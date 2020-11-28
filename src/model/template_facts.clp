;;; #######################
;;; DEFTEMPLATES & DEFFACTS
;;; #######################

;;; Tile information (with its value)
(deftemplate tile
   (slot x)
   (slot y)
   (slot value))

;;; Closed (not clicked) neighbours' count of a tile (Init by rotating)
(deftemplate closed-neighbours
   (slot x)
   (slot y)
   (slot count))

;;; Unidentified bomb neighbours' count of a tile (Init from value)
(deftemplate unidentified-bomb-neighbours
   (slot x)
   (slot y)
   (slot count))

;;; Clicked tile by agent (Visible for viewing tile's value)
(deftemplate clicked
   (slot x)
   (slot y))

;;; Opened tile (Visible or can-be-clicked tile for agent)
(deftemplate opened
   (slot x)
   (slot y))

;;; Condition for a tile to open its neighbours
;;; or condition how a tile is opened
(deftemplate open-condition
   (slot x)
   (slot y)
   (slot cond))

;;; Flagged tile (Predicted bomb tile)
(deftemplate flagged
   (slot x)
   (slot y))

;;; Just global var for counting iteration
(defglobal
   ?*iteration* = 0
)