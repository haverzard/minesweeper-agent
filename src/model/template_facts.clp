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
