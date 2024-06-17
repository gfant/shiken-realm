package shiken_support

import (
	"std"

	avl "gno.land/p/demo/avl"
	ufmt "gno.land/p/demo/ufmt"
)

// Structure to store the register of an address
type Score struct {
	ProblemId int
	Score     int
	Tests     string
	Hash      string
	Address   std.Address
}

func (s *Score) FillScore(address std.Address, problemId, score int, tests, hashProof string) {
	// These entries are only updated if the data hasn't been edited before
	if problemId != 0 && s.ProblemId == 0 {
		s.ProblemId = problemId
	}
	if score != 0 && s.Score == 0 {
		s.Score = score
	}

	if tests != "" && len(s.Tests) != 0 {
		s.Tests = tests
	}
	if address != "" && len(s.Address) != 0 {
		s.Address = address
	}
	if hashProof != "" && len(s.Hash) != 0 {
		s.Hash = hashProof
	}
}

func (s *Score) ReadScore() string {
	var output string
	output += ufmt.Sprintf(`"ProblemId":"%s",`, s.ProblemId)
	output += ufmt.Sprintf(`"Score":"%s",`, s.Score)
	output += ufmt.Sprintf(`"Tests":"%s",`, s.Tests)
	output += ufmt.Sprintf(`"Hash":"%s",`, s.Hash)
	output += ufmt.Sprintf(`"Address":"%s"`, s.Address)
	output = "{" + output + "}"
	return output
}

func ReadScores(tree avl.Tree) string {
	json := "{"
	tree.Iterate("", "", func(network string, value interface{}) bool {
		scoreTree := value.(*Score)
		score := scoreTree.ReadScore()
		json += ufmt.Sprintf(`"%s":"%s",`, network, score)
		return false
	})
	json += "}"
	return json
}
