package shiken

import (
	"std"
	"strconv"

	avl "gno.land/p/demo/avl"

	leaderboard "gno.land/p/dev/shiken_leaderboards"
	shiken_problems "gno.land/p/dev/shiken_problems"
)

func AddNewProblem(title, statement, examples string) {
	verifyAddressBelongsToDAO(std.GetOrigCaller())
	setupNewProblem(title, statement, examples)
}

func setupNewProblem(title, statement, examples string) {
	storeNewProblemData(title, statement, examples)
	generateProblemTree()
	generateProblemInvertedTree()
	updateProblemId()
}

func updateProblemId() {
	ProblemId++
}

func AddNewScore(address std.Address, problemId, score int, tests string) {
	if validateTreeShouldAddScore(score, problemId) && compareNewScoreIsBetterThanOld(address, score, problemId) {
		scoreId := generateScoreId(score)
		newScoreNode := generateNodeForLeaderboard(address, score, scoreId, problemId, tests)
		updateLeaderboard(problemId, newScoreNode)
		registerScoreIdToAddress(address, scoreId, problemId)
	}
	updateScoreCounter()
}

func updateLeaderboard(problemId int, nodeForLeaderboard leaderboard.Content) {
	bTreeScores := getLeaderboard(problemId)
	bTreeScores.Insert(nodeForLeaderboard)
	problemIdString := GetStringFromInt(problemId)
	leaderboardsKeyToScore.Set(problemIdString, bTreeScores)
}

func GetStringFromInt(value int) string {
	return strconv.Itoa(value)
}

func updateScoreCounter() {
	scoreCounter++
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

func updateIdForAddress(address std.Address, problemId, newId int, avlTree *avl.Tree) {
	avlTree.Set(address.String(), newId)
	leaderboardsAddressToKey.Set(strconv.Itoa(problemId), avlTree)
}

// Removes a registered address from the leaderboard given its position
func removePositionFromLeaderboard(address std.Address, problemId int, leaderboardTree *avl.Tree) {
	leaderboardTree.Remove(address.String())
	leaderboardsAddressToKey.Set(strconv.Itoa(problemId), leaderboardTree)
}

// Returns true if the address has reached a new best score.
// Otherwise returns false
func compareNewScoreIsBetterThanOld(address std.Address, newScore, problemId int) bool {
	if !addressPreviousScoreExists(address, problemId) {
		return true
	}
	lastScore := getAddressPosition(address, problemId)

	// Case score exists
	btree := getLeaderboard(problemId)
	// Get the score for the given address
	content, err := btree.Search(lastScore)
	if err != nil {
		panic(err)
	}
	score := content.Value.(*Score)
	// Check if the new score is better than the existing score
	lastScore = lastScore / LeaderboardFactor
	return newScore < score.Score
}

func getInvertedLeaderboard(problemId int) *avl.Tree {
	avlTreeInterface, ok := leaderboardsAddressToKey.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	avlTree := avlTreeInterface.(*avl.Tree)
	return avlTree
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

func getLeaderboard(problemId int) *leaderboard.BTree {
	bTreeInterface, ok := leaderboardsKeyToScore.Get(strconv.Itoa(problemId))
	if !ok {
		panic(ErrNoProblemId)
	}
	bTree := bTreeInterface.(*leaderboard.BTree)
	return bTree
}

// Generators

func generateNewScore(address std.Address, score, scoreId, problemId int, tests string) Score {
	newScore := Score{}
	newScore.Key = scoreId
	newScore.InputInformation(address, score, problemId, tests)
	return newScore
}

func generateNodeForLeaderboard(address std.Address, score, scoreId, problemId int, tests string) leaderboard.Content {
	scoreStruct := generateNewScore(address, score, scoreId, problemId, tests)
	newContent := leaderboard.Content{Value: &scoreStruct}
	newContent.AddKey(scoreStruct.Key)
	return newContent
}

func generateScoreId(score int) int {
	return score*LeaderboardFactor + scoreCounter
}

func storeNewProblemData(title, statement, examples string) {
	newProblem := new(shiken_problems.Problem)
	newProblem.InputInformation(title, statement, examples)
	Problems.Set(StringProblemId(), newProblem)
}

func generateProblemTree() {
	newTree, err := leaderboard.NewBTree(2)
	if err != nil {
		panic(err)
	}
	leaderboardsKeyToScore.Set(StringProblemId(), newTree)
}

func generateProblemInvertedTree() {
	newTree := new(avl.Tree)
	leaderboardsAddressToKey.Set(StringProblemId(), newTree)
}
