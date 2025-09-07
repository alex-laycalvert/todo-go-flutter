package repositories

import (
	"database/sql"
	"strings"
	"todo_backend/internal/modules/todos/models"

	"github.com/google/uuid"
)

type TodoSQLRepository struct {
	db *sql.DB
}

func NewTodoSQLRepository(db *sql.DB) *TodoSQLRepository {
	return &TodoSQLRepository{db}
}

func (r *TodoSQLRepository) GetTodoByID(id string) (*Todo, error) {
	selectQuery := `SELECT
		todo.id,
		todo.title,
		todo.description,
		todo.created_at,
		todo.is_completed,
		todo.completed_at,

		creator.id as created_by_id,
		creator.name as created_by_name,

		completor.id as completed_by_id,
		completor.name as completed_by_name
	FROM todos todo
	JOIN users creator on todo.created_by_id = creator.id
	LEFT JOIN users completor on todo.completed_by_id = completor.id
	WHERE todo.id = ?`

	var todoModel models.TodoModel
	var createdByID, createdByName string
	var completedAt, completedByID, completedByName sql.NullString
	err := r.db.QueryRow(selectQuery, id).Scan(
		&todoModel.ID,
		&todoModel.Title,
		&todoModel.Description,
		&todoModel.CreatedAt,
		&todoModel.IsCompleted,
		&completedAt,
		&createdByID,
		&createdByName,
		&completedByID,
		&completedByName,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	todo := Todo{
		ID:          todoModel.ID,
		Title:       todoModel.Title,
		Description: todoModel.Description,
		CreatedAt:   todoModel.CreatedAt,
		IsCompleted: todoModel.IsCompleted,
		CreatedBy: TodoUser{
			ID:   createdByID,
			Name: createdByName,
		},
	}
	if completedByID.Valid && completedByName.Valid {
		todo.CompletedBy = &TodoUser{
			ID:   completedByID.String,
			Name: completedByName.String,
		}
	} else {
		todo.CompletedBy = nil
	}
	if completedAt.Valid {
		todo.CompletedAt = &completedAt.String
	} else {
		todo.CompletedAt = nil
	}

	return &todo, nil
}

func (r *TodoSQLRepository) ListTodos(listTodosQuery ListTodosQuery) (*ListTodosResult, error) {
	selectQuery := `SELECT
		todo.id,
		todo.title,
		todo.description,
		todo.created_at,
		todo.is_completed,
		todo.completed_at,

		creator.id as created_by_id,
		creator.name as created_by_name,

		completor.id as completed_by_id,
		completor.name as completed_by_name
	FROM todos todo
	JOIN users creator on todo.created_by_id = creator.id
	LEFT JOIN users completor on todo.completed_by_id = completor.id`
	queryParts := []string{selectQuery}
	args := []any{}

	conditions := []string{}
	if listTodosQuery.UserID != "" {
		conditions = append(conditions, "(todo.created_by_id = ? OR todo.completed_by_id = ?)")
		args = append(args, listTodosQuery.UserID, listTodosQuery.UserID)
	}

	if listTodosQuery.Term != "" {
		term := "%" + strings.ToLower(listTodosQuery.Term) + "%"
		conditions = append(conditions, "(LOWER(todo.title) LIKE ? OR LOWER(todo.description) LIKE ?)")
		args = append(args, term, term)
	}

	if listTodosQuery.IsCompleted != nil {
		conditions = append(conditions, "todo.is_completed = ?")
		args = append(args, *listTodosQuery.IsCompleted)
	}

	result := ListTodosResult{Todos: []Todo{}}

	conditionQuery := ""
	if len(conditions) > 0 {
		for i, condition := range conditions {
			if i == 0 {
				conditionQuery += " WHERE " + condition
			} else {
				conditionQuery += " AND " + condition
			}
		}
	}
	queryParts = append(queryParts, conditionQuery)

	stmt, err := r.db.Prepare(strings.Join(queryParts, " "))
	if err != nil {
		return nil, err
	}
	queryResults, err := stmt.Query(args...)
	if err != nil {
		return nil, err
	}
	defer queryResults.Close()

	for queryResults.Next() {
		var todo Todo
		var createdByID, createdByName string
		var completedAt, completedByID, completedByName sql.NullString
		err := queryResults.Scan(
			&todo.ID,
			&todo.Title,
			&todo.Description,
			&todo.CreatedAt,
			&todo.IsCompleted,
			&completedAt,
			&createdByID,
			&createdByName,
			&completedByID,
			&completedByName,
		)
		if err != nil {
			return nil, err
		}

		todo.CreatedBy = TodoUser{
			ID:   createdByID,
			Name: createdByName,
		}

		if completedByID.Valid && completedByName.Valid {
			todo.CompletedBy = &TodoUser{
				ID:   completedByID.String,
				Name: completedByName.String,
			}
		} else {
			todo.CompletedBy = nil
		}

		if completedAt.Valid {
			todo.CompletedAt = &completedAt.String
		} else {
			todo.CompletedAt = nil
		}

		result.Todos = append(result.Todos, todo)
	}
	if err := queryResults.Err(); err != nil {
		return nil, err
	}

	return &result, nil
}

func (r *TodoSQLRepository) CreateTodo(input CreateTodoInput) (string, error) {
	newID := uuid.New().String()
	err := r.db.QueryRow(
		`INSERT INTO todos (id, title, description, created_by_id)
		VALUES (?, ?, ?, ?)
		RETURNING id`,
		newID, input.Title, input.Description, input.CreatedByID,
	).Scan(&newID)
	return newID, err
}

func (r *TodoSQLRepository) CompleteTodo(todoID string, completedByID string) error {
	_, err := r.db.Exec(`UPDATE todos
		SET is_completed = 1, completed_by_id = ?, completed_at = CURRENT_TIMESTAMP
		WHERE id = ?`,
		completedByID, todoID,
	)
	return err
}
