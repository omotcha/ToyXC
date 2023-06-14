package utils

import (
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
