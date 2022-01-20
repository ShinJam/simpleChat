package utils

import (
	"fmt"
	"os"
)

// ConnectionURLBuilder func for building URL connection.
func ConnectionURLBuilder(n string) (string, error) {
	// Define URL to connection.
	var url string

	// Switch given names.
	switch n {
	case "postgres":
		// URL for PostgreSQL connection.
		url = os.Getenv("DATABASE_URL")
	case "redis":
		// URL for Redis connection.
		url = os.Getenv("REDIS_URL")
	case "fiber":
		// URL for Fiber connection.
		url = os.Getenv("SERVER_URL")
	default:
		// Return error message.
		return "", fmt.Errorf("connection name '%v' is not supported", n)
	}

	// Return connection URL.
	return url, nil
}
