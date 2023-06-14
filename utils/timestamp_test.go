package utils

import (
	"fmt"
	"testing"
)

func TestCurrentTS(t *testing.T) {
	fmt.Println("Current Timestamp: ", currentTS())
}

func TestTargetTS(t *testing.T) {
	fmt.Println("Target Timestamp", targetTS(2077, 7, 7, 7, 7, 7))
}

func TestDelayedTS(t *testing.T) {
	fmt.Println("Delayed Timestamp", delayedTS("3m"))
}
