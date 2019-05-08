#!/usr/bin/sbcl --script
;;;;script that takes in a compiled file and grabs only the op codes from it

(defparameter *path* (second sb-ext:*posix-argv*))
(defparameter *file* (if *path*
			 (merge-pathnames 
			  *path*
			  (first (directory "")))
			 (progn (princ "need to pass a file")
				(princ #\NewLine)
				(exit))))


(defun load-up-file (file)
  "returns the contents of file"
  (with-open-file (f file)
    (loop :for x := (read-line f nil)
	  :while x
	  :collect x)))

(defun get-a-lines-op-codes (line)
  "need to step through the string and check for a #\ #\<char> #\<char> #\. Can't use regex because that requires quicklisp"
  (if (> (length line) 4)
      (do* ((len (length line))
	    (colon-found-p nil)
	    (op-codes "")
	    (a 0 (1+ a))
	    (b 1 (1+ b))
	    (c 2 (1+ c))
	    (d 3 (1+ d))
	    (ac (aref line a)
		(aref line a))
	    (bc (aref line b)
		(aref line b))
	    (cc (aref line c)
		(aref line c))
	    (dc (aref line d)
		(aref line d)))
	   (nil)
	(when (some (lambda (char)
		    (char= char #\:))
		  (list ac bc cc dc))
	    (setf colon-found-p t))
	(when (and colon-found-p
		   (and (char/= bc #\Space)
			(char/= cc #\Space))
		   (or (and (char= ac #\Tab)
			    (char= dc #\Space))
		       (and (char= dc #\Tab)
			    (char= ac #\Space))
		       (char= ac dc #\Space)
		       (char= ac dc #\Tab)))
	  (setf op-codes
		(concatenate 'string op-codes
			     (format nil "\\x~A~A" bc cc))))
	(if (= d (1- len))
	    (return op-codes)))
      ""))
(defun get-a-files-op-codes (file)
  (mapcar #'get-a-lines-op-codes file))
(defun process (file)
  "Does the boy work"
  (princ
   (apply #'concatenate 'string
	  (get-a-files-op-codes
	   (load-up-file file))))
  :test #'equal)

(princ #\NewLine)
(process *file*)
(princ #\NewLine)

