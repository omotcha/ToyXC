package utils

import (
	"crypto/sha256"
	"encoding/hex"
)

func Str2Byte(str string) string {
	var bl = []byte(str)
	var hs = hex.EncodeToString(bl)
	if len(hs) >= 64 {
		return "0x" + hs[0:64]
	}
	for {
		if len(hs) >= 64 {
			break
		}
		hs = hs + "0000"
	}
	return "0x" + hs[0:64]
}

func Sha256Encrypt(str string) string {
	b := []byte(str)
	sha256Instance := sha256.New()
	sha256bytes := sha256Instance.Sum(b)
	sha256string := hex.EncodeToString(sha256bytes)
	return sha256string
}
