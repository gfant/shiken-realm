package shiken

import (
	"std"

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

func storeNewProblemData(title, statement, examples string) {
	newProblem := new(shiken_problems.Problem)
	newProblem.InputInformation(title, statement, examples)
	Problems.Set(getStringProblemId(), newProblem)
}

func generateProblemTree() {
	newTree, err := leaderboard.NewBTree(2)
	if err != nil {
		panic(err)
	}
	leaderboardsKeyToScore.Set(getStringProblemId(), newTree)
}

func generateProblemInvertedTree() {
	newTree := new(avl.Tree)
	leaderboardsAddressToKey.Set(getStringProblemId(), newTree)
}

func updateProblemId() {
	ProblemId++
}
