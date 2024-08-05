package shiken

import (
	"std"
)

func verifyDAO(caller std.Address) bool {
	_, ok := DAO.Get(caller.String())
	if !ok {
		panic(ErrNotDAOMember)
	}
	return true
}

func newBestScore(score int) bool {
	return true
}
