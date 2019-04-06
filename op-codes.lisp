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
  "Gets the op codes from a line as characters"
  (let ((first-tab (position #\Tab line :test #'string=))
	(second-tab (position #\Tab line :from-end t :test #'string=)))
    (if (and first-tab second-tab)
	(subseq line first-tab second-tab)
	nil)))


(defun remove-x-from-list (x list &key (test #'string=))
  (mapcar (lambda (entry)
	    (remove x entry :test test))
	  list))
	  
(defun get-a-files-op-codes (file)
  "Gets a list of op codes from file"
  (mapcar #'get-a-lines-op-codes  file))
(defun remove-blanks-from-op-codes-list (a-files-op-codes)
  (loop :for x :in a-files-op-codes
	:unless (string= x "")
	  :collect x))
(defun remove-nil-from-op-codes-list (op-code-list)
  (loop :for x :in op-code-list
	:when x
	  :collect x))

(defun remove-trailing-spaces-from-op-codes-entry (op-code-entry)
  (subseq op-code-entry 0
	  (1+ (position #\Space op-code-entry :from-end t :test-not #'string=))))
(defun remove-trailing-spaces-from-op-codes-list (a-files-op-codes)
  "Removes the trailing spaces from a-files-op-codes"
  (mapcar #'remove-trailing-spaces-from-op-codes-entry a-files-op-codes))
(defun hexlify-op-code (op-code)
  "Turns b8 into \xb8 for example"
  (concatenate 'string (format nil "\\") "x" op-code))
(defun hexlify-op-codes-entry (op-code-entry)
  "turns '0f05' into '\x0f\x05"
  (coerce (remove nil
		  (reduce #'append
			  (loop :for (a b) :on (coerce op-code-entry 'list)
				:collect (list #\\ #\x a b))))
	  'string))

(defun hexlify-op-codes-file (a-files-op-codes)
  (mapcar #'hexlify-op-codes-entry a-files-op-codes))
  
(defun process (file)
  "Does the boy work"
  (princ
   (apply #'concatenate 'string
     (hexlify-op-codes-file
     (remove-x-from-list #\Tab
      (remove-x-from-list nil
       (remove-x-from-list #\Space
       	(remove-blanks-from-op-codes-list
         (remove-nil-from-op-codes-list
          (get-a-files-op-codes
           (load-up-file file)))))
        :test #'equal))))))

(princ #\NewLine)
(process *file*)
(princ #\NewLine)
