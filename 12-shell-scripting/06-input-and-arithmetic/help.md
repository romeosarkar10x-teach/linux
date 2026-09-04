# 12/06 — help

## "The prompt does not appear when I redirect output"

Then it is going to stdout, not to the terminal. Compare `echo -n "n: "; read v`
with `read -p "n: " v` under `> /dev/null`.

## "My last variable has too much in it"

That is the rule, not a bug: the final name in a `read` gets every remaining
field, separators included. Add another name, or split with the right `IFS`.

## "The number in my file is not the number in my script"

Print it with `printf '[%s]'` first — is it what you think? Then look at the
first character. If it is `0`, read the "leading zero" section of
`notes/arithmetic.txt` before doing anything else.

## "`value too great for base`"

Bash is reading your number as octal, or as a based literal. `10#` in front of it
says "this is decimal". The `$` still has to be there: `10#$v`.

## "My comparison silently does nothing"

Check the status of the `(( ))` on its own. An arithmetic error inside an `if`
condition is a false condition, not a stopped script, and the error text is on
stderr where your log is not looking.

## "I need one decimal place"

Multiply before you divide, and print with `printf '%d.%d'`. Read `bin/average-2`
line by line. If you need three decimals, or real division, use `awk` — there is
no `bc` here.

## "My loop over the array skips things"

Print `${!a[@]}`. If the indices are not `0 1 2 ...`, your `for ((i=0;...))` loop
is wrong by construction. Loop over `"${a[@]}"`.

## "Everything in my associative array is overwriting element zero"

`declare -A` before the first assignment. Without it you have an indexed array,
and every string key is arithmetic for 0.

## "How do I read a file into an array?"

`mapfile -t arr < file` — one line per element, newlines stripped. Not
`arr=( $(cat file) )`, which splits on every space.
