;;; #######################
;;; ALGORITHM
;;; #######################


;;; Start
(defrule init
    =>
    (assert (clicked 0 9))
    (assert (justopen 0 9 1))
    (assert (nobomb 0 9))
)