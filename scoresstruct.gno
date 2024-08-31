package shiken

import (
	"std"

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
	setProblemId(s, problemId)
	setScore(s, score)
	setTests(s, tests)
	setAddress(s, address)
}

func setProblemId(s *Score, problemId int) {
	if problemId != 0 && s.ProblemId == 0 {
		s.ProblemId = problemId
	}
}

func setScore(s *Score, score int) {
	if score != 0 && s.Score == 0 {
		s.Score = score
	}
}

func setTests(s *Score, tests string) {
	if tests != "" && len(s.Tests) == 0 {
		s.Tests = tests
	}
}

func setAddress(s *Score, address std.Address) {
	if address != "" && len(s.Address) == 0 {
		s.Address = address
	}
}

func (s *Score) ReadScore() string {
	var output string
	output += ufmt.Sprintf(`{"Address": "%s","Score"  : "%d","Tests" : "%s"}`, s.Address, s.Score, s.Tests)
	return output
}

func (s *Score) GetKey() int {
	return s.Key
}

func (s *Score) GetScore() int {
	return s.Score
}
