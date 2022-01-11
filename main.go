package main

import (
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/shinjam/simpleChat/pkg/configs"
	"github.com/shinjam/simpleChat/pkg/middleware"
	"github.com/shinjam/simpleChat/pkg/routes"
	"github.com/shinjam/simpleChat/pkg/utils"

	_ "github.com/shinjam/simpleChat/docs"
)

// @title API
// @version 1.0
// @description This is an auto-generated API Docs.
// @termsOfService http://swagger.io/terms/
// @contact.name shin
// @contact.email nevvjann@gmail.com
// @license.name MIT
// @license.url https://github.com/shinjam/simpleChat/LICENSE
// @securityDefinitions.apikey ApiKeyAuth
// @in header
// @name Authorization
// @BasePath /api
func main() {
	// Define Fiber config.
	config := configs.FiberConfig()

	// Define a new Fiber app with config.
	app := fiber.New(config)

	// Middlewares.
	middleware.FiberMiddleware(app) // Register Fiber's middleware for app.

	// Routes.
	routes.SwaggerRoute(app) // Register a route for API Docs (Swagger).
	routes.PublicRoutes(app) // Register a public routes for app.

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	// Start server (with or without graceful shutdown).
	if os.Getenv("STAGE_STATUS") == "dev" {
		utils.StartServer(app)
	} else {
		utils.StartServerWithGracefulShutdown(app)
	}
}
