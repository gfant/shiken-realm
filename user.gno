package shiken

import (
	"std"

	avl "gno.land/p/demo/avl"
)

type UserScore struct {
	Address        std.Address
	ProblemsSolved avl.Tree
	Attempts       avl.Tree
}

func getProblemsSolved(user *UserScore) int {
	return user.ProblemsSolved.Size()
}

func getAttempts(user *UserScore) int {
	return user.Attempts.Size()
}

func getAddress(user *UserScore) std.Address {
	return user.Address
}
