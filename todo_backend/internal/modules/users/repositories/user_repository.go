package repositories

type User struct {
	ID             string  `json:"id"`
	FirebaseUserID string  `json:"firebase_user_id"`
	Email          string  `json:"email"`
	Name           string  `json:"name"`
	AvatarURL      *string `json:"avatar_url,omitempty"`
	CreatedAt      string  `json:"created_at"`
	UpdatedAt      string  `json:"updated_at"`
	IsConfigured   bool    `json:"is_configured"`
}

type UpsertUserInput struct {
	FirebaseUserID string
	Email          string
	Name           *string
	AvatarURL      *string
}

type UpdateUserInput struct {
	Name *string `json:"name,omitempty"`
}

type UserRepository interface {
	GetUserByID(userID string) (*User, error)

	UpsertUser(user UpsertUserInput) (string, error)

	UpdateUser(userID string, updatedBy string, data UpdateUserInput) error
}
