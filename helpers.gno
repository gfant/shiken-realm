package shiken

import (
	"std"
	"strconv"

	leaderboard "gno.land/p/dev/shiken_leaderboards"
)

func verifyAddressBelongsToDAO(caller std.Address) bool {
	_, ok := DAO.Get(caller.String())
	if !ok {
		panic(ErrNotDAOMember)
	}
	return true
}

// New score worth to be added in the leaderboard
func validateTreeShouldAddScore(score, problemId int) bool {
	tree := getTreeById(problemId)
	if tree.IsEmpty() {
		return true
	}
	worstScore := GetSlowestScore(problemId)
	return worthToBeAdded(worstScore, score, tree)
}

func worthToBeAdded(worstScore, score int, tree *leaderboard.BTree) bool {
	return worstScore > score || tree.GetSize() < 10000
}

func GetFastestScore(problemId int) int {
	tree := getTreeById(problemId)
	bContent, err := tree.GetSmallestKey()
	if err != nil {
		panic(ErrNoProblemId)
	}
	bScore := bContent.Value.(*Score)
	if err != nil {
		panic(ErrNoProblemId)
	}
	return bScore.Score
}

func GetSlowestScore(problemId int) int {
	tree := getTreeById(problemId)
	scoreInterface, err := tree.GetGreatestKey()
	scoreStruct := scoreInterface.Value.(*Score)
	if err != nil {
		panic(ErrNoProblemId)
	}
	return scoreStruct.Score
}

func getTreeById(problemId int) *leaderboard.BTree {
	treeInterface, ok := leaderboardsKeyToScore.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	return treeInterface.(*leaderboard.BTree)
}

func StringProblemId() string {
	return strconv.Itoa(ProblemId)
}
