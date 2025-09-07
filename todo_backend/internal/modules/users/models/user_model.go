package models

import (
	"database/sql"
	"strings"
)

type UserModel struct {
	ID             string
	FirebaseUserID string
	Email          string
	Name           string
	AvatarURL      sql.NullString
	CreatedAt      string
	UpdatedAt      string
}

func (u *UserModel) IsConfigured() bool {
	return strings.TrimSpace(u.Name) != "" && strings.TrimSpace(u.Email) != ""
}
