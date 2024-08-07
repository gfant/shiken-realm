package shiken

import (
	"strconv"

	leaderboard "gno.land/p/dev/shiken_leaderboards"
	shiken_problems "gno.land/p/dev/shiken_problems"
)

func RenderScores(id int) string {
	idString := strconv.Itoa(id)
	// Tree{problemId -> Tree{Address -> score}}
	lbInterface, ok := leaderboards.Get(idString)
	if !ok {
		panic(ErrNoProblemId)
	}
	lb := lbInterface.(*leaderboard.BTree)
	output := "{"
	output += `"problem":` + RenderProblem(id) + ","
	output += `"scores":[` + leaderboard.ReadScores(lb) + "]"
	output += "}"
	return output
}

func RenderProblems() string {
	output := shiken_problems.ReadProblems(Problems)
	return output
}

func RenderProblem(problemId int) string {
	idString := strconv.Itoa(problemId)
	problemInterface, ok := Problems.Get(idString)
	if !ok {
		panic(ErrNoProblemId)
	}
	problem := problemInterface.(*shiken_problems.Problem)
	output := problem.ReadProblem()
	return output
}
