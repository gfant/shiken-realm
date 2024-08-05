package shiken

import (
	"std"
	"strconv"

	avl "gno.land/p/demo/avl"

	shiken_support "gno.land/p/dev/shiken_support"
)

// Adding new problem to the list
func AddNewProblem(title, statement, examples string) {
	caller := std.GetOrigCaller()
	verifyDAO(caller)
	newProblem := new(shiken_support.Problem)
	newProblem.FillProblem(title, statement, examples)
	id := strconv.Itoa(ProblemId)
	Problems.Set(id, newProblem)
	// For later purposes
	leaderboards.Set(id, new(avl.Tree))
	ProblemId++
}

// Adding score of an user
func AddNewScore(address std.Address, problemId int, score, tests string) {
	// Generating score record
	newScore := new(shiken_support.Score)
	newScore.FillScore(address, problemId, score, tests)

	// Getting the leaderboard for problem
	problemIdString := strconv.Itoa(problemId)
	scoresInterface, ok := leaderboards.Get(problemIdString)
	if !ok {
		panic(ErrNoProblemId)
	}
	scores := scoresInterface.(*avl.Tree)

	// Generating id for score
	scoreInt, err := strconv.Atoi(score)
	if err != nil {
		panic(err)
	}
	scoreIntId := scoreInt*LeaderboardFactor + updaterCounter
	scoreId := strconv.Itoa(scoreIntId)

	// Setting the score
	scores.Set(scoreId, newScore)
	leaderboards.Set(problemIdString, scores)
}
