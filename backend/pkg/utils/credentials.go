package utils

import (
	"fmt"

	"github.com/shinjam/simpleChat/pkg/repository"
)

// GetCredentialsByRole func for getting credentials from a role name.
func GetCredentialsByRole(role string) ([]string, error) {
	// Define credentials variable.
	var credentials []string

	// Switch given role.
	switch role {
	case repository.AdminRoleName:
		// Admin credentials (all access).
		credentials = []string{
			// repository.BookCreateCredential,
			// repository.BookUpdateCredential,
			// repository.BookDeleteCredential,
		}
	case repository.UserRoleName:
		// Simple user credentials (only book creation).
		credentials = []string{
			// repository.BookCreateCredential,
		}
	default:
		// Return error message.
		return nil, fmt.Errorf("role '%v' does not exist", role)
	}

	return credentials, nil
}
