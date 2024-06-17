package shiken_support

import (
	ufmt "gno.land/p/demo/ufmt"
)

type Problem struct {
	Title     string
	Statement string
	Examples  string
}

func (p *Problem) FillProblem(title, statement, examples string) {
	if title != "" {
		p.Title = title
	}
	if statement != "" {
		p.Statement = statement
	}
	if examples != "" {
		p.Examples = examples
	}
}

func (p *Problem) ReadProblem() string {
	var output string
	output += ufmt.Sprintf(`"Title":"%s",`, p.Title)
	output += ufmt.Sprintf(`"Statement":"%s",`, p.Statement)
	output += ufmt.Sprintf(`"Examples":"%s"`, p.Examples)
	output = "{" + output + "}"
	return output
}
