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

func getTreeById(problemId int) *leaderboard.BTree {
	treeInterface, ok := leaderboardsKeyToScore.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
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
