package test

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"fmt"
	"github.com/labstack/gommon/log"
	"io/ioutil"
	"net/http/httptest"
	"regexp"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/shinjam/simpleChat/app/models"
	"github.com/shinjam/simpleChat/pkg/routes"
	"github.com/shinjam/simpleChat/pkg/utils"
	"github.com/stretchr/testify/assert"
)

func TestUserSignIn(t *testing.T) {
	db, mock := MockQuery()
	defer func(db *sql.DB) {
		err := db.Close()
		if err != nil {
			log.Error(err)
		}
	}(db)

	user := &models.SignIn{
		Email:    "guest2@test.com",
		Password: "1234",
	}

	// use QuoteMeta func to escape character
	// reference: https://stackoverflow.com/questions/59652031/sqlmock-is-not-matching-query-but-query-is-identical-and-log-output-shows-the-s
	query := regexp.QuoteMeta(`SELECT * FROM kuve.user WHERE email = ?`)

	rows := sqlmock.NewRows([]string{"id", "created_at", "updated_at", "email", "password_hash", "user_status", "user_role"}).
		AddRow(uuid.New(), time.Now(), nil, user.Email, utils.GeneratePassword(user.Password), 1, "user")

	mock.ExpectQuery(query).WithArgs(user.Email).WillReturnRows(rows)

	// Define a new Fiber app.
	app := fiber.New()

	// Define routes.
	routes.PublicRoutes(app)

	userBytes, _ := json.Marshal(user)
	req := httptest.NewRequest("POST", "/api/v1/user/sign/in", bytes.NewReader(userBytes))
	req.Header.Set("Content-Type", "application/json")

	// Perform the request plain with the app.
	resp, err := app.Test(req, -1) // the -1 disables request latency

	// Verify, that no error occurred, that is not expected
	if !assert.Equalf(t, false, err != nil, "sign in user") {
		body, _ := ioutil.ReadAll(resp.Body)
		fmt.Println(string(body)) // => Hello, World!
	}

	// Verify, if the status code is as expected.
	assert.Equalf(t, 200, resp.StatusCode, "sign in user")
}
