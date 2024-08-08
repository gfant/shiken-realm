package shiken_leaderboards

import (
	ufmt "gno.land/p/demo/ufmt"
)

func (s *Score) ReadScore() string {
	var output string
	output += ufmt.Sprintf(`{"Address": "%s","Score"  : "%d","Tests" : "%s"}`, s.Address, s.Score, s.Tests)
	return output
}

func ReadScores(tree *BTree) string {
	output := tree.ValuesInOrder()
	return output
}
