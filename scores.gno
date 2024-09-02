package shiken

import (
	"std"

	avl "gno.land/p/demo/avl"
	leaderboard "gno.land/p/dev/shiken_leaderboards"
)

// Scores-specific errors
const (
	ErrNoScoreRegistered             = "score for address not found"
	ErrNoLeaderboardForProblemId     = "leaderboard for problem id not found or not existent"
	ErrLeaderboardEmptyOrNotExistent = "leaderboard empty or not existent"
	ErrSomethingFailed               = "something failed"
)

func AddNewScore(address std.Address, problemId, score int, tests string) {
	createNewAttemptByUser(address, problemId, score)
	if validateTreeShouldAddScore(score, problemId) && compareNewScoreIsBetterThanOld(address, score, problemId) {
		updateLeaderboardsAndAddressRegister(address, problemId, score, tests)
	}
	updateScoreCounter()
}

func validateTreeShouldAddScore(score, problemId int) bool {
	tree := getProblemScoreTreeById(problemId)
	if tree.IsEmpty() {
		return true
	}
	worstScore := GetSlowestScore(problemId)
	return worthToBeAdded(worstScore, score, tree)
}

func worthToBeAdded(worstScore, score int, tree *leaderboard.BTree) bool {
	return worstScore > score || tree.GetSize() < 10000
}

func updateLeaderboardsAndAddressRegister(address std.Address, problemId, newScore int, tests string) {
	scoreId := generateScoreId(newScore)
	newScoreRecord := generateRecordForLeaderboard(address, newScore, scoreId, problemId, tests)
	updateLeaderboard(problemId, newScoreRecord)
	registerScoreIdToAddress(address, scoreId, problemId)
}

func generateScoreId(score int) int {
	return score*LeaderboardFactor + scoreCounter
}

func generateRecordForLeaderboard(address std.Address, score, scoreId, problemId int, tests string) leaderboard.Content {
	scoreStruct := generateNewScore(address, score, scoreId, problemId, tests)
	newContent := leaderboard.Content{Value: &scoreStruct}
	newContent.AddKey(scoreStruct.Key)
	return newContent
}

func updateLeaderboard(problemId int, nodeForLeaderboard leaderboard.Content) {
	bTreeScores := getLeaderboard(problemId)
	bTreeScores.Insert(nodeForLeaderboard)
	problemIdString := getStringFromInt(problemId)
	leaderboardsKeyToScore.Set(problemIdString, bTreeScores)
}

func registerScoreIdToAddress(address std.Address, newId, problemId int) {
	invertedLeaderboard := getInvertedLeaderboard(problemId)
	if previousScoreExists(address, invertedLeaderboard) {
		removePositionFromLeaderboard(address, problemId, invertedLeaderboard)
	}
	updateIdForAddress(address, problemId, newId, invertedLeaderboard)
}

func previousScoreExists(address std.Address, avlTree *avl.Tree) bool {
	_, ok := avlTree.Get(address.String())
	return ok
}

func removePositionFromLeaderboard(address std.Address, problemId int, leaderboardTree *avl.Tree) {
	leaderboardTree.Remove(address.String())
	leaderboardsAddressToKey.Set(getStringFromInt(problemId), leaderboardTree)
}

func updateIdForAddress(address std.Address, problemId, newId int, avlTree *avl.Tree) {
	avlTree.Set(address.String(), newId)
	leaderboardsAddressToKey.Set(getStringFromInt(problemId), avlTree)
}

func generateNewScore(address std.Address, score, scoreId, problemId int, tests string) Score {
	newScore := Score{}
	newScore.Key = scoreId
	newScore.InputInformation(address, score, problemId, tests)
	return newScore
}

func updateScoreCounter() {
	scoreCounter++
}

func compareNewScoreIsBetterThanOld(address std.Address, newScore, problemId int) bool {
	if !addressPreviousScoreExists(address, problemId) {
		return true
	}
	lastScore := getAddressPosition(address, problemId)

	// Case score exists
	btree := getLeaderboard(problemId)
	// Get the score for the given address
	content, err := btree.Search(lastScore)
	breakIfError(err, ErrSomethingFailed)
	score := content.Value.(*Score)
	// Check if the new score is better than the existing score
	lastScore = lastScore / LeaderboardFactor
	return newScore < score.Score
}

func getLeaderboard(problemId int) *leaderboard.BTree {
	bTreeInterface, ok := leaderboardsKeyToScore.Get(getStringFromInt(problemId))
	breakIfNotOk(ok, ErrNoLeaderboardForProblemId)
	bTree := bTreeInterface.(*leaderboard.BTree)
	return bTree
}

func GetFastestScore(problemId int) int {
	tree := getProblemScoreTreeById(problemId)
	bContent, err := tree.GetSmallestKey()
	breakIfError(err, ErrLeaderboardEmptyOrNotExistent)
	bScore := bContent.Value.(*Score)
	return bScore.Score
}

func GetSlowestScore(problemId int) int {
	tree := getProblemScoreTreeById(problemId)
	scoreInterface, err := tree.GetGreatestKey()
	breakIfError(err, ErrLeaderboardEmptyOrNotExistent)
	scoreStruct := scoreInterface.Value.(*Score)
	return scoreStruct.Score
}

func getInvertedLeaderboard(problemId int) *avl.Tree {
	avlTreeInterface, ok := leaderboardsAddressToKey.Get(getStringFromInt(problemId))
	breakIfNotOk(ok, ErrNoLeaderboardForProblemId)
	return avlTreeInterface.(*avl.Tree)
}

func getAddressPosition(address std.Address, problemId int) int {
	avlTree := getInvertedLeaderboard(problemId)
	positionInterface, ok := avlTree.Get(address.String())
	if !ok {
		return -1
	}
	position := positionInterface.(int)
	return position
}

func addressPreviousScoreExists(address std.Address, problemId int) bool {
	position := getAddressPosition(address, problemId)
	return position != -1
}

func readScores(tree *leaderboard.BTree) string {
	interfaces := leaderboard.ValuesInOrder(tree) // Output is a slice of interface{}
	output := generateScoresString(interfaces)
	return output
}

func generateScoresString(interfaces []interface{}) string {
	var output string
	for _, v := range interfaces {
		score := v.(*Score)
		output += score.ReadScore() + ","
	}
	output = output[:len(output)-1] // Remove trailing comma
	return output
}
