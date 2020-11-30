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

;;; Same tile
(deffunction same-tile (?x1 ?y1 ?x2 ?y2)
    (and (= ?x1 ?x2) (= ?y1 ?y2))
)

;;; Get all possible neighbours
(deffunction get-neighbours (?x ?y)
    (create$
        (- ?x 1) ?y
        (+ ?x 1) ?y
        ?x       (- ?y 1)
        ?x       (+ ?y 1)
        (- ?x 1) (- ?y 1)
        (- ?x 1) (+ ?y 1)
        (+ ?x 1) (- ?y 1)
        (+ ?x 1) (+ ?y 1)
    )
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
    (bind ?neighbours (get-neighbours ?x ?y))
    (while (!= (length ?neighbours) 0) do
        (bind ?i (nth$ 1 ?neighbours))
        (bind ?j (nth$ 2 ?neighbours))
        (if (in-range ?i ?j ?s)
            then
            (do-for-fact ((?ff unidentified-bomb-neighbours)) (same-tile ?i ?j ?ff:x ?ff:y)
                (modify ?ff (count (- ?ff:count 1)))
            )
        )
        (bind ?neighbours (delete$ ?neighbours 1 2))
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
    (bind ?neighbours (get-neighbours ?x ?y))
    (while (!= (length ?neighbours) 0) do
        (bind ?i (nth$ 1 ?neighbours))
        (bind ?j (nth$ 2 ?neighbours))
        (if (in-range ?i ?j ?s)
            then
            (do-for-fact ((?ff closed-neighbours)) (same-tile ?i ?j ?ff:x ?ff:y)
                (modify ?ff (count (- ?ff:count 1)))
            )
        )
        (bind ?neighbours (delete$ ?neighbours 1 2))
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
    (bind ?neighbours (get-neighbours ?x ?y))
    (while (!= (length ?neighbours) 0) do
        (bind ?i (nth$ 1 ?neighbours))
        (bind ?j (nth$ 2 ?neighbours))
        (if (in-range ?i ?j ?s)
            then
            (and
                (assert (opened (x ?i) (y ?j)))
                (assert (open-condition (x ?i) (y ?j) (cond ?z)))
            )
        )
        (bind ?neighbours (delete$ ?neighbours 1 2))
    )
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
    ?f1<-(open-condition (x ?x) (y ?y) (cond 1))
    (opened (x ?x) (y ?y))
    =>
    (assert (nobomb ?x ?y))
    (assert (clicked (x ?x) (y ?y)))
    (modify ?f1 (cond 0)))

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
    ?f1<-(open-condition (x ?x) (y ?y) (cond 0))
    (opened (x ?x) (y ?y))
    (opened-nobomb ?x ?y)
    =>
    (assert (nobomb ?x ?y))
    (assert (clicked (x ?x) (y ?y)))
    (modify ?f1 (cond 1)))

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
    (assert (clicked (x ?x) (y ?y))))

;;; Open all tiles that are free of bomb
;;; it's inferenced after bomb discover
;;; which made other bomb neighbours' count into 0
;;;
;;; Just avoid clicked tile (incase of bomb)
;;; and also we indicate the tiles are opened after bomb discovery
;;; with opened-bomb fact
(deffunction discover-free (?x ?y ?s)
    (bind ?neighbours (get-neighbours ?x ?y))
    (while (!= (length ?neighbours) 0) do
        (bind ?i (nth$ 1 ?neighbours))
        (bind ?j (nth$ 2 ?neighbours))
        (if (in-range ?i ?j ?s)
            then
            (do-for-fact ((?ff open-condition)) (same-tile ?i ?j ?ff:x ?ff:y)
                (if (any-factp ((?fx clicked)) (same-tile ?ff:x ?ff:y ?fx:x ?fx:y))
                    then
                    else
                    (assert (opened (x ?ff:x) (y ?ff:y)))
                    (modify ?ff (cond 0))
                    (assert (opened-nobomb ?ff:x ?ff:y))
                )
            )
        )
        (bind ?neighbours (delete$ ?neighbours 1 2))
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
    (bind ?neighbours (get-neighbours ?x ?y))
    (while (!= (length ?neighbours) 0) do
        (bind ?i (nth$ 1 ?neighbours))
        (bind ?j (nth$ 2 ?neighbours))
        (if (in-range ?i ?j ?s)
            then
            (do-for-fact ((?ff closed-neighbours)) (same-tile ?i ?j ?ff:x ?ff:y)
                (if (any-factp ((?fx clicked)) (same-tile ?ff:x ?ff:y ?fx:x ?fx:y))
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
        (bind ?neighbours (delete$ ?neighbours 1 2))
    )
)

;;; If closed neighbours' count == bombs' count in a certain tile
;;; Flagged all closed neighbour tiles as bombs
;;; Pre-conditions:
;;; - Unidentified bomb neighbours' count and closed neighbours' count is not 0 and equal
;;; - Tile has been clicked
;;;
;;; Actions:
;;; - Flagged all closed neighbour tiles as bombs
(defrule bomb-1
    (declare (salience 5))
    (unidentified-bomb-neighbours (x ?x) (y ?y) (count ?bn&:(!= ?bn 0)))
    (closed-neighbours (x ?x) (y ?y) (count ?cn))
    (test (= ?cn ?bn))
    (clicked (x ?x) (y ?y))
    (board-size ?s)
    =>
    (flagged-bombs ?x ?y ?s)
;    (assert (n-iteration (+ ?*iteration* 1)))
;    (bind ?*iteration* (+ ?*iteration* 1))
)
