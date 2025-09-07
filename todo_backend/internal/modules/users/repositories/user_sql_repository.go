package repositories

import (
	"database/sql"
	"strings"
	"todo_backend/internal/modules/users/models"

	"github.com/google/uuid"
)

type UserSQLRepository struct {
	db *sql.DB
}

func NewUserSQLRepository(db *sql.DB) *UserSQLRepository {
	return &UserSQLRepository{db}
}

func (r *UserSQLRepository) GetUserByID(id string) (*User, error) {
	row := r.db.QueryRow(`
		SELECT id, firebase_user_id, email, name, avatar_url, created_at, updated_at
		FROM users
		WHERE id = ?
	`, id)

	var userModel models.UserModel
	err := row.Scan(
		&userModel.ID,
		&userModel.FirebaseUserID,
		&userModel.Email,
		&userModel.Name,
		&userModel.AvatarURL,
		&userModel.CreatedAt,
		&userModel.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil // No user found
		}
		return nil, err
	}

	var avatarURL *string
	if userModel.AvatarURL.Valid {
		avatarURL = &userModel.AvatarURL.String
	} else {
		avatarURL = nil
	}

	return &User{
		ID:             userModel.ID,
		FirebaseUserID: userModel.FirebaseUserID,
		Email:          userModel.Email,
		Name:           userModel.Name,
		AvatarURL:      avatarURL,
		CreatedAt:      userModel.CreatedAt,
		UpdatedAt:      userModel.UpdatedAt,
		IsConfigured:   userModel.IsConfigured(),
	}, nil
}

func (r *UserSQLRepository) UpsertUser(input UpsertUserInput) (string, error) {
	newId := uuid.New().String()

	// Build dynamic SQL based on provided fields (non-nil pointers)
	setParts := []string{}
	args := []any{}

	// Email is always updated since it's required
	setParts = append(setParts, "email = ?")
	args = append(args, input.Email)
	if input.Name != nil {
		setParts = append(setParts, "name = ?")
		args = append(args, *input.Name)
	}

	if input.AvatarURL != nil {
		setParts = append(setParts, "avatar_url = ?")
		args = append(args, sql.NullString{String: *input.AvatarURL, Valid: *input.AvatarURL != ""})
	}

	// Always update updated_at
	setParts = append(setParts, "updated_at = datetime('now')")

	// Prepare the upsert query with RETURNING clause for ID
	query := `
		INSERT INTO users (id, firebase_user_id, email, name, avatar_url, created_at, updated_at)
		VALUES (?, ?, ?, ?, ?, datetime('now'), datetime('now'))
		ON CONFLICT(firebase_user_id) DO UPDATE SET ` +
		strings.Join(setParts, ", ") + `
		RETURNING id`

	// Prepare arguments for the INSERT part
	var nameVal string
	var avatarVal sql.NullString

	if input.Name != nil {
		nameVal = *input.Name
	}
	if input.AvatarURL != nil {
		avatarVal = sql.NullString{String: *input.AvatarURL, Valid: *input.AvatarURL != ""}
	}

	insertArgs := []any{
		newId,
		input.FirebaseUserID,
		input.Email,
		nameVal,
		avatarVal,
	}
	// Combine INSERT args with UPDATE args
	allArgs := append(insertArgs, args...)

	// Execute the upsert query and get the returned ID
	var userID string
	row := r.db.QueryRow(query, allArgs...)
	err := row.Scan(&userID)
	if err != nil {
		return "", err
	}

	return userID, nil
}

func (r *UserSQLRepository) UpdateUser(userID string, updatedBy string, data UpdateUserInput) error {
	query := `UPDATE users SET
		updated_at = datetime('now')`
	args := []any{}

	if data.Name != nil && *data.Name != "" {
		query += `, name = ?`
		args = append(args, *data.Name)
	}

	query += ` WHERE id = ?`
	args = append(args, userID)

	_, err := r.db.Exec(query, args...)
	return err
}
