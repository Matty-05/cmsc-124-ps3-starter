# Environments and the Toy Evaluator

## Following a lexical closure

Consider `(let ((x 2)) (let ((f (lambda (y) (+ x y)))) (let ((x 100)) (f 1))))`. The outer `let` binds `x` to `2` in the empty environment. The next `let` creates `f`, whose closure stores body `(+ x y)` and environment `((x . 2))`. The innermost `let` extends its environment with `(x . 100)`, ahead of `f` and the earlier `x`. Evaluating `(f 1)` looks up `f` there, evaluates the argument to `1`, then applies the closure. `apply-closure` extends the saved environment with `(y . 1)`, producing `((y . 1) (x . 2))`. In the body, `x` resolves to `2`, so the result is `3`.

## Where the environment is captured

The lambda branch of `eval-expr` passes its current `env` to `make-closure`:

```lisp
((and (consp expr) (eq (first expr) 'lambda))
 (make-closure (second expr) (third expr) env))
```

In this trace, that environment is `((x . 2))`. `make-closure` stores it with the parameters and body. Later, `apply-closure` extends this saved environment with the arguments before evaluating the body. `extend-env` uses `(mapcar #'cons params args)` to make the new binding pairs, then `append` places those pairs before the existing environment. This builds a new outer list and leaves the caller's environment intact.

## What dynamic scope would do

If `apply-closure` extended the caller's environment instead, `x` would resolve to the innermost binding, `100`, and the expression would return `101`. That is dynamic scope, as with Common Lisp special variables. P10 declares `*ps3-rate*` special, so `ps3-scale` sees its temporary rebinding and returns `30`. In P16, `factor` is lexical and captured by the lambda; rebinding it outside does not change the captured value, so the result is `6`.

## One namespace in the toy language

In the toy evaluator, the application branch of `eval-expr` evaluates the operator expression with `eval-expr` too. Thus `(f 1)` looks up `f` as a variable, gets its closure, and calls it. In Common Lisp, `(f 1)` looks for `f` in the function namespace; a closure stored only as the variable value of `f` is not found there, so that call fails. `funcall` lets Common Lisp call a function object held in a variable. Our host-side `apply-op` uses `(funcall op ...)` for this reason. The toy language is a Lisp-1, where variables and callable values share one namespace; Common Lisp is a Lisp-2, with separate variable and function namespaces. A named Common Lisp function used as a value needs `#'`. Our evaluator code uses `lambda` with `mapcar` and passes `#'cons` as a function argument in `extend-env`.
