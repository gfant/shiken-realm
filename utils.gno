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
	newScore.Key = scoreIntId
	newScore.FillScore(address, score, problemId, tests)
	// Node to be added in the leaderboard
	newContent := leaderboard.Content{Value: &newScore}
	newContent.AddKey(scoreIntId)

	// Getting the leaderboard for problem
	problemIdString := strconv.Itoa(problemId)
	bTreeInterface, ok := leaderboards.Get(problemIdString)
	if !ok {
		panic(ErrNoProblemId)
	}
	bTreeScores := bTreeInterface.(*leaderboard.BTree)
	if newBestScore(scoreIntId, problemId) && addressNewBestScore(address, score, problemId) {
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
		removePositionFromLeaderboard(idForAddress, problemId)
	}
	// Adding the address with the new id
	avlTree.Set(address.String(), newId)
	// and updating the invertedLeaderboard
	invertedLeaderboards.Set(strconv.Itoa(problemId), avlTree)
}

// Removes a registered address from the leaderboard given its position
func removePositionFromLeaderboard(position, problemId int) {
	bTreeInterface, ok := leaderboards.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	btree := bTreeInterface.(*leaderboard.BTree)
	btree.Delete(position)
	leaderboards.Set(strconv.Itoa(problemId), btree)
}

// Returns true if the address has reached a new best score.
// Otherwise returns false
func addressNewBestScore(address std.Address, newScore, problemId int) bool {
	// Get the last score of the address given in the problem with id problemId
	lastScore := getAddressId(address, problemId)
	// Case score don't exist yet
	if lastScore == 0 {
		return true
	}

	// Case score exists
	bTreeInterface, ok := leaderboards.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	btree := bTreeInterface.(*leaderboard.BTree)
	// Get the score for the given address
	content, err := btree.Search(lastScore)
	if err != nil {
		panic(err)
	}
	score := content.Value.(*Score)
	// Check if the new score is better than the existing score
	lastScore = lastScore / LeaderboardFactor
	isBetter := newScore < score.Score
	return isBetter
}

// Gets the id associated to the address if the address is already registered
func getAddressId(address std.Address, problemId int) int {
	// Get the inverted leaderboard for the problem
	avlTreeInterface, ok := invertedLeaderboards.Get(strconv.Itoa(problemId))
	if !ok {
		return 0
	}
	avlTree := avlTreeInterface.(*avl.Tree)
	// Get the position of the address in the inverted leaderboard
	position, ok := avlTree.Get(address.String())
	if !ok {
		return 0
	}
	intPosition := position.(int)
	return intPosition
}
