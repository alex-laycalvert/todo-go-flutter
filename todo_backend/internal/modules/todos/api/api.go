package api

import (
	"encoding/json"
	"log"
	"net/http"
	"todo_backend/internal/middleware"
	"todo_backend/internal/modules/todos/repositories"

	"github.com/go-chi/chi/v5"
)

type TodoAPI struct {
	repository repositories.TodoRepository
}

func NewTodoAPI(repository repositories.TodoRepository) *TodoAPI {
	return &TodoAPI{repository}
}

func (api *TodoAPI) GetTodosHandler(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	userID := ctx.Value(middleware.AuthUserIDKey).(string)
	term := r.URL.Query().Get("term")
	isCompleted := r.URL.Query().Get("is_completed")
	var isCompletedPtr *bool
	if isCompleted != "" {
		val := isCompleted == "true"
		isCompletedPtr = &val
	}
	todos, err := api.repository.ListTodos(repositories.ListTodosQuery{
		Term:        term,
		UserID:      userID,
		IsCompleted: isCompletedPtr,
	})
	if err != nil {
		http.Error(w, "Error fetching todos", http.StatusInternalServerError)
		return
	}
	jsonResp, err := json.Marshal(todos)
	if err != nil {
		http.Error(w, "Error marshaling todos data", http.StatusInternalServerError)
		return
	}
	w.Write(jsonResp)
}

func (api *TodoAPI) PostTodosHandler(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	userID := ctx.Value(middleware.AuthUserIDKey).(string)
	var input repositories.CreateTodoInput
	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		log.Println("Error decoding request body:", err)
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	input.CreatedByID = userID
	// TODO: validate
	todoID, err := api.repository.CreateTodo(input)
	if err != nil {
		log.Println("Error creating todo:", err)
		http.Error(w, "Error creating todo", http.StatusInternalServerError)
		return
	}
	jsonResp, err := json.Marshal(map[string]string{"id": todoID})
	if err != nil {
		log.Println("Error marshaling todo data:", err)
		http.Error(w, "Error marshaling todo data", http.StatusInternalServerError)
		return
	}
	w.Write(jsonResp)
}

func (api *TodoAPI) GetTodoHandler(w http.ResponseWriter, r *http.Request) {
	todoID := chi.URLParam(r, "todoID")
	if todoID == "" {
		http.Error(w, "Missing todo ID", http.StatusBadRequest)
		return
	}

	todo, err := api.repository.GetTodoByID(todoID)
	if err != nil {
		log.Println("Error fetching todo:", err)
		http.Error(w, "Error fetching todo", http.StatusInternalServerError)
		return
	}
	if todo == nil {
		log.Println("Todo not found:", todoID)
		http.Error(w, "Todo not found", http.StatusNotFound)
		return
	}
	jsonResp, err := json.Marshal(todo)
	if err != nil {
		log.Println("Error marshaling todo data:", err)
		http.Error(w, "Error marshaling todo data", http.StatusInternalServerError)
		return
	}

	w.Write(jsonResp)
}

func (api *TodoAPI) PostTodoHandler(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	userID := ctx.Value(middleware.AuthUserIDKey).(string)

	todoID := chi.URLParam(r, "todoID")
	if todoID == "" {
		http.Error(w, "Missing todo ID", http.StatusBadRequest)
		return
	}

	err := api.repository.CompleteTodo(todoID, userID)
	if err != nil {
		log.Println("Error completing todo:", err)
		http.Error(w, "Error completing todo", http.StatusInternalServerError)
		return
	}

	jsonResp, err := json.Marshal(map[string]string{"id": todoID})
	if err != nil {
		log.Println("Error marshaling todo data:", err)
		http.Error(w, "Error marshaling todo data", http.StatusInternalServerError)
		return
	}

	w.Write(jsonResp)
}
