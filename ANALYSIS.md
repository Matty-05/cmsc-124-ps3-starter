# Environments and the Toy Evaluator

## Following a lexical closure

Consider `(let ((x 2)) (let ((f (lambda (y) (+ x y)))) (let ((x 100)) (f 1))))`. The outer `let` evaluates its initializer in the empty environment, then `extend-env` puts `(x . 2)` at the front. The next `let` creates `f`; its lambda branch saves the current environment, so `f` contains the body `(+ x y)` and the environment `((x . 2))`. The innermost `let` extends its own environment with `(x . 100)`, ahead of `f` and the earlier `x`. Evaluating `(f 1)` looks up `f` there, evaluates the argument to `1`, then applies the closure. `apply-closure` extends the saved environment with `(y . 1)`, producing `((y . 1) (x . 2))`. In the body, `x` resolves to `2`, so the result is `3`.

## Where the environment is captured

The lambda branch is [src/evaluator.lisp:110–111](src/evaluator.lisp#L110):

```lisp
((and (consp expr) (eq (first expr) 'lambda))
 (make-closure (second expr) (third expr) env))
```

At this point in the trace, `env` is `((x . 2))`. `make-closure` stores that list alongside the parameters and body. Later, `apply-closure` uses the stored environment on line 94. `extend-env` builds new pairs with `append`, so calling the closure does not change the caller’s environment or the environment saved in the closure.

## What dynamic scope would do

If `apply-closure` extended the caller’s environment instead, `x` would resolve to the innermost binding, `100`, and the expression would return `101`. That is dynamic scope: the binding visible at the call site controls the lookup. Common Lisp special variables declared with `defvar` have dynamic binding behavior. Our prediction table records P10 as `30` and P16 as `6`; those results are consistent with the binding rules we reasoned about for the manual’s cases. The evaluator’s lexical closure keeps the definition environment available after execution has moved into a different nested `let`.

## One namespace in the toy language

The final application branch evaluates the operator expression with `eval-expr` (lines 112–114), just as it evaluates a variable in any other position. Therefore a function value stored in `f` can be called with `(f 1)`, and a lambda expression can appear directly in operator position. The toy language is a Lisp-1: variables and callable values share one namespace. CLISP is a Lisp-2, with separate variable and function namespaces. In CLISP, calling a function value held in a variable requires `funcall`; referring to a named function as a value uses `#'`. The host-side code shows these distinctions too: line 41 gives `mapcar` a `lambda`, while line 58 passes `#'cons` as a function argument.
