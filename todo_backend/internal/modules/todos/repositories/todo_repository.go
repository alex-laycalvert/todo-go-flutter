package repositories

type TodoUser struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

type Todo struct {
	ID          string    `json:"id"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	CreatedAt   string    `json:"created_at"`
	CreatedBy   TodoUser  `json:"created_by"`
	IsCompleted bool      `json:"is_completed"`
	CompletedBy *TodoUser `json:"completed_by,omitempty"`
	CompletedAt *string   `json:"completed_at,omitempty"`
}

type ListTodosResult struct {
	Todos []Todo `json:"todos"`
}

type ListTodosQuery struct {
	Term        string
	IsCompleted *bool
	UserID      string
}

type CreateTodoInput struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	CreatedByID string
}

type TodoRepository interface {
	GetTodoByID(todoID string) (*Todo, error)

	ListTodos(listTodosQuery ListTodosQuery) (*ListTodosResult, error)

	CreateTodo(input CreateTodoInput) (string, error)

	CompleteTodo(todoID string, completedByID string) error
}
