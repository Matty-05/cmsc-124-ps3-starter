# Reasoning for the Predictions Table

Write one entry under every heading below, then commit this file together with
`predictions.tsv`, before you run a case or open `tests/expected.tsv`.

Each entry names the rule that produces the four predicted fields for that
case. One to three sentences is enough. The grader checks structure only. It
does not judge quality, and it sets no word minimum.

After you run the cases, add a short correction under each case you predicted
wrongly. Say what you predicted, what CLISP printed, and which rule you
misread. Those entries belong in the correction commits.

## P01

`* ` multiplies 2 and 3 first, then `+` adds 1 to give 7. This is an `integer`, so its length is `none`; the operator is `function` because the outer call uses `+`.

## P02

The quote keeps `(+ 1 2)` as a list instead of adding the numbers, so I wrote `(+,1,2)`. Its three elements make it a `cons` with length 3. The operator is `special-operator` because the leading quote stands for `quote`.

## P03

`nil` evaluates to itself and also means the empty list. The module gives it the kind `null` and length 0. Since the form is atomic, its operator is `none`.

## P04

`t` evaluates to itself and belongs to the `symbol` kind. A symbol has no sequence length, so I used `none` for length. The operator is also `none` because this is an atomic form.

## P05

`symbolp` asks whether `nil` is a symbol, which it is, so the answer is `t`. That answer has kind `symbol` and length `none`. The operator is `function` because `symbolp` is the outer call.

## P06

`car` receives the quoted empty list and returns `nil`. This gives kind `null` and length 0, while the operator is `function` because the expression calls `car`.

## P07

`cons` adds 1 to the front of `(2 3)`, giving `(1,2,3)`. The result is a `cons` with three elements, and the operator is `function` because the outer call is `cons`.

## P08

The empty list passes the `null` test, so `if` chooses `'empty` and returns the symbol `empty`. This gives kind `symbol` and length `none`. I classified `if` as `special-operator` because it evaluates only the selected branch.

## P09

`and` gets past 1 because it counts as true, then stops at `nil` and returns it. The result has kind `null` and length 0. I used `special-operator` for `and` following the module's CLISP classification rule.

## P10

The `defvar` declaration makes `*ps3-rate*` special, so `ps3-scale` sees the temporary value 10 during the call and returns 30. `progn` returns that last result, an `integer` with length `none`. The operator is `special-operator` because the outer form is `progn`.

## P11

Defining the function returns its name, `ps3-twice`. The name is a `symbol` with length `none`, even though it names a function. The operator is `macro` because the form starts with `defun`.

## P12

`down` stops at zero and returns the empty list, then the earlier calls add 1, 2, and 3 to the front as they return. This builds `(3,2,1)`, a `cons` with length 3; zero is never added. The outer form is `labels`, so the operator is `special-operator`.

## P13

The three input lists have lengths 2, 0, and 1, which `mapcar` collects as `(2,0,1)`. This is a `cons` with length 3. The operator is `function` because the outer call is `mapcar`.

## P14

The lambda squares each input number, and `mapcar` collects the answers as `(1,4,9)`. This list has kind `cons` and length 3. The outer call is `mapcar`, so the operator is `function`.

## P15

This expression creates a function without calling it, so I used the module's notation `#<function>`. The result has kind `function` and length `none`. The operator is `macro`, which is the assignment's classification for `lambda`.

## P16

When `f` is created, it captures the binding where `factor` is 2. The later binding to 10 does not change what `f` captured, so calling it with 3 gives 6, an `integer` with length `none`. The outer form is `let`, so the operator is `special-operator`.
