package middleware

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/websocket/v2"
	"github.com/shinjam/simpleChat/app/ws"
	"github.com/shinjam/simpleChat/platform/database"

	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
)

// FiberMiddleware provide Fiber's built-in middlewares.
// See: https://docs.gofiber.io/api/middleware
func FiberMiddleware(a *fiber.App) {
	a.Use(
		// Add CORS to each route.
		cors.New(),
		// Add simple logger.
		logger.New(),
	)
}

func FiberWebsocketMiddleware(a *fiber.App, wsServer *ws.WsServer) {
	a.Use("/ws", func(c *fiber.Ctx) error {
		// Create database connection.
		db, err := database.OpenDBConnection()
		if err != nil {
			// Return status 500 and database connection error.
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": true,
				"msg":   err.Error(),
			})
		}
		users, err := db.GetAllUsers()
		wsServer.Users = users

		// IsWebSocketUpgrade returns true if the client
		// requested upgrade to the WebSocket protocol.
		if websocket.IsWebSocketUpgrade(c) {
			c.Locals("allowed", true)
			c.Locals("wsServer", wsServer)
			return c.Next()
		}

		return fiber.ErrUpgradeRequired
	})
}
