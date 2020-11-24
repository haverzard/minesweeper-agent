;;; #######################
;;; DEFTEMPLATES & DEFFACTS
;;; #######################

;;; Tile information (with its value)
(deftemplate tile
   (slot x)
   (slot y)
   (slot value))

;;; Closed neighbours' count of a tile (Init by rotating)
(deftemplate closed-neighbours
   (slot x)
   (slot y)
   (slot count))

;;; Bomb neighbours' count of a tile (Init from value)
(deftemplate bomb-neighbours
   (slot x)
   (slot y)
   (slot count))

;;; Clicked tile by agent
(deftemplate clicked
   (slot x)
   (slot y))

;;; Opened tile (Visible tile or can-be-clicked tile)
(deftemplate opened
   (slot x)
   (slot y))

;;; Condition for a tile to open its neighbours
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