(ql:quickload (list :cl-ppcre :drakma))
(defpackage :discord-cache-download
  (:use :cl :cl-ppcre :drakma)
  (:nicknames :dcached))
(in-package :discord-cache-download)

(defparameter *cache-dir* "~/.config/discord/Cache/*")
(defparameter *save-dir* "./images/")
(defparameter *regex* "http[s]?:\/\/(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+")

(defun read-file (path)
  "Read first 200 bytes from path"
  (let ((string ""))
    (with-open-file (file path :element-type '(unsigned-byte 8))
      (loop :for x := (read-byte file nil)
            :for y :from 0 :to 200
            :do (setf string (format nil "~A~A" string (code-char x)))))
    string))

(defun extract-url-regex (string)
  (scan-to-strings *regex* string))
(defun extract-url-from-path (path)
  (extract-url-regex (read-file path)))
(defun all-caches ()
  (directory *cache-dir*))
(defun empty-stringp (string)
  (< (length string) 1))
(defun regex (reg string)
  (scan-to-strings reg string))
(defun valid-url (string)
  "valid url checks to make sure that the link is an image and is from discord servers"
  (and (regex "discord" string)
       (regex ".(jpg|png|gif|jpeg|jpe|webp)" string)))

(defun validate-pathnamep (pathname)
  "A valid pathname is like this '510a9991623a86f8_0'"
  (let ((name (file-namestring pathname)))
    (if (not (empty-stringp name))
        (let  ((first-char (aref name 0))
               (second-char (aref name 1))
               (last-char (aref name (1- (length name)))))
          (if (and (char/= first-char #\.)
                   (or (char/= second-char #\#)
                       (char/= first-char #\#))
                   (char= last-char #\0))
              t
              nil))
        nil)))

(defun remove-invalid-paths (list-of-paths)
  (remove-if-not #'validate-pathnamep list-of-paths))
(defun remove-invalid-urls (list-of-urls)
  (remove-if-not #'valid-url list-of-urls))
(defun all-urls (list-of-files)
 (mapcar #'extract-url-from-path  list-of-files))

(defun write-to-file (array pathname)
  (with-open-file (file pathname :element-type '(unsigned-byte 8)
                                 :if-does-not-exist :create 
                                 :if-exists :overwrite
                                 :direction :output)
    (loop :for byte :across array
          :do (write-byte byte file))))

(defun request-and-save (url name)
  (handler-case
      (write-to-file (http-request url)
                     (format nil "~A~A"
                             *save-dir*
                             name))
    (ERROR (c) (format t "Error ~A~%" c))
    (USOCKET:NS-TRY-AGAIN-CONDITION (c) (format t "Error ~A~%" c))))

(defun request-and-save-all ()
  (loop :for url :in (remove-invalid-urls (all-urls (remove-invalid-paths (all-caches))))
        :with x := 0
        :do (format t "Requesting ~A~%" url)
            (request-and-save url x)	    
            (incf x)
            (sleep 0.1)))

