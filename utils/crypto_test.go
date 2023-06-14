package utils

import (
	"fmt"
	"testing"
)

func TestSha256Encrypt(t *testing.T) {
	fmt.Println(Sha256Encrypt("alice_pwd"))
}
