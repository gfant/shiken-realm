package shiken_leaderboards

import (
	"std"
)

func (s *Score) FillScore(address std.Address, score, problemId int, tests string) {
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

func (s *Score) AddKey(key int) {
	s.Key = key
}
