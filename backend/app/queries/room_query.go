package queries

import (
	"log"

	"github.com/jmoiron/sqlx"
	"github.com/shinjam/simpleChat/app/models"
	"github.com/shinjam/simpleChat/pkg/repository"
)

type RoomQueries struct {
	*sqlx.DB
}

// CreateRoom query for creating a new Room by given id, name, private
func (q *RoomQueries) CreateRoom(r repository.Room) error {
	query := `INSERT INTO kuve.room(id, name, private) values($1, $2, $3)`
	log.Print(r.GetId(), r.GetName(), r.GetPrivate())
	// Send query to database.
	_, err := q.Exec(
		query,
		r.GetId(), r.GetName(), r.GetPrivate(),
	)
	if err != nil {
		// Return only error.
		return err
	}

	// This query returns nothing.
	return nil
}

// GetRoomByName query for getting one Room by given name.
func (q *RoomQueries) GetRoomByName(name string) (models.Room, error) {
	// Define Room variable.
	room := models.Room{}

	// Define query string.
	query := `SELECT id, name, private FROM kuve.room where name = $1 LIMIT 1`

	// Send query to database.
	err := q.Get(&room, query, name)
	if err != nil {
		// Return empty object and error.
		return room, err
	}

	// Return query result.
	return room, nil
}
