package main

import (
	"fmt"
	"time"
)

func currentTS() int64 {
	now := time.Now().Unix()
	return now
}

func targetTS(year int, month int, day int, hour int, minute int, second int) int64 {
	ret := time.Date(year, time.Month(month), day, hour, minute, second, 0, time.Local).Unix()
	return ret
}

func delayedTS(delay string) int64 {
	now := time.Now()
	dur, _ := time.ParseDuration(delay)
	ret := now.Add(dur)
	return ret.Unix()
}

func main() {
	fmt.Println("Current Timestamp: ", currentTS())
	fmt.Println("Target Timestamp", targetTS(2077, 7, 7, 7, 7, 7))
	fmt.Println("Delayed Timestamp", delayedTS("1h"))
}
