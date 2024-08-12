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
	newTree, err := leaderboard.NewBTree(2)
	if err != nil {
		panic(err)
	}
	leaderboards.Set(id, newTree)
	ProblemId++
}

// Adding score of an user
func AddNewScore(address std.Address, problemId, score int, tests string) {
	// Generating score record
	newScore := Score{}
	newScore.FillScore(address, score, problemId, tests)
	newContent := leaderboard.Content{Value: &newScore}

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
		newContent.AddKey(scoreIntId)                  // Adding key to order in the tree
		bTreeScores.Insert(newContent)                 // Adding the score into the tree
		leaderboards.Set(problemIdString, bTreeScores) // Returning the tree into the leaderboard avl.tree
	}
	updaterCounter++
}
