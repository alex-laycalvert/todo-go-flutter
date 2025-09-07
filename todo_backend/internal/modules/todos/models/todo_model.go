package models

import "database/sql"

type TodoModel struct {
	ID            string
	Title         string
	Description   string
	IsCompleted   bool
	CreatedByID   string
	CreatedAt     string
	CompletedAt   sql.NullString
	CompletedByID sql.NullString
}
