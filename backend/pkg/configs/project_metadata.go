package configs

import (
	"path"
	"runtime"
)

const (
	Version string = "1"
)

var (
	RootDir string
)

func init() {
	_, filename, _, _ := runtime.Caller(0)
	RootDir = path.Join(path.Dir(filename), "../..")
}
