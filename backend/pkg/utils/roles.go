package utils

import (
	"github.com/labstack/gommon/log"
	"github.com/shinjam/simpleChat/pkg/repository"
)

// VerifyRole func for verifying a given role.
func VerifyRole(role string) (string, error) {
	// Switch given role.
	switch role {
	case repository.AdminRoleName:
		// Nothing to do, verified successfully.
	case repository.UserRoleName:
		// Nothing to do, verified successfully.
	default:
		// Set default role
		role = repository.UserRoleName
		log.Debugf("set default role as user")
	}

	return role, nil
}
