;;; #######################
;;; RULES
;;; #######################

;;; #######################
;;; HELPER FUNCTIONS
;;; #######################

;;; Return True if neighbour is on the board, else False
(deffunction in-range (?x ?y ?s)
    (= (if (and (>= ?x 0) (< ?x ?s) (>= ?y 0) (< ?y ?s)) then 1 else 0) 1)
)

;;; Return 1 if neighbour is on the board, else 0
(deffunction in-range-count (?x ?y ?s)
    (if (and (>= ?x 0) (< ?x ?s) (>= ?y 0) (< ?y ?s)) then 1 else 0)
)

;;; #######################
;;; BOMB NEIGHBOURS
;;; #######################

;;; INIT RULE
;;; Set bomb neighbours' count with tile's value
(defrule init-bomb-counts
    (declare (salience 30))
    (tile (x ?x) (y ?y) (value ?v))
    (board-size ?s)
    =>
    (assert (unidentified-bomb-neighbours (x ?x) (y ?y) (count ?v)))
)

;;; Decrease the bombs' count for all neighbours of the flagged tile
;;; Pre-conditions:
;;; - Tile has been flagged (not duplicate)
;;;
;;; Actions:
;;; - Decrease bombs' count for all neighbours of the flagged tile by 1
(defrule bomb-tile-decrement
    (declare (salience 10))
    (flagged (x ?x) (y ?y))
    (board-size ?s)
    =>
    (and (in-range ?x (- ?y 1) ?s)
        (do-for-fact ((?ff unidentified-bomb-neighbours)) (and (= ?ff:x ?x) (= ?ff:y (- ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range ?x (+ ?y 1) ?s)
        (do-for-fact ((?ff unidentified-bomb-neighbours)) (and (= ?ff:x ?x) (= ?ff:y (+ ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range (- ?x 1) ?y ?s)
        (do-for-fact ((?ff unidentified-bomb-neighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y ?y))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range (+ ?x 1) ?y ?s)
        (do-for-fact ((?ff unidentified-bomb-neighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y ?y))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range (+ ?x 1) (- ?y 1) ?s)
        (do-for-fact ((?ff unidentified-bomb-neighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (- ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range (+ ?x 1) (+ ?y 1) ?s)
        (do-for-fact ((?ff unidentified-bomb-neighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (+ ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range (- ?x 1) (- ?y 1) ?s)
        (do-for-fact ((?ff unidentified-bomb-neighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (- ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range (- ?x 1) (+ ?y 1) ?s)
        (do-for-fact ((?ff unidentified-bomb-neighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (+ ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
)

;;; #######################
;;; CLOSED NEIGHBOURS
;;; #######################
;;; Keep track of closed neighbours

;;; INIT RULE
;;; Initialize all tiles with its closed neighbours' count
(defrule init-closed
    (declare (salience 30))
    (tile (x ?x) (y ?y) (value ?))
    (board-size ?s)
    =>
    (assert 
        (closed-neighbours (x ?x) (y ?y) (count 
                (+ (in-range-count ?x (- ?y 1) ?s)
                    (in-range-count ?x (+ ?y 1) ?s)
                    (in-range-count (- ?x 1) ?y ?s)
                    (in-range-count (+ ?x 1) ?y ?s)
                    (in-range-count (+ ?x 1) (- ?y 1) ?s)
                    (in-range-count (+ ?x 1) (+ ?y 1) ?s)
                    (in-range-count (- ?x 1) (- ?y 1) ?s)
                    (in-range-count (- ?x 1) (+ ?y 1) ?s))
    )))
)

;;; Decrease the closed neighbours' count for all neighbours of the clicked tile
;;; Pre-conditions:
;;; - Tile has been clicked (not duplicate)
;;;
;;; Actions:
;;; - Decrease closed neighbours' count for all neighbours of the clicked tile by 1
(defrule closed-tile-decrement
    (declare (salience 20))
    (clicked (x ?x) (y ?y))
    (board-size ?s)
    =>
    (and (in-range ?x (- ?y 1) ?s)
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x ?x) (= ?ff:y (- ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range ?x (+ ?y 1) ?s)
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x ?x) (= ?ff:y (+ ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range (- ?x 1) ?y ?s)
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y ?y))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range (+ ?x 1) ?y ?s)
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y ?y))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range (+ ?x 1) (- ?y 1) ?s)
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (- ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range (+ ?x 1) (+ ?y 1) ?s)
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (+ ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range (- ?x 1) (- ?y 1) ?s)
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (- ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
    (and (in-range (- ?x 1) (+ ?y 1) ?s)
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (+ ?y 1)))
            (modify ?ff (count (- ?ff:count 1))))
    )
)

;;; #######################
;;; OPEN TILE (DISCOVER)
;;; #######################
;;; Open tiles that surround clicked tile

;;; Open neighbour's tiles of the tile that has been clicked
;;; Pre-conditions:
;;; - Tile has been clicked
;;;
;;; Actions:
;;; - Inherits open-condition value to neighbours
;;;     -> open-condition of non 0-valued tile should be different
;;;        from 0-valued tile
;;;     -> this is to stop the agent clicking neighbours 
;;;        from non 0-valued tile because it can be a bomb
;;; - Open neighbours tile for discovery
(defrule open-tile
    (declare (salience 20))
    (clicked (x ?x) (y ?y))
    (open-condition (x ?x) (y ?y) (cond ?z))
    (board-size ?s)
    =>
    (and (in-range ?x (- ?y 1) ?s) (
        and (assert (opened (x ?x) (y (- ?y 1))))
        (assert (open-condition (x ?x) (y (- ?y 1)) (cond ?z)))
    ))
    (and (in-range ?x (+ ?y 1) ?s) (
        and (assert (opened (x ?x) (y (+ ?y 1))))
        (assert (open-condition (x ?x) (y (+ ?y 1)) (cond ?z)))
    ))
    (and (in-range (- ?x 1) ?y ?s) (
        and (assert (opened (x (- ?x 1)) (y ?y)))
        (assert (open-condition (x (- ?x 1)) (y ?y) (cond ?z)))
    ))
    (and (in-range (+ ?x 1) ?y ?s) (
        and (assert (opened (x (+ ?x 1)) (y ?y)))
        (assert (open-condition (x (+ ?x 1)) (y ?y) (cond ?z)))
    ))
    (and (in-range (+ ?x 1) (- ?y 1) ?s) (
        and (assert (opened (x (+ ?x 1)) (y (- ?y 1))))
        (assert (open-condition (x (+ ?x 1)) (y (- ?y 1)) (cond ?z)))
    ))    
    (and (in-range (+ ?x 1) (+ ?y 1) ?s) (
        and (assert (opened (x (+ ?x 1)) (y (+ ?y 1))))
        (assert (open-condition (x (+ ?x 1)) (y (+ ?y 1)) (cond ?z)))
    ))
    (and (in-range (- ?x 1) (- ?y 1) ?s) (
        and (assert (opened (x (- ?x 1)) (y (- ?y 1))))
        (assert (open-condition (x (- ?x 1)) (y (- ?y 1)) (cond ?z)))
    ))
    (and (in-range (- ?x 1) (+ ?y 1) ?s) (
        and (assert (opened (x (- ?x 1)) (y (+ ?y 1))))
        (assert (open-condition (x (- ?x 1)) (y (+ ?y 1)) (cond ?z)))
    ))
)

;;; #######################
;;; NOBOMB & BOMB
;;; #######################

;;; Click non 0-valued tile after free nobomb discovery because it should not have any bomb
;;; Pre-conditions:
;;; - Tile has been opened
;;; - Tile is a non 0-valued tile
;;; - Tile is opened by a 0-valued tile (open-condition = 1)
;;;
;;; Actions:
;;; - Click the tile and set open-condition = 0 to indicate the tile is a non 0-valued tile
;;;   It's should not be opened
;;; - Set as nobomb tile
(defrule nobomb-1
    (declare (salience 10))
    (tile (x ?x) (y ?y) (value ?value&:(!= ?value 0)))
    (open-condition (x ?x) (y ?y) (cond 1))
    (opened (x ?x) (y ?y))
    =>
    (assert (nobomb ?x ?y))
    (assert (clicked (x ?x) (y ?y)))
    (assert (open-condition (x ?x) (y ?y) (cond 0))))

;;; Click 0-valued tile after free nobomb discovery to let it discover other tiles
;;; Pre-conditions:
;;; - Tile has been opened
;;; - Tile is opened by a 0-valued tile (open-condition = 1)
;;;
;;; Actions:
;;; - Click the tile and set open-condition = 0 to indicate tile is opened by a non 0-valued tile
;;; - Set as nobomb tile
(defrule nobomb-2
    (declare (salience 15))
    (tile (x ?x) (y ?y) (value 0))
    (not (flagged (x ?x) (y ?y)))
    (open-condition (x ?x) (y ?y) (cond 1))
    (opened (x ?x) (y ?y))
    =>
    (assert (nobomb ?x ?y))
    (assert (clicked (x ?x) (y ?y))))

;;; Click 0-valued tile after bomb discovery which is guarenteed of having no bomb
;;; Pre-conditions:
;;; - Tile has been opened, resulted from bomb discovery
;;; - Tile is a 0-valued tile
;;;
;;; Actions:
;;; - Click the tile and set open-condition = 1 to let the tile discover its neighbours
;;; - Set as nobomb tile
(defrule nobomb-3
    (declare (salience 6))
    (tile (x ?x) (y ?y) (value 0))
    (open-condition (x ?x) (y ?y) (cond 0))
    (opened (x ?x) (y ?y))
    (opened-nobomb ?x ?y)
    =>
    (assert (nobomb ?x ?y))
    (assert (clicked (x ?x) (y ?y)))
    (assert (open-condition (x ?x) (y ?y) (cond 1))))

;;; Click non 0-valued tile after bomb discovery which is guarenteed of having no bomb
;;; Pre-conditions:
;;; - Tile has been opened, resulted from bomb discovery
;;; - Tile is a non 0-valued tile
;;;
;;; Actions:
;;; - Click the tile and set open-condition = 0 to not let the tile discover its neighbours
;;; - Set as nobomb tile
(defrule nobomb-4
    (declare (salience 6))
    (tile (x ?x) (y ?y) (value ?value&:(!= ?value 0)))
    (open-condition (x ?x) (y ?y) (cond 0))
    (opened (x ?x) (y ?y))
    (opened-nobomb ?x ?y)
    =>
    (assert (nobomb ?x ?y))
    (assert (clicked (x ?x) (y ?y)))
    (assert (open-condition (x ?x) (y ?y) (cond 0))))

;;; Open all tiles that are free of bomb
;;; it's inferenced after bomb discover
;;; which made other bomb neighbours' count into 0
;;;
;;; Just avoid clicked tile (incase of bomb)
;;; and also we indicate the tiles are opened after bomb discovery
;;; with opened-bomb fact
(deffunction discover-free (?x ?y ?s)
    (if (in-range ?x (+ ?y 1) ?s)
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
    (if (in-range ?x (- ?y 1) ?s)
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
    (if (in-range (- ?x 1) ?y ?s)
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
    (if (in-range (+ ?x 1) ?y ?s)
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
    (if (in-range (- ?x 1) (- ?y 1) ?s)
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
    (if (in-range (- ?x 1) (+ ?y 1) ?s)
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
    (if (in-range (+ ?x 1) (- ?y 1) ?s)
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
    (if (in-range (+ ?x 1) (+ ?y 1) ?s)
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

;;; Open nobomb tile for discovery
;;; Pre-conditions:
;;; - Unidentified bomb neighbours' count of the tile is 0
;;;   means it's safe to open all neighbour tiles (except bomb)
;;; - Tile has been clicked
;;;
;;; Actions:
;;; - Do discovery-free (explained above)
(defrule open-nobomb
    (declare (salience 10))
    (tile (x ?x) (y ?y) (value ?))
    (unidentified-bomb-neighbours (x ?x) (y ?y) (count 0))
    (not (flagged (x ?x) (y ?y)))
    (clicked (x ?x) (y ?y))
    (board-size ?s)
    =>
    (discover-free ?x ?y ?s))


;;; Flag all closed neighbour tiles as bombs
;;; We also assume flagging as clicking too
(deffunction flagged-bombs (?x ?y ?s)
    (if (in-range ?x (+ ?y 1) ?s)
        then
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x ?x) (= ?ff:y (+ ?y 1)))
            (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                then
                else
                (and
                    (assert (flagged (x ?ff:x) (y ?ff:y)))
                    (assert (clicked (x ?ff:x) (y ?ff:y)))
                    (assert (bomb ?ff:x ?ff:y))
                )
            )
        )
    )
    (if (in-range ?x (- ?y 1) ?s)
        then
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x ?x) (= ?ff:y (- ?y 1)))
            (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                then
                else
                (and
                    (assert (flagged (x ?ff:x) (y ?ff:y)))
                    (assert (clicked (x ?ff:x) (y ?ff:y)))
                    (assert (bomb ?ff:x ?ff:y))
                )
            )
        )
    )
    (if (in-range (- ?x 1) ?y ?s)
        then
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y ?y))
            (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                then
                else
                (and
                    (assert (flagged (x ?ff:x) (y ?ff:y)))
                    (assert (clicked (x ?ff:x) (y ?ff:y)))
                    (assert (bomb ?ff:x ?ff:y))
                )
            )
        )
    )
    (if (in-range (+ ?x 1) ?y ?s)
        then
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y ?y))
            (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                then
                else
                (and
                    (assert (flagged (x ?ff:x) (y ?ff:y)))
                    (assert (clicked (x ?ff:x) (y ?ff:y)))
                    (assert (bomb ?ff:x ?ff:y))
                )
            )
        )
    )
    (if (in-range (- ?x 1) (- ?y 1) ?s)
        then
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (- ?y 1)))
            (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                then
                else
                (and
                    (assert (flagged (x ?ff:x) (y ?ff:y)))
                    (assert (clicked (x ?ff:x) (y ?ff:y)))
                    (assert (bomb ?ff:x ?ff:y))
                )
            )
        )
    )
    (if (in-range (- ?x 1) (+ ?y 1) ?s)
        then
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x (- ?x 1)) (= ?ff:y (+ ?y 1)))
            (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                then
                else
                (and
                    (assert (flagged (x ?ff:x) (y ?ff:y)))
                    (assert (clicked (x ?ff:x) (y ?ff:y)))
                    (assert (bomb ?ff:x ?ff:y))
                )
            )
        )
    )
    (if (in-range (+ ?x 1) (- ?y 1) ?s)
        then
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (- ?y 1)))
            (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                then
                else
                (and
                    (assert (flagged (x ?ff:x) (y ?ff:y)))
                    (assert (clicked (x ?ff:x) (y ?ff:y)))
                    (assert (bomb ?ff:x ?ff:y))
                )
            )
        )
    )
    (if (in-range (+ ?x 1) (+ ?y 1) ?s)
        then
        (do-for-fact ((?ff closed-neighbours)) (and (= ?ff:x (+ ?x 1)) (= ?ff:y (+ ?y 1)))
            (if (any-factp ((?fx clicked)) (and (= ?fx:x ?ff:x) (= ?fx:y ?ff:y)))
                then
                else
                (and
                    (assert (flagged (x ?ff:x) (y ?ff:y)))
                    (assert (clicked (x ?ff:x) (y ?ff:y)))
                    (assert (bomb ?ff:x ?ff:y))
                )
            )
        )
    )
)

;;; If closed neighbours' count == bombs' count in a certain tile
;;; Flagged all closed neighbour tiles as bombs
;;; Pre-conditions:
;;; - Unidentified bomb neighbours' count and closed neighbours' count is not 0 and equal
;;; - Tile has been opened
;;;
;;; Actions:
;;; - Flagged all closed neighbour tiles as bombs
(defrule bomb-1
    (declare (salience 5))
    (unidentified-bomb-neighbours (x ?x) (y ?y) (count ?bn&:(!= ?bn 0)))
    (closed-neighbours (x ?x) (y ?y) (count ?cn))
    (test (= ?cn ?bn))
    (opened (x ?x) (y ?y))
    (board-size ?s)
    =>
    (flagged-bombs ?x ?y ?s)
;    (assert (n-iteration (+ ?*iteration* 1)))
;    (bind ?*iteration* (+ ?*iteration* 1))
)
