package shiken

import (
	"std"

	avl "gno.land/p/demo/avl"
)

var (
	Problems             avl.Tree    // Id -> Problem
	leaderboards         avl.Tree    // Id -> Btree{Key -> ScoreData}
	invertedLeaderboards avl.Tree    // Id -> Avl.Tree{Address -> Score}
	updaterCounter       int         // Counter to update the attempts in leaderboards
	Account              avl.Tree    // Address -> Data
	owner                std.Address // Creator of realm
	ProblemId            int         // Counter for problems so can be registered in an avl.Tree
	DAO                  avl.Tree    // List of addresses that conform those that can edit everything here
	DAOsize              int         // This value must be set in the beginning of the ream
)

const (
	ErrNoProblemId    = "No problem with given Id"
	ErrNotDAOMember   = "This address is not from a DAO member"
	ErrNotDAOSize     = "This list doesn't have enough members for the new DAO"
	LeaderboardFactor = 10_000_000_000
)

func init() {
	creator := std.GetOrigCaller()
	owner = creator
	DAOsize = 1
	ProblemId = 1
	DAO = avl.Tree{}
	DAO.Set(creator.String(), true)
}

func Render(path string) string {
	return "Shiken"
}
