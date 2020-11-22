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


;;; Print function
(deffunction print-im (?s)
    (bind ?i 0)
    (while (< ?i ?s) do 
        (bind ?j (- ?s 1))
        (while (>= ?j 0) do
            (if (any-factp ((?f opened)) (and (= ?f:x ?i) (= ?f:y ?j)))
                then
                (printout t "A ")
                else
                (printout t "X ")
            )
            (bind ?j (- ?j 1))
        ?j)
        (printout t crlf)
        (bind ?i (+ ?i 1))
    ?i)
)

;;; Print
(defrule print
    (declare (salience 100))
    (board-size ?s)
    =>
    (print-im ?s)
)