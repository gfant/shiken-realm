package shiken

import (
	"std"
	"strconv"

	avl "gno.land/p/demo/avl"

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
	// Setting the new leaderboard for the problem
	leaderboards.Set(id, newTree)
	// Setting the inverted leaderboard for the problem
	invertedLeaderboards.Set(id, new(avl.Tree))
	// Incrementing the problem id
	ProblemId++
}

// Adding score of an user
func AddNewScore(address std.Address, problemId, score int, tests string) {
	// Generating id for score
	scoreIntId := score*LeaderboardFactor + updaterCounter
	// Generating score record
	newScore := Score{}
	newScore.FillScore(address, score, problemId, tests)
	newScore.Key = scoreIntId
	newContent := leaderboard.Content{Value: &newScore}

	// Getting the leaderboard for problem
	problemIdString := strconv.Itoa(problemId)
	bTreeInterface, ok := leaderboards.Get(problemIdString)
	if !ok {
		panic(ErrNoProblemId)
	}
	bTreeScores := bTreeInterface.(*leaderboard.BTree)

	// Setting the score only if it's better than the worst score
	if newBestScore(scoreIntId, problemId) {
		// Inserting the id in the content for later usage
		newContent.AddKey(scoreIntId)
		// Inserting the new score in the btree
		bTreeScores.Insert(newContent)
		// Setting the updated leaderboard for the problem
		leaderboards.Set(problemIdString, bTreeScores)
		// Registering the address in the inverted leaderboard
		// Address -> ScoreId in ProblemId
		registerIdToAddress(address, scoreIntId, problemId)
	}
	updaterCounter++
}

func registerIdToAddress(address std.Address, newId, problemId int) {
	// Getting the leaderboard for problem
	avlTreeInterface, ok := invertedLeaderboards.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	avlTree := avlTreeInterface.(*avl.Tree)
	idForAddressInterface, ok := avlTree.Get(address.String())
	if ok {
		// If the address is in the leaderboard, the id is removed
		// and the address is inserted again with the new id
		idForAddress := idForAddressInterface.(int)
		id := idForAddress
		removeRegisteredAddressFromLeaderboard(id, problemId)
	}
	invertedLeaderboards.Set(strconv.Itoa(problemId), avlTree)
	avlTree.Set(address.String(), newId)
}

func removeRegisteredAddressFromLeaderboard(position, problemId int) {
	bTreeInterface, ok := leaderboards.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	btree := bTreeInterface.(*leaderboard.BTree)
	btree.Delete(position)
	leaderboards.Set(strconv.Itoa(problemId), btree)
}
