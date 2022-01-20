package test

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/shinjam/simpleChat/app/models"
	"github.com/shinjam/simpleChat/pkg/routes"
	"github.com/stretchr/testify/assert"
)

func TestUserSignIn(t *testing.T) {
	// Load Fixtures
	PrepareTestDatabase()

	user := &models.SignIn{
		Email:    "guest1@test.com",
		Password: "1234",
	}

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
		body, _ := io.ReadAll(resp.Body)
		fmt.Println(string(body))
	}

	// Verify, if the status code is as expected.
	if !assert.Equalf(t, 200, resp.StatusCode, "sign in user") {
		body, _ := io.ReadAll(resp.Body)
		fmt.Println(string(body))
	}
}
