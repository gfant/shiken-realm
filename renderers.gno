package shiken

import (
	leaderboard "gno.land/p/dev/shiken_leaderboards"
	shiken_problems "gno.land/p/dev/shiken_problems"
)

func RenderScores(id int) string {
	// Tree{problemId -> Tree{Address -> score}}
	lbInterface, ok := leaderboardsKeyToScore.Get(getStringFromInt(id))
	if !ok {
		panic(ErrNoProblemId)
	}
	lb := lbInterface.(*leaderboard.BTree)
	output := "{"
	output += `"problem":` + RenderProblem(id) + ","
	output += `"scores":[` + readScores(lb) + "]"
	output += "}"
	return output
}

func RenderProblems() string {
	output := shiken_problems.ReadProblems(Problems)
	return output
}

func RenderProblem(problemId int) string {
	idString := getStringFromInt(problemId)
	problemInterface, ok := Problems.Get(idString)
	if !ok {
		panic(ErrNoProblemId)
	}
	problem := problemInterface.(*shiken_problems.Problem)
	output := problem.ReadProblem()
	return output
}
