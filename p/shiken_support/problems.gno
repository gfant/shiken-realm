package shiken_support

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

func (p *Problem) FillProblem(title, statement, examples string) {
	if title != "" {
		p.Title = title
	}
	if statement != "" {
		p.Statement = statement
	}
	if examples != "" {
		examplesArr := strings.Split(examples, ",")
		p.Examples = examplesArr
	}
}

func (p *Problem) ReadProblem() string {
	var output string
	output += ufmt.Sprintf(`"Title":"%s",`, p.Title)
	output += ufmt.Sprintf(`"Statement":"%s",`, p.Statement)
	output += ufmt.Sprintf(`"Examples":[`)
	for _, ex := range p.Examples {
		output += `"` + ex + `"` + `,`
	}
	output = output[0 : len(output)-1] // Removing last comma
	output += "]"
	output = "{" + output + "}"
	return output
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
