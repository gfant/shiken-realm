package shiken

import (
	"std"
	"strconv"

	avl "gno.land/p/demo/avl"

	shiken_support "gno.land/p/dev/shiken_support"
)

var (
	Problems     avl.Tree    // Id -> Problem
	Leaderboards avl.Tree    // Id -> Avl.Tree{Address -> Score}
	Account      avl.Tree    // Address -> Data
	owner        std.Address // Creator of realm
	ProblemId    int         // Counter for problems so can be registered in an avl.Tree
	DAO          avl.Tree    // List of addresses that conform those that can edit everything here
	DAOsize      int         // This value must be set in the beginning of the ream
)

const (
	ErrNoProblemId  = "No problem with given Id"
	ErrNotDAOMember = "This address is not from a DAO member"
	ErrNotDAOSize   = "This list doesn't have enough members for the new DAO"
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

// Adding new problem to the list
func AddNewProblem(title, statement, examples string) {
	caller := std.GetOrigCaller()
	verifyDAO(caller)
	newProblem := new(shiken_support.Problem)
	newProblem.FillProblem(title, statement, examples)
	id := strconv.Itoa(ProblemId)
	Problems.Set(id, newProblem)
	// For later purposes
	Leaderboards.Set(id, new(avl.Tree))
	ProblemId++
}

// Adding score of an user
func AddNewScore(address std.Address, problemId, score int, tests, hashProof string) {
	newScore := new(shiken_support.Score)
	newScore.FillScore(address, problemId, score, tests, hashProof)
	problemIdString := strconv.Itoa(problemId)
	scoresInterface, ok := Leaderboards.Get(problemIdString)
	if !ok {
		panic(ErrNoProblemId)
	}
	scores := scoresInterface.(*avl.Tree)
	addr := address.String()
	scores.Set(addr, newScore)
	Leaderboards.Set(problemIdString, scores)
}

func RenderScores(id int) string {
	idString := strconv.Itoa(id)
	// Tree -> {problemId -> Tree{Address -> score}}
	lbInterface, ok := Leaderboards.Get(idString)
	if !ok {
		panic(ErrNoProblemId)
	}
	lb := lbInterface.(avl.Tree)
	output := shiken_support.ReadScores(lb)
	return output
}

func RenderProblems() string {
	output := shiken_support.ReadProblems(Problems)
	return output
}

func RenderProblem(problemId int) string {
	idString := strconv.Itoa(problemId)
	problemInterface, ok := Problems.Get(idString)
	if !ok {
		panic(ErrNoProblemId)
	}
	problem := problemInterface.(*shiken_support.Problem)
	output := problem.ReadProblem()
	return output
}

func verifyDAO(caller std.Address) bool {
	_, ok := DAO.Get(caller.String())
	if !ok {
		panic(ErrNotDAOMember)
	}
	return true
}
