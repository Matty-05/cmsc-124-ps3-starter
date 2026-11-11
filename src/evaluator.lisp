;;;; evaluator.lisp -- Part 2. Write the eight functions below.
;;;;
;;;; The toy language is a Lisp-1. One namespace holds both variables and
;;;; functions, so a variable bound to a closure is callable in operator
;;;; position and (f 1) works with no FUNCALL. The CLISP hosting this file is a
;;;; Lisp-2, which is why the host needs FUNCALL and #' where the toy language
;;;; needs neither. ANALYSIS.md asks you about that difference.
;;;;
;;;; An environment is an association list: ((name . value) (name . value) ...).
;;;; The grader scores E1 to E4 separately, so finish them in order and keep
;;;; every group you get right.
;;;;
;;;; The grammar, in full:
;;;;
;;;;   expr := number
;;;;         | symbol
;;;;         | (+ expr expr) | (- expr expr) | (* expr expr)
;;;;         | (let ((name expr) ...) body)
;;;;         | (lambda (name ...) body)
;;;;         | (operator-expr argument-expr ...)

;;; E1 -- numbers and symbols.

(defun lookup (name env)
  "The value NAME is bound to in ENV.

The first match wins, so an inner binding shadows an outer one that shares its
name. Signal an error when NAME is not bound at all."
  (let ((pair (assoc name env)))
    (if pair
        (cdr pair)
        (error "Unbound symbol: ~S" name))))

;;; E2 -- prefix arithmetic.

(defun eval-operands (exprs env)
  "Every expression in EXPRS, evaluated in the same ENV, as a list.

MAPCAR and a LAMBDA do this in one line. Watch the arity: EVAL-EXPR takes two
arguments and MAPCAR hands its function one."
  (mapcar (lambda (expr) (eval-expr expr env)) exprs))

(defun apply-op (op values)
  "Apply the arithmetic operator OP to the two numbers in VALUES.

OP is the symbol +, -, or *. Signal an error for anything else."
  (if (member op '(+ - *))
      (funcall op (first values) (second values))
      (error "Unknown arithmetic operator: ~S" op)))

;;; E3 -- let.

(defun extend-env (params args env)
  "ENV with PARAMS bound to ARGS in front of it.

MAPCAR takes two lists and #'CONS pairs them. Build a new list. Do not modify
ENV, because the caller keeps using it after the extension goes out of scope."
  (append (mapcar #'cons params args) env))

(defun eval-let (expr env)
  "Evaluate (let ((name init) ...) body).

Every init is evaluated in ENV before any name is bound, so the bindings happen
in parallel and an init cannot see a name the same LET introduces."
  (let* ((bindings (second expr))
         (params (mapcar #'first bindings))
         (args (eval-operands (mapcar #'second bindings) env)))
    (eval-expr (third expr) (extend-env params args env))))

;;; E4 -- lambda and application.

(defun make-closure (params body env)
  "A closure over ENV.

Return the list (:closure params body env). ENV is the environment the lambda
was written in, not the one it will later be called from. Saving the wrong one
is what makes the difference between 3 and 101 in the case the manual walks
through."
  (list :closure params body env))

(defun apply-closure (closure args)
  "Run CLOSURE on ARGS.

The parameters join the environment the closure captured. Signal an error when
CLOSURE is not a closure, and when the argument count does not match."
  (unless (and (consp closure) (eq (first closure) :closure))
    (error "Not a closure: ~S" closure))
  (let ((params (second closure))
        (body (third closure))
        (saved-env (fourth closure)))
    (unless (= (length params) (length args))
      (error "Closure expected ~D arguments, got ~D"
             (length params) (length args)))
    (eval-expr body (extend-env params args saved-env))))

;;; The dispatcher.

(defun eval-expr (expr env)
  "The value of EXPR in ENV.

Order the branches with care. NIL is a symbol as well as the empty list, and a
number is not a cons, so the atom tests come before the list tests."
  (cond
    ((numberp expr) expr)
    ((symbolp expr) (lookup expr env))
    ((and (consp expr) (member (first expr) '(+ - *)))
     (apply-op (first expr) (eval-operands (rest expr) env)))
    ((and (consp expr) (eq (first expr) 'let))
     (eval-let expr env))
    ((and (consp expr) (eq (first expr) 'lambda))
     (make-closure (second expr) (third expr) env))
    ((consp expr)
     (apply-closure (eval-expr (first expr) env)
                    (eval-operands (rest expr) env)))
    (t (error "Invalid expression: ~S" expr))))
