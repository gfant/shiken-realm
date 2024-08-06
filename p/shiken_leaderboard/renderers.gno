package shiken_leaderboards

import (
	ufmt "gno.land/p/demo/ufmt"
)

func (s *Score) ReadScore() string {
	var output string
	output += ufmt.Sprintf(`{"Address":"%s"}`, s.Address)
	output += ufmt.Sprintf(`"Score":"%d",`, s.Score)
	output += ufmt.Sprintf(`"Tests":"%s"}`, s.Tests)
	return output
}

func ReadScores(tree *BTree) string {
	tree.InOrderTraversal()
	output := tree.ValuesInOrder()
	return output
}
