package shiken_problems

import (
	"strings"

	avl "gno.land/p/demo/avl"
	ufmt "gno.land/p/demo/ufmt"
)

type Problem struct {
	Title     string
	Statement string
	Examples  []string
}

func (p *Problem) InputInformation(title, statement, examples string) {
	p.setTitle(title)
	p.setStatement(statement)
	p.setExamples(examples)
}

func (p *Problem) setTitle(title string) {
	if title != "" {
		p.Title = title
	}
}

func (p *Problem) setStatement(statement string) {
	if statement != "" {
		p.Statement = statement
	}
}

func (p *Problem) setExamples(examples string) {
	if examples != "" {
		p.Examples = strings.Split(examples, ",")
	}
}

func (p *Problem) ReadProblem() string {
	output := ufmt.Sprintf(`"Title":"%s",`, p.Title)
	output += ufmt.Sprintf(`"Statement":"%s",`, p.Statement)
	output += ufmt.Sprintf(`"Examples":%s`, renderExamples(p.Examples))
	return "{" + output + "}"
}

func renderExamples(examples []string) string {
	var output string
	for _, ex := range examples {
		output += `"` + ex + `"` + `,`
	}
	return "[" + output[0:len(output)-1] + "]" // Removing last comma
}

func ReadProblems(tree avl.Tree) string {
	json := "{"
	tree.Iterate("", "", func(network string, value interface{}) bool {
		problemInterface := value.(*Problem)
		problem := problemInterface.ReadProblem()
		json += ufmt.Sprintf(`"%s":%s,`, network, problem)
		return false
	})
	json = json[0 : len(json)-1]
	json += "}"
	return json
}
