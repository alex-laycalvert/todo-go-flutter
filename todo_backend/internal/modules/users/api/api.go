package api

import (
	"encoding/json"
	"log"
	"net/http"
	"todo_backend/internal/middleware"
	"todo_backend/internal/modules/users/repositories"

	"github.com/go-chi/chi/v5"
)

const meUserID = "me"

type UserAPI struct {
	repository repositories.UserRepository
}

func NewUserAPI(repository repositories.UserRepository) *UserAPI {
	return &UserAPI{repository}
}

func (api *UserAPI) GetUserHandler(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "userID")

	if userID == meUserID {
		ctx := r.Context()
		userID = ctx.Value(middleware.AuthUserIDKey).(string)
	}

	user, err := api.repository.GetUserByID(userID)
	if err != nil {
		http.Error(w, "Error fetching user", http.StatusInternalServerError)
		return
	}
	if user == nil {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}
	jsonResp, err := json.Marshal(user)
	if err != nil {
		http.Error(w, "Error marshaling user data", http.StatusInternalServerError)
	}
	w.Write(jsonResp)
}

func (api *UserAPI) PutUserHandler(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	userID := chi.URLParam(r, "userID")
	authUserID := ctx.Value(middleware.AuthUserIDKey).(string)

	if userID == meUserID {
		userID = authUserID
	}

	var input repositories.UpdateUserInput
	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	// TODO: validate

	err = api.repository.UpdateUser(userID, authUserID, input)
	if err != nil {
		log.Println("Error updating user:", err)
		http.Error(w, "Error updating user", http.StatusInternalServerError)
		return
	}

	jsonResp, err := json.Marshal(map[string]string{"id": userID})
	if err != nil {
		http.Error(w, "Error marshaling user data", http.StatusInternalServerError)
	}
	w.Write(jsonResp)
}
