package shiken

import (
	"std"

	ufmt "gno.land/p/demo/ufmt"

	avl "gno.land/p/demo/avl"
)

type UserRegister struct {
	Address        string   // There is no need to store it as address
	ProblemsSolved avl.Tree // Tree{problemId -> score}
	Attempts       avl.Tree // Tree{problemId -> attempts}
	TotalAttempts  int
}

const (
	ErrNoUser     = "No user found"
	ErrUserExists = "User already exists"
)

func createNewAttemptByUser(address std.Address, problemId int, score int) {
	createUserRegisterIfNecessary(address.String())
	user := getUserRegister(address.String())
	updateAttempts(user, problemId)
	updateTotalAttempts(user)
}

func createUserRegisterIfNecessary(address string) {
	if !verifyUserExists(address) {
		user := createUserRegister(address)
		TreeAddressToData.Set(address, user)
	}
}

func verifyUserExists(address string) bool {
	_, ok := TreeAddressToData.Get(address)
	return ok
}

func createUserRegister(address string) *UserRegister {
	return &UserRegister{
		Address:        address,
		ProblemsSolved: *avl.NewTree(),
		Attempts:       *avl.NewTree(),
	}
}

func getUserRegister(address string) *UserRegister {
	userInterface, ok := TreeAddressToData.Get(address)
	breakIfNotOk(ok, ErrNoUser)
	return userInterface.(*UserRegister)
}

func updateProblemsSolved(user *UserRegister, problemId, score int) {
	problemsSolved := getProblemsSolvedTree(user)
	problemsSolved.Set(getStringFromInt(problemId), score)
	user.setProblemsSolved(problemsSolved)
}

func (user *UserRegister) setProblemsSolved(problemsSolved avl.Tree) {
	user.ProblemsSolved = problemsSolved
}

func updateAttempts(user *UserRegister, problemId int) {
	attempts := getAttempts(user)
	attempts.Set(getStringFromInt(problemId), getPreviousAttempts(attempts, problemId)+1)
	user.setAttempts(attempts)
}

func (user *UserRegister) setAttempts(attempts avl.Tree) {
	user.Attempts = attempts
}

func getPreviousAttempts(attempts avl.Tree, problemId int) int {
	attemptsInterface, ok := attempts.Get(getStringFromInt(problemId))
	if !ok {
		return 0
	}
	return attemptsInterface.(int)
}

func updateTotalAttempts(user *UserRegister) {
	user.TotalAttempts++
}

func renderUserRegister(address string) string {
	var output string
	user := getUserRegister(address)
	output += ufmt.Sprintf(`{"Address": "%s","ProblemsSolved"  : "%d","Attempts" : "%d"}`, getAddress(user), "", getAttempts(user))
	return output
}

func getProblemsSolvedTree(user *UserRegister) avl.Tree {
	return user.ProblemsSolved
}

func getAttempts(user *UserRegister) avl.Tree {
	return user.Attempts
}

func getAddress(user *UserRegister) string {
	return user.Address
}
