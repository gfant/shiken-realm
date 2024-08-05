package shiken

import (
	"std"
	"strconv"

	btree "gno.land/p/dev/btree"
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
	tree := treeInterface.(*btree.BTree)
	worst := tree.GetSmallest()
	if worst.Key > score {
		return true
	} else {
		return false
	}
}
