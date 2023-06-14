package utils

import (
	"crypto/sha256"
	"encoding/hex"
)

func Sha256Encrypt(str string) string {
	b := []byte(str)
	sha256Instance := sha256.New()
	sha256bytes := sha256Instance.Sum(b)
	sha256string := hex.EncodeToString(sha256bytes)
	return sha256string
}
