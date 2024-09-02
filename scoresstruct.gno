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
	if intNotZero(problemId) && intNotZero(s.ProblemId) {
		s.ProblemId = problemId
	}
}

func setScore(s *Score, score int) {
	if intNotZero(score) && intNotZero(s.Score) {
		s.Score = score
	}
}

func setTests(s *Score, tests string) {
	if stringNotEmpty(tests) && stringNotEmpty(s.Tests) {
		s.Tests = tests
	}
}

func setAddress(s *Score, address std.Address) {
	if stringNotEmpty(address.String()) && stringNotEmpty(s.Address.String()) {
		s.Address = address
	}
}

func (s *Score) ReadScore() string {
	var output string
	output += ufmt.Sprintf(`{"Address": "%s","Score"  : "%d","Tests" : "%s"}`, s.GetAddress(), s.GetScore(), s.GetTests())
	return output
}

func (s *Score) GetAddress() std.Address {
	return s.Address
}

func (s *Score) GetKey() int {
	return s.Key
}

func (s *Score) GetScore() int {
	return s.Score
}

func (s *Score) GetTests() string {
	return s.Tests
}
