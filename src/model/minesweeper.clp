;;; #######################
;;; ALGORITHM
;;; #######################


;;; Start
(defrule init
    (tile (x 0) (y 0) (value 0))
    (not (no-start))
    =>
    (assert (clicked (x 0) (y 0)))
    (assert (open-condition (x 0) (y 0) (cond 1)))
    (assert (nobomb 0 0))
    (assert (n-iteration 0))
)

;;; Error Detection
(defrule no-init
    (declare (salience 100))
    (or
        (not (tile (x 0) (y 0) (value 0)))
        (bomb 0 0)
    )
    =>
    (printout t "ERROR: INVALID GAMESTATE" crlf)
    (printout t "ERROR: (0, 0) must have 0 as its value" crlf)
    (printout t "ERROR: (0, 0) must have no bomb" crlf)
    (assert (no-start))
)

;;; Error Detection
(defrule wrong-bomb
    (declare (salience 100))
    (flagged (x ?x) (y ?y))
    (not (bomb ?x ?y))
    =>
    (printout t "WRONG PREDICTION :(" crlf)
    (exit)
)

;;; Print function
(deffunction print-im (?s)
    (bind ?i (- ?s 1))
    (while (>= ?i 0) do 
        (bind ?j 0)
        (while (< ?j (- ?s 1)) do
            (if (any-factp ((?f clicked)) (and (= ?f:x ?j) (= ?f:y ?i)))
                then
                (if (any-factp ((?f2 flagged)) (and (= ?f2:x ?j) (= ?f2:y ?i)))
                    then
                    (printout t "F ")
                    else
                    (do-for-fact ((?f3 tile)) (and (= ?f3:x ?j) (= ?f3:y ?i))
                        (printout t ?f3:value " ")
                    )
                )
                else
                (printout t "X ")
            )
            (bind ?j (+ ?j 1))
        ?j)
        (printout t crlf)
        (bind ?i (- ?i 1))
    ?i)
)

;;; Print
(defrule print
    (declare (salience 100))
    (board-size ?s)
    (n-iteration ?i)
    =>
    (printout t "ITERATION " ?i crlf)
    (print-im ?s)
)