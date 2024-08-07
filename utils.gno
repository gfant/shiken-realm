package shiken

import (
	"std"
	"strconv"

	leaderboard "gno.land/p/dev/shiken_leaderboards"
	shiken_problems "gno.land/p/dev/shiken_problems"
)

// Adding new problem to the list
func AddNewProblem(title, statement, examples string) {
	caller := std.GetOrigCaller()
	verifyDAO(caller)
	newProblem := new(shiken_problems.Problem)
	newProblem.FillProblem(title, statement, examples)
	id := strconv.Itoa(ProblemId)
	Problems.Set(id, newProblem)
	// For later purposes
	leaderboards.Set(id, leaderboard.NewBTree(3))
	ProblemId++
}

// Adding score of an user
func AddNewScore(address std.Address, problemId, score int, tests string) {
	// Generating score record
	newScore := leaderboard.Score{}
	newScore.FillScore(address, score, problemId, tests)

	// Getting the leaderboard for problem
	problemIdString := strconv.Itoa(problemId)
	bTreeInterface, ok := leaderboards.Get(problemIdString)
	if !ok {
		panic(ErrNoProblemId)
	}
	bTreeScores := bTreeInterface.(*leaderboard.BTree)
	// Generating id for score
	scoreIntId := score*LeaderboardFactor + updaterCounter

	// Setting the score only if it's better than the worst score
	if newBestScore(scoreIntId, problemId) {
		newScore.AddKey(scoreIntId)                    // Adding key to order in the tree
		bTreeScores.Insert(newScore)                   // Adding the score into the tree
		leaderboards.Set(problemIdString, bTreeScores) // Returning the tree into the leaderboard avl.tree
	}
	updaterCounter++
}
