;;; #######################
;;; RULES
;;; #######################

;;; #######################
;;; CLOSED NEIGHBOURS
;;; #######################
;;; Keep track of closed neighbours

;;; Return 1 if neighbour is on the board, else 0
(deffunction inRangeCount (?x ?y ?s)
    (if (and (>= ?x 0) (< ?x ?s) (>= ?y 0) (< ?y ?s)) then 1 else 0)
)

;;; Initialize all tiles with its closed neighbours' count
(defrule init-closed
    (declare (salience 30))
    (tile (x ?x) (y ?y) (value ?))
    (board-size ?s)
    =>
    (assert 
        (closedNeighbours (x ?x) (y ?y) (count 
                (+ (inRangeCount ?x (- ?y 1) ?s)
                    (inRangeCount ?x (+ ?y 1) ?s)
                    (inRangeCount (- ?x 1) ?y ?s)
                    (inRangeCount (+ ?x 1) ?y ?s)
                    (inRangeCount (+ ?x 1) (- ?y 1) ?s)
                    (inRangeCount (+ ?x 1) (+ ?y 1) ?s)
                    (inRangeCount (- ?x 1) (- ?y 1) ?s)
                    (inRangeCount (- ?x 1) (+ ?y 1) ?s))
    )))
)

;;; #######################
;;; OPEN TILE (DISCOVER)
;;; #######################
;;; Open tiles that surround clicked tile

;;; Return True if neighbour is on the board, else False
(deffunction inRange (?x ?y ?s)
    (= (if (and (>= ?x 0) (< ?x ?s) (>= ?y 0) (< ?y ?s)) then 1 else 0) 1)
)

;;; Open tile that has been clicked
;;; Inherits justopen value
(defrule open-tile
    (declare (salience 20))
    (clicked ?x ?y)
    (justopen ?x ?y ?z)
    (board-size ?s)
    =>
    (and (inRange ?x (- ?y 1) ?s) (
        and (assert (opened ?x (- ?y 1)))
        (assert (justopen ?x (- ?y 1) ?z))
    ))
    (and (inRange ?x (+ ?y 1) ?s) (
        and (assert (opened ?x (+ ?y 1)))
        (assert (justopen ?x (+ ?y 1) ?z))
    ))
    (and (inRange (- ?x 1) ?y ?s) (
        and (assert (opened (- ?x 1) ?y))
        (assert (justopen (- ?x 1) ?y ?z))
    ))
    (and (inRange (+ ?x 1) ?y ?s) (
        and (assert (opened (+ ?x 1) ?y))
        (assert (justopen (+ ?x 1) ?y ?z))
    ))
    (and (inRange (+ ?x 1) (- ?y 1) ?s) (
        and (assert (opened (+ ?x 1) (- ?y 1)))
        (assert (justopen (+ ?x 1) (- ?y 1) ?z))
    ))    
    (and (inRange (+ ?x 1) (+ ?y 1) ?s) (
        and (assert (opened (+ ?x 1) (+ ?y 1)))
        (assert (justopen (+ ?x 1) (+ ?y 1) ?z))
    ))
    (and (inRange (- ?x 1) (- ?y 1) ?s) (
        and (assert (opened (- ?x 1) (- ?y 1)))
        (assert (justopen (- ?x 1) (- ?y 1) ?z))
    ))
    (and (inRange (- ?x 1) (+ ?y 1) ?s) (
        and (assert (opened (- ?x 1) (+ ?y 1)))
        (assert (justopen (- ?x 1) (+ ?y 1) ?z))
    ))
)
