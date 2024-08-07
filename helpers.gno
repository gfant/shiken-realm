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
	if tree.GetSize() == 0 {
		return true
	}
	worst := tree.GetSmallest()
	if worst.Score > score || tree.GetSize() < 10000 {
		return true
	} else {
		return false
	}
}

func GetFastest(problemId int) int {
	treeInterface, ok := leaderboards.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	tree := treeInterface.(*leaderboard.BTree)
	b := tree.GetSmallest()
	return b.Score
}

func GetSlowest(problemId int) int {
	treeInterface, ok := leaderboards.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	tree := treeInterface.(*leaderboard.BTree)
	s := tree.GetSmallest()
	return s.Score
}
