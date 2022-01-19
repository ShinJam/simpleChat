package routes

import (
	"github.com/gofiber/fiber/v2"
	"github.com/shinjam/simpleChat/app/controllers"
	"github.com/shinjam/simpleChat/pkg/configs"
)

// PublicRoutes func for describe group of public routes.
func PublicRoutes(a *fiber.App) {
	// Create routes group.
	route := a.Group("/api/v" + configs.Version)

	// Routes for POST method:
	route.Post("/user/sign/up", controllers.UserSignUp) // register a new user
	route.Post("/user/sign/in", controllers.UserSignIn) // auth, return Access & Refresh tokens
}
