package server

import (
	"encoding/json"
	"net/http"
	"todo_backend/internal/middleware"

	todosAPI "todo_backend/internal/modules/todos/api"
	todoRepositories "todo_backend/internal/modules/todos/repositories"

	usersAPI "todo_backend/internal/modules/users/api"
	userRepositories "todo_backend/internal/modules/users/repositories"

	"github.com/go-chi/chi/v5"
	chiMiddleware "github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
)

func (s *Server) RegisterRoutes() http.Handler {
	r := chi.NewRouter()
	r.Use(chiMiddleware.Logger)

	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"https://*", "http://*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type"},
		AllowCredentials: true,
		MaxAge:           300,
	}))

	r.Get("/health", s.healthHandler)
	db := s.db.GetDB()
	userRepository := userRepositories.NewUserSQLRepository(db)

	// Protected
	r.With(middleware.FirebaseAuthMiddlware(s.authClient, userRepository, nil)).Group(func(r chi.Router) {
		r.Route("/users", func(r chi.Router) {
			api := usersAPI.NewUserAPI(userRepository)
			r.Get("/{userID}", api.GetUserHandler)
			r.Put("/{userID}", api.PutUserHandler)
		})
	})

	// Protected, configured user
	r.With(
		middleware.FirebaseAuthMiddlware(
			s.authClient,
			userRepository,
			&middleware.FirebaseAuthMiddlewareOptions{
				MustBeConfigured: true,
			}),
	).Group(func(r chi.Router) {
		r.Route("/todos", func(r chi.Router) {
			api := todosAPI.NewTodoAPI(todoRepositories.NewTodoSQLRepository(db))
			r.Get("/", api.GetTodosHandler)
			r.Post("/", api.PostTodosHandler)

			r.Get("/{todoID}", api.GetTodoHandler)
			r.Post("/{todoID}", api.PostTodoHandler)
		})
	})

	return r
}

func (s *Server) healthHandler(w http.ResponseWriter, r *http.Request) {
	jsonResp, _ := json.Marshal(s.db.Health())
	_, _ = w.Write(jsonResp)
}
