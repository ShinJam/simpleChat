package queries

import (
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/labstack/gommon/log"
	"github.com/shinjam/simpleChat/app/models"
	"github.com/shinjam/simpleChat/pkg/repository"
)

// UserQueries struct for queries from User model.
type UserQueries struct {
	*sqlx.DB
}

// GetAllUsers query for getting all users
func (q *UserQueries) GetAllUsers() ([]repository.User, error) {
	var users []models.User
	err := q.Select(&users, `SELECT id, email FROM kuve.user WHERE user_status=1`)
	if err != nil {
		// Return empty object and error.
		log.Error(err)
		return nil, err
	}
	var repoUsers []repository.User
	for i := range users {
		// solve gosec G601: Implicit memory aliasing of items from a range statement
		// reference: https://stackoverflow.com/questions/62446118/implicit-memory-aliasing-in-for-loop/68247837
		repoUsers = append(repoUsers, &users[i])
	}

	return repoUsers, nil
}

// GetUserByID query for getting one User by given ID.
func (q *UserQueries) GetUserByID(id uuid.UUID) (models.User, error) {
	// Define User variable.
	user := models.User{}

	// Define query string.
	query := `SELECT * FROM kuve.user WHERE id = $1`

	// Send query to database.
	err := q.Get(&user, query, id)
	if err != nil {
		// Return empty object and error.
		return user, err
	}

	// Return query result.
	return user, nil
}

// GetUserByEmail query for getting one User by given Email.
func (q *UserQueries) GetUserByEmail(email string) (models.User, error) {
	// Define User variable.
	user := models.User{}

	// Define query string.
	query := `SELECT * FROM kuve.user WHERE email = $1`

	// Send query to database.
	err := q.Get(&user, query, email)
	if err != nil {
		// Return empty object and error.
		return user, err
	}

	// Return query result.
	return user, nil
}

// CreateUser query for creating a new user by given email and password hash.
func (q *UserQueries) CreateUser(u *models.User) error {
	// Define query string.
	query := `INSERT INTO kuve.user VALUES ($1, $2, $3, $4, $5, $6, $7)`

	// Send query to database.
	_, err := q.Exec(
		query,
		u.ID, u.CreatedAt, u.UpdatedAt, u.Email, u.PasswordHash, u.UserStatus, u.UserRole,
	)
	if err != nil {
		// Return only error.
		return err
	}

	// This query returns nothing.
	return nil
}

// DeleteeUser query for delete a new user by given id.
func (q *UserQueries) SoftDeleteeUserByID(id uuid.UUID) error {
	// Define query string.
	query := `UPDATE kuve.user SET user_status=0 WHERE id = $1`

	_, err := q.Exec(query, id)

	if err != nil {
		// Return only error.
		return err
	}

	// This query returns nothing.
	return nil

}
