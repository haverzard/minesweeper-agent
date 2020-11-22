;;; #######################
;;; RULES
;;; #######################

;;; #######################
;;; HELPER FUNCTIONS
;;; #######################

;;; Return True if neighbour is on the board, else False
(deffunction inRange (?x ?y ?s)
    (= (if (and (>= ?x 0) (< ?x ?s) (>= ?y 0) (< ?y ?s)) then 1 else 0) 1)
)

;;; Return 1 if neighbour is on the board, else 0
(deffunction inRangeCount (?x ?y ?s)
    (if (and (>= ?x 0) (< ?x ?s) (>= ?y 0) (< ?y ?s)) then 1 else 0)
)

;;; #######################
;;; BOMB NEIGHBOURS
;;; #######################
;;; Set bomb neighbours' count with tile's value
(defrule init-bomb-counts
    (declare (salience 30))
    (tile (x ?x) (y ?y) (value ?v))
    (board-size ?s)
    =>
    (assert (bombNeighbours (x ?x) (y ?y) (count ?v)))
)

;;; Decrease the bombs' count for all neighbours of the flagged tile
(defrule bomb-tile-decrement
    (declare (salience 10))
    (flagged ?x ?y)
    (board-size ?s)
    =>
    (and (inRange ?x (- ?y 1) ?s)
        (do-for-fact ((?ff bombNeighbours)) (and (= ?ff:x ?x) (= ?ff:y (- ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange ?x (+ ?y 1) ?s)
        (do-for-fact ((?ff bombNeighbours)) (and (= ?ff:x ?x) (= ?ff:y (+ ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange (- ?x 1) ?y ?s)
        (do-for-fact ((?ff bombNeighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y ?y))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange (+ ?x 1) ?y ?s)
        (do-for-fact ((?ff bombNeighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y ?y))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange (+ ?x 1) (- ?y 1) ?s)
        (do-for-fact ((?ff bombNeighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (- ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange (+ ?x 1) (+ ?y 1) ?s)
        (do-for-fact ((?ff bombNeighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (+ ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange (- ?x 1) (- ?y 1) ?s)
        (do-for-fact ((?ff bombNeighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (- ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange (- ?x 1) (+ ?y 1) ?s)
        (do-for-fact ((?ff bombNeighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (+ ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
)

;;; #######################
;;; CLOSED NEIGHBOURS
;;; #######################
;;; Keep track of closed neighbours
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

;;; Decrease the closed neighbour' count for all neighbours of the clicked/flagged tile
(defrule closed-tile-decrement
    (declare (salience 20))
    (clicked (x ?x) (y ?y))
    (board-size ?s)
    =>
    (and (inRange ?x (- ?y 1) ?s)
        (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x ?x) (= ?ff:y (- ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange ?x (+ ?y 1) ?s)
        (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x ?x) (= ?ff:y (+ ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange (- ?x 1) ?y ?s)
        (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y ?y))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange (+ ?x 1) ?y ?s)
        (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y ?y))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange (+ ?x 1) (- ?y 1) ?s)
        (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (- ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange (+ ?x 1) (+ ?y 1) ?s)
        (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (+ ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange (- ?x 1) (- ?y 1) ?s)
        (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (- ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (inRange (- ?x 1) (+ ?y 1) ?s)
        (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (+ ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
)

;;; #######################
;;; OPEN TILE (DISCOVER)
;;; #######################
;;; Open tiles that surround clicked tile

;;; Open tile that has been clicked
;;; Inherits open-condition value
(defrule open-tile
    (declare (salience 20))
    (clicked (x ?x) (y ?y))
    (open-condition (x ?x) (y ?y) (cond ?z))
    (board-size ?s)
    =>
    (and (inRange ?x (- ?y 1) ?s) (
        and (assert (opened (x ?x) (y (- ?y 1))))
        (assert (open-condition (x ?x) (y (- ?y 1)) (cond ?z)))
    ))
    (and (inRange ?x (+ ?y 1) ?s) (
        and (assert (opened (x ?x) (y (+ ?y 1))))
        (assert (open-condition (x ?x) (y (+ ?y 1)) (cond ?z)))
    ))
    (and (inRange (- ?x 1) ?y ?s) (
        and (assert (opened (x (- ?x 1)) (y ?y)))
        (assert (open-condition (x (- ?x 1)) (y ?y) (cond ?z)))
    ))
    (and (inRange (+ ?x 1) ?y ?s) (
        and (assert (opened (x (+ ?x 1)) (y ?y)))
        (assert (open-condition (x (+ ?x 1)) (y ?y) (cond ?z)))
    ))
    (and (inRange (+ ?x 1) (- ?y 1) ?s) (
        and (assert (opened (x (+ ?x 1)) (y (- ?y 1))))
        (assert (open-condition (x (+ ?x 1)) (y (- ?y 1)) (cond ?z)))
    ))    
    (and (inRange (+ ?x 1) (+ ?y 1) ?s) (
        and (assert (opened (x (+ ?x 1)) (y (+ ?y 1))))
        (assert (open-condition (x (+ ?x 1)) (y (+ ?y 1)) (cond ?z)))
    ))
    (and (inRange (- ?x 1) (- ?y 1) ?s) (
        and (assert (opened (x (- ?x 1)) (y (- ?y 1))))
        (assert (open-condition (x (- ?x 1)) (y (- ?y 1)) (cond ?z)))
    ))
    (and (inRange (- ?x 1) (+ ?y 1) ?s) (
        and (assert (opened (x (- ?x 1)) (y (+ ?y 1))))
        (assert (open-condition (x (- ?x 1)) (y (+ ?y 1)) (cond ?z)))
    ))
)

;;; #######################
;;; NOBOMB & BOMB
;;; #######################

;;; Numbered tile should not have any bomb
(defrule nobomb-1
    (declare (salience 10))
    (tile (x ?x) (y ?y) (value ?value&:(!= ?value 0)))
    (open-condition (x ?x) (y ?y) (cond ?a&:(= 1 ?a)))
    (opened (x ?x) (y ?y))
    =>
    (assert (nobomb ?x ?y))
    (assert (clicked (x ?x) (y ?y)))
    (assert (open-condition (x ?x) (y ?y) (cond 0))))

;;; No bomb tile and no numbered tile should discover other tiles
(defrule nobomb-2
    (declare (salience 15))
    (tile (x ?x) (y ?y) (value ?value&:(= ?value 0)))
    (not (flagged ?x ?y))
    (not (open-condition (x ?x) (y ?y) (cond 0)))
    (opened (x ?x) (y ?y))
    =>
    (assert (nobomb ?x ?y))
    (assert (clicked (x ?x) (y ?y))))

;;; 
(deffunction discover-free (?x ?y ?s)
    (or
        (if (inRange ?x (+ ?y 1) ?s)
            then
            (do-for-fact ((?ff open-condition)) (and (= ?ff:x ?x) (= ?ff:y (+ ?y 1)))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (assert (opened (x ?ff:x) (y ?ff:y)))
                    (modify ?ff (cond 0))
                    (assert (opened-nobomb ?ff:x ?ff:y))
                )
            )
        )
        (if (inRange ?x (- ?y 1) ?s)
            then
            (do-for-fact ((?ff open-condition)) (and (= ?ff:x ?x) (= ?ff:y (- ?y 1)))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (assert (opened (x ?ff:x) (y ?ff:y)))
                    (modify ?ff (cond 0))
                    (assert (opened-nobomb ?ff:x ?ff:y))
                )
            )
        )
        (if (inRange (- ?x 1) ?y ?s)
            then
            (do-for-fact ((?ff open-condition)) (and (= ?ff:x (- ?x 1)) (= ?ff:y ?y))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (assert (opened (x ?ff:x) (y ?ff:y)))
                    (modify ?ff (cond 0))
                    (assert (opened-nobomb ?ff:x ?ff:y))
                )
            )
        )
        (if (inRange (+ ?x 1) ?y ?s)
            then
            (do-for-fact ((?ff open-condition)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y ?y))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (assert (opened (x ?ff:x) (y ?ff:y)))
                    (modify ?ff (cond 0))
                    (assert (opened-nobomb ?ff:x ?ff:y))
                )
            )
        )
        (if (inRange (- ?x 1) (- ?y 1) ?s)
            then
            (do-for-fact ((?ff open-condition)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (- ?y 1)))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (assert (opened (x ?ff:x) (y ?ff:y)))
                    (modify ?ff (cond 0))
                    (assert (opened-nobomb ?ff:x ?ff:y))
                )
            )
        )
        (if (inRange (- ?x 1) (+ ?y 1) ?s)
            then
            (do-for-fact ((?ff open-condition)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (+ ?y 1)))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (assert (opened (x ?ff:x) (y ?ff:y)))
                    (modify ?ff (cond 0))
                    (assert (opened-nobomb ?ff:x ?ff:y))
                )
            )
        )
        (if (inRange (+ ?x 1) (- ?y 1) ?s)
            then
            (do-for-fact ((?ff open-condition)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (- ?y 1)))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (assert (opened (x ?ff:x) (y ?ff:y)))
                    (modify ?ff (cond 0))
                    (assert (opened-nobomb ?ff:x ?ff:y))
                )
            )
        )
        (if (inRange (+ ?x 1) (+ ?y 1) ?s)
            then
            (do-for-fact ((?ff open-condition)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (+ ?y 1)))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (assert (opened (x ?ff:x) (y ?ff:y)))
                    (modify ?ff (cond 0))
                    (assert (opened-nobomb ?ff:x ?ff:y))
                )
            )
        )
    )
)

;;; Open nobomb tile for discovery
(defrule open-nobomb
    (tile (x ?x) (y ?y) (value ?))
    (bombNeighbours (x ?x) (y ?y) (count 0))
    (clicked (x ?x) (y ?y))
    (board-size ?s)
    =>
    (discover-free ?x ?y ?s))


;;; Flag all closed neighbour tiles as bombs
(deffunction flaggedBombs (?x ?y ?s)
    (or
        (if (inRange ?x (+ ?y 1) ?s)
            then
            (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x ?x) (= ?ff:y (+ ?y 1)))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (and
                        (assert (flagged ?ff:x ?ff:y))
                        (assert (clicked (x ?ff:x) (y ?ff:y)))
                        (assert (bomb ?ff:x ?ff:y))
                    )
                )
            )
        )
        (if (inRange ?x (- ?y 1) ?s)
            then
            (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x ?x) (= ?ff:y (- ?y 1)))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (and
                        (assert (flagged ?ff:x ?ff:y))
                        (assert (clicked (x ?ff:x) (y ?ff:y)))
                        (assert (bomb ?ff:x ?ff:y))
                    )
                )
            )
        )
        (if (inRange (- ?x 1) ?y ?s)
            then
            (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y ?y))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (and
                        (assert (flagged ?ff:x ?ff:y))
                        (assert (clicked (x ?ff:x) (y ?ff:y)))
                        (assert (bomb ?ff:x ?ff:y))
                    )
                )
            )
        )
        (if (inRange (+ ?x 1) ?y ?s)
            then
            (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y ?y))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (and
                        (assert (flagged ?ff:x ?ff:y))
                        (assert (clicked (x ?ff:x) (y ?ff:y)))
                        (assert (bomb ?ff:x ?ff:y))
                    )
                )
            )
        )
        (if (inRange (- ?x 1) (- ?y 1) ?s)
            then
            (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (- ?y 1)))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (and
                        (assert (flagged ?ff:x ?ff:y))
                        (assert (clicked (x ?ff:x) (y ?ff:y)))
                        (assert (bomb ?ff:x ?ff:y))
                    )
                )
            )
        )
        (if (inRange (- ?x 1) (+ ?y 1) ?s)
            then
            (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (+ ?y 1)))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (and
                        (assert (flagged ?ff:x ?ff:y))
                        (assert (clicked (x ?ff:x) (y ?ff:y)))
                        (assert (bomb ?ff:x ?ff:y))
                    )
                )
            )
        )
        (if (inRange (+ ?x 1) (- ?y 1) ?s)
            then
            (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (- ?y 1)))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (and
                        (assert (flagged ?ff:x ?ff:y))
                        (assert (clicked (x ?ff:x) (y ?ff:y)))
                        (assert (bomb ?ff:x ?ff:y))
                    )
                )
            )
        )
        (if (inRange (+ ?x 1) (+ ?y 1) ?s)
            then
            (do-for-fact ((?ff closedNeighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (+ ?y 1)))
                (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                    then
                    else
                    (and
                        (assert (flagged ?ff:x ?ff:y))
                        (assert (clicked (x ?ff:x) (y ?ff:y)))
                        (assert (bomb ?ff:x ?ff:y))
                    )
                )
            )
        )
    )
)

;;; If closed neighbours' count == bombs' count in a certain tile
;;; Flagged all closed neighbour tiles as bombs
(defrule bomb-1
    (declare (salience 5))
    (bombNeighbours (x ?x) (y ?y) (count ?bn&:(!= ?bn 0)))
    (closedNeighbours (x ?x) (y ?y) (count ?cn))
    (test (= ?cn ?bn))
    (opened (x ?x) (y ?y))
    (board-size ?s)
    =>
    (flaggedBombs ?x ?y ?s))
