package routes

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/websocket/v2"
	"github.com/shinjam/simpleChat/app/ws"
	"github.com/shinjam/simpleChat/pkg/configs"
)

// PublicRoutes func for describe group of public routes.
func WebsocketRoutes(a *fiber.App) {
	// Create routes group.
	route := a.Group("/ws/v" + configs.Version)

	// Routes for POST method:
	route.Get("/", websocket.New(ws.ServeWs)) // register a new user
}
