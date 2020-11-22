;;; #######################
;;; DEFTEMPLATES & DEFFACTS
;;; #######################

(deftemplate tile
   (slot x)
   (slot y)
   (slot value))

(deftemplate closedNeighbours
   (slot x)
   (slot y)
   (slot count))

(deftemplate bombNeighbours
   (slot x)
   (slot y)
   (slot count))

(deftemplate clicked
   (slot x)
   (slot y))

(deftemplate opened
   (slot x)
   (slot y))

(deftemplate open-condition
   (slot x)
   (slot y)
   (slot cond))

(deftemplate flagged
   (slot x)
   (slot y))

(defglobal
   ?*iteration* = 0
)