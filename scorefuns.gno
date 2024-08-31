package shiken

import (
	"std"

	leaderboard "gno.land/p/dev/shiken_leaderboards"

	ufmt "gno.land/p/demo/ufmt"
)

type Score struct {
	Key       int
	Address   std.Address
	ProblemId int
	Score     int
	Tests     string
}

func (s *Score) InputInformation(address std.Address, score, problemId int, tests string) {
	// These entries are only updated if the data hasn't been edited before
	if problemId != 0 && s.ProblemId == 0 {
		s.ProblemId = problemId
	}
	if s.Score == 0 {
		s.Score = score
	}

	if tests != "" && len(s.Tests) != 0 {
		s.Tests = tests
	}
	if len(s.Address) == 0 {
		s.Address = address
	}
}

func (s *Score) ReadScore() string {
	var output string
	output += ufmt.Sprintf(`{"Address": "%s","Score"  : "%d","Tests" : "%s"}`, s.Address, s.Score, s.Tests)
	return output
}

func ReadScores(tree *leaderboard.BTree) string {
	interfaces := leaderboard.ValuesInOrder(tree) // Output is a slice of interface{}
	var output string
	for _, v := range interfaces {
		score := v.(*Score)
		output += score.ReadScore() + ","
	}
	output = output[:len(output)-1] // Remove trailing comma
	return output
}

func (s *Score) GetKey() int {
	return s.Key
}

func (s *Score) GetScore() int {
	return s.Score
}
