package utils

import (
	"fmt"
	"testing"
)

func TestStr2Byte(t *testing.T) {
	fmt.Println(Str2Byte("alice_pwd"))
}

func TestSha256Encrypt(t *testing.T) {
	fmt.Println(Sha256Encrypt("alice_pwd"))
}
