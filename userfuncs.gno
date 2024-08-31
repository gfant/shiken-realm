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

func GetProblemsSolved(user *UserScore) int {
	return user.ProblemsSolved.Size()
}

func GetAttempts(user *UserScore) int {
	return user.Attempts.Size()
}

func GetAddress(user *UserScore) std.Address {
	return user.Address
}
