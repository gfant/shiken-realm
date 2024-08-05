package shiken

import (
	"strconv"

	avl "gno.land/p/demo/avl"

	shiken_support "gno.land/p/dev/shiken_support"
)

func RenderScores(id int) string {
	idString := strconv.Itoa(id)
	// Tree{problemId -> Tree{Address -> score}}
	lbInterface, ok := leaderboards.Get(idString)
	if !ok {
		panic(ErrNoProblemId)
	}
	lb := lbInterface.(*avl.Tree)
	output := "{"
	output += `"problem":` + RenderProblem(id) + ","
	output += `"scores":` + shiken_support.ReadScores(lb)
	output += "}"
	return output
}

func RenderProblems() string {
	output := shiken_support.ReadProblems(Problems)
	return output
}

func RenderProblem(problemId int) string {
	idString := strconv.Itoa(problemId)
	problemInterface, ok := Problems.Get(idString)
	if !ok {
		panic(ErrNoProblemId)
	}
	problem := problemInterface.(*shiken_support.Problem)
	output := problem.ReadProblem()
	return output
}
