package shiken_support

import (
	"std"

	avl "gno.land/p/demo/avl"
	ufmt "gno.land/p/demo/ufmt"
)

// Structure to store the register of an address
type Score struct {
	Key       int
	Address   std.Address
	ProblemId int
	Score     int
	Tests     string
}

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
	if address != "" && len(s.Address) != 0 {
		s.Address = address
	}
}

func (s *Score) AddKey(key int) {
	s.Key = key
}

func (s *Score) ReadScore() string {
	var output string
	output += ufmt.Sprintf(`{"ProblemId":"%s",`, s.ProblemId)
	output += ufmt.Sprintf(`"Score":"%d",`, s.Score)
	output += ufmt.Sprintf(`"Tests":"%s"}`, s.Tests)
	return output
}

func ReadScores(tree *avl.Tree) string {
	json := "{"
	tree.Iterate("", "", func(network string, value interface{}) bool {
		scoreTree := value.(*Score)
		score := scoreTree.ReadScore()
		json += ufmt.Sprintf(`"%s":%s,`, network, score)
		return false
	})
	if len(json) > 1 {
		json = json[0 : len(json)-1]
	}
	json += "}"
	return json
}
