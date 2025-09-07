package middleware

import (
	"context"
	"log"
	"net/http"
	"todo_backend/internal/modules/users/repositories"

	"firebase.google.com/go/v4/auth"
	chiMiddleware "github.com/go-chi/chi/v5/middleware"
)

const AuthUserIDKey = "authUserID"

type FirebaseAuthMiddlewareOptions struct {
	MustBeConfigured bool
}

func FirebaseAuthMiddlware(client *auth.Client, userRepository repositories.UserRepository, options *FirebaseAuthMiddlewareOptions) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Use chi middleware to get the request ID
			requestID := chiMiddleware.GetReqID(r.Context())

			idToken := r.Header.Get("Authorization")
			if idToken == "" {
				http.Error(w, "Authorization header missing", http.StatusUnauthorized)
				return
			}
			idToken = idToken[len("Bearer "):]

			// Verify the ID token
			token, err := client.VerifyIDToken(r.Context(), idToken)
			if err != nil {
				log.Printf("Error verifying ID token: %v", err)
				http.Error(w, "Invalid ID token", http.StatusUnauthorized)
				return
			}
			firebaseUserID := token.UID
			email := token.Claims["email"].(string)
			name, ok := token.Claims["displayName"].(string)
			nameValue := &name
			if !ok {
				nameValue = nil
			}
			authUserID, err := userRepository.UpsertUser(repositories.UpsertUserInput{
				FirebaseUserID: firebaseUserID,
				Email:          email,
				Name:           nameValue,
			})
			if err != nil {
				log.Printf("Error upserting user: %v", err)
				http.Error(w, "Error upserting user", http.StatusInternalServerError)
				return
			}

			if options != nil && options.MustBeConfigured {
				user, err := userRepository.GetUserByID(authUserID)
				if err != nil {
					log.Printf("Error fetching user: %v", err)
					http.Error(w, "Error fetching user", http.StatusInternalServerError)
					return
				}
				if user == nil || !user.IsConfigured {
					http.Error(w, "User not configured", http.StatusForbidden)
					return
				}
			}

			// Add the user ID to the request context
			ctx := r.Context()
			ctx = context.WithValue(ctx, AuthUserIDKey, authUserID)
			ctx = context.WithValue(ctx, "firebaseUserID", token.UID)
			ctx = context.WithValue(ctx, "requestID", requestID)

			// Call the next handler with the updated context
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}
