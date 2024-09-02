package shiken

import (
	"std"
	"strconv"

	leaderboard "gno.land/p/dev/shiken_leaderboards"
)

func verifyAddressBelongsToDAO(caller std.Address) bool {
	_, ok := DAO.Get(caller.String())
	breakIfNotOk(ok, ErrNotDAOMember)
	return true
}

func getProblemScoreTreeById(problemId int) *leaderboard.BTree {
	treeInterface, ok := leaderboardsKeyToScore.Get(getStringFromInt(problemId))
	breakIfNotOk(ok, ErrNoProblemId)
	return treeInterface.(*leaderboard.BTree)
}

func getProblemById(problemId int) *leaderboard.BTree {
	treeInterface, ok := Problems.Get(getStringFromInt(problemId))
	breakIfNotOk(ok, ErrNoProblemId)
	return treeInterface.(*leaderboard.BTree)
}

func getStringProblemId() string {
	return strconv.Itoa(ProblemId)
}

func getStringFromInt(value int) string {
	return strconv.Itoa(value)
}

func breakIfNotOk(ok bool, msg string) {
	if !ok {
		panic(msg)
	}
}

func breakIfError(err error, msg string) {
	if err != nil {
		panic(msg)
	}
}

func stringNotEmpty(value string) bool {
	return len(value) != 0
}

func intNotZero(value int) bool {
	return value != 0
}
