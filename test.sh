
gnokey maketx call -pkgpath "gno.land/r/dev/shiken" -func "AddNewProblem" \
-gas-fee 1000000ugnot -gas-wanted 2000000 -send "" -broadcast -chainid "dev" \
-args "Revert the strings" \
-args "Create a function 'Problem' that reverses the given string." \
-args "gno->ong,dao->oad,very long sentence->ecnetnes gnol yrev" \
-remote "tcp://127.0.0.1:26657" g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5

gnokey maketx call -pkgpath "gno.land/r/dev/shiken" -func "AddNewProblem" \
-gas-fee 1000000ugnot -gas-wanted 2000000 -send "" -broadcast -chainid "dev" \
-args "Primes under n" \
-args "Create a function 'Problem' that counts the number of primes under n. (A prime is a number that its only positive divisors are 1 and itself)" \
-args "2->0,20->8,1000000->78498" \
-remote "tcp://127.0.0.1:26657" g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5

gnokey maketx call -pkgpath "gno.land/r/dev/shiken" -func "AddNewProblem" \
-gas-fee 1000000ugnot -gas-wanted 2000000 -send "" -broadcast -chainid "dev" \
-args "Remove the vowels" \
-args "Create a function 'Problem' that removes the vowels of a given string." \
-args "gnolang->gnlng,dao->d,very long sentence->vry lng sntnc" \
-remote "tcp://127.0.0.1:26657" g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5