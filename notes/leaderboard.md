# About leaderboards

The leaderboards will store the score by registering as key the value

		`score * (10000000000000000) + counter`

where `counter` is a number that will only increase if the result is good enough
to be included in the leaderboard. Because the leaderboard will be stored in
ascendent order, the increment of the counter is precisely a good way to keep 
the results with a unique id.

Apart from this, the InvertedLeaderboard will have as key the address of the 
applicant and the value will be the key that stores the result of that address
on the Leaderboard.
An example:

`g1abc123` gets the result `153` in problem with Id `1`. This will make
```
Leaderboard:

Leaderboard -> 1-> 1530000000000000001 -> {
                                            address: g1abc123,
                                            tests: "...",
                                          }

InversedLeaderBoard:

InversedLeaderBoard -> 1 -> g1abc123 -> 1530000000000000001
```

If the user gets a better score, let's say 99, the InversedLeaderBoard will give us the previous id (`1530000000000000001`) and we will delete the score from the Leaderboard structure, to later add the new updated value

```
Leaderboard:

Leaderboard -> 1 -> 990000000000000002 -> {
                                            address: g1abc123,
                                            tests: "...",
                                           }

InversedLeaderBoard:

InversedLeaderBoard -> 1 -> g1abc123 -> 990000000000000002
```