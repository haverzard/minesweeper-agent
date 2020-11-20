;;; #######################
;;; RULES
;;; #######################

;;; #######################
;;; OPEN TILE (DISCOVER)
;;; #######################

;;; Open tiles that are not in the right-corner
(defrule open-1
    (declare (salience 20))
    (clicked ?x ?y)
    (board-size ?s)
    (test (!= ?x (- ?s 1)))
    =>
    (assert (opened (+ ?x 1) ?y)))

;;; Open tiles that are not in the left-corner
(defrule open-2
    (declare (salience 20))
    (clicked ?x ?y)
    (board-size ?s)
    (test (!= ?x 0))
    =>
    (assert (opened (- ?x 1) ?y)))

;;; Open tiles that are not in the top-corner
(defrule open-3
    (declare (salience 20))
    (clicked ?x ?y)
    (board-size ?s)
    (test (!= ?y (- ?s 1)))
    =>
    (assert (opened ?x (+ ?y 1))))

;;; Open tiles that are not in the bottom-corner
(defrule open-4
    (declare (salience 20))
    (clicked ?x ?y)
    (board-size ?s)
    (test (!= ?y 0))
    =>
    (assert (opened ?x (- ?y 1))))

;;; Open tiles that are not in the top-left-corner
(defrule open-5
    (declare (salience 20))
    (clicked ?x ?y)
    (board-size ?s)
    (test (!= ?x 0))
    (test (!= ?y (- ?s 1)))
    =>
    (assert (opened (- ?x 1) (+ ?y 1))))

;;; Open tiles that are not in the top-right-corner
(defrule open-6
    (declare (salience 20))
    (clicked ?x ?y)
    (board-size ?s)
    (test (!= ?x (- ?s 1)))
    (test (!= ?y (- ?s 1)))
    =>
    (assert (opened (+ ?x 1) (+ ?y 1))))

;;; Open tiles that are not in the bottom-left-corner
(defrule open-7
    (declare (salience 20))
    (clicked ?x ?y)
    (board-size ?s)
    (test (!= ?x 0))
    (test (!= ?y 0))
    =>
    (assert (opened (- ?x 1) (- ?y 1))))

;;; Open tiles that are not in the bottom-left-corner
(defrule open-8
    (declare (salience 20))
    (clicked ?x ?y)
    (board-size ?s)
    (test (!= ?x (- ?s 1)))
    (test (!= ?y 0))
    =>
    (assert (opened (+ ?x 1) (- ?y 1))))
