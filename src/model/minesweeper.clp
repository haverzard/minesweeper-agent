;;; #######################
;;; ALGORITHM
;;; #######################


;;; Start
(defrule init
    =>
    (assert (clicked (x 0) (y 9)))
    (assert (open-condition (x 0) (y 9) (cond 1)))
    (assert (nobomb 0 9))
)
