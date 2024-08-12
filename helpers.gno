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
	} else {
		// Getting the worst score is the element with the highest
		// Score, so we get the greatest element
		worstContent, err := tree.GetGreatest()
		if err != nil {
			panic(ErrNoProblemId)
		}
		worst := worstContent.Value.(*Score)
		if worst.Score > score || tree.GetSize() < 10000 {
			return true
		} else {
			return false
		}
	}
	return true
}

func GetFastest(problemId int) int {
	treeInterface, ok := leaderboards.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	tree := treeInterface.(*leaderboard.BTree)
	bContent, err := tree.GetSmallest()
	if err != nil {
		panic(ErrNoProblemId)
	}
	bScore := bContent.Value.(*Score)
	if err != nil {
		panic(ErrNoProblemId)
	}
	return bScore.Score
}

func GetSlowest(problemId int) int {
	treeInterface, ok := leaderboards.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	tree := treeInterface.(*leaderboard.BTree)
	bContent, err := tree.GetGreatest()
	bScore := bContent.Value.(*Score)
	if err != nil {
		panic(ErrNoProblemId)
	}
	return bScore.Score
}

func GetScoreSize(problemId int) int {
	treeInterface, ok := leaderboards.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	tree := treeInterface.(*leaderboard.BTree)
	return tree.GetSize()
}
