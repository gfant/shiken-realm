package shiken

import (
	"std"
	"strconv"

	leaderboard "gno.land/p/dev/shiken_leaderboards"
)

func verifyDAO(caller std.Address) bool {
	_, ok := DAO.Get(caller.String())
	if !ok {
		panic(ErrNotDAOMember)
	}
	return true
}

func newBestScore(score, problemId int) bool {
	treeInterface, ok := leaderboards.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	tree := treeInterface.(*leaderboard.BTree)
	worst := tree.GetSmallest()
	if worst.Key > score {
		return true
	} else {
		return false
	}
}
