package routes

import (
	"github.com/gofiber/fiber/v2"
	"github.com/shinjam/simpleChat/docs"
	"github.com/shinjam/simpleChat/pkg/configs"

	swagger "github.com/arsmn/fiber-swagger/v2"
)

func init() {
	docs.SwaggerInfo.Version = configs.Version
}

// SwaggerRoute func for describe group of API Docs routes.
func SwaggerRoute(a *fiber.App) {
	// Create routes group.
	route := a.Group("/swagger")

	// Routes for GET method:
	route.Get("*", swagger.Handler) // get one user by ID
}
