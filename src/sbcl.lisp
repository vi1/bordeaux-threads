;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; indent-tabs-mode: nil -*-

#|
Copyright 2006, 2007 Greg Pfeil

Distributed under the MIT license (see LICENSE file)
|#

(in-package #:bordeaux-threads)

;;; documentation on the SBCL Threads interface can be found at
;;; http://www.sbcl.org/manual/Threading.html

;;; Thread Creation

(defun %make-thread (function name)
  (sb-thread:make-thread function :name name))

(defun current-thread ()
  sb-thread:*current-thread*)

(defun threadp (object)
  (typep object 'sb-thread:thread))

(defun thread-name (thread)
  (sb-thread:thread-name thread))

;;; Resource contention: locks and recursive locks

(defun make-lock (&optional name)
  (sb-thread:make-mutex :name (or name "Anonymous lock")))

(defun acquire-lock (lock &optional (wait-p t))
  (sb-thread:get-mutex lock nil wait-p))

(defun release-lock (lock)
  (sb-thread:release-mutex lock))

(defmacro with-lock-held ((place) &body body)
  `(sb-thread:with-mutex (,place) ,@body))

(defun make-recursive-lock (&optional name)
  (sb-thread:make-mutex :name (or name "Anonymous recursive lock")))

;;; XXX acquire-recursive-lock and release-recursive-lock are actually
;;; complicated because we can't use control stack tricks.  We need to
;;; actually count something to check that the acquire/releases are
;;; balanced

(defmacro with-recursive-lock-held ((place) &body body)
  `(sb-thread:with-recursive-lock (,place)
     ,@body))

;;; Resource contention: condition variables

(defun make-condition-variable (&key name)
  (sb-thread:make-waitqueue :name (or name "Anonymous condition variable")))

(defun condition-wait (condition-variable lock)
  (sb-thread:condition-wait condition-variable lock))

(defun condition-notify (condition-variable)
  (sb-thread:condition-notify condition-variable))

(defun thread-yield ()
  (sb-thread:release-foreground))

;;; Timeouts

(deftype timeout () 'sb-ext:timeout)

(defmacro with-timeout ((timeout) &body body)
  `(sb-ext:with-timeout ,timeout
     ,@body))

;;; Introspection/debugging

(defun all-threads ()
  (sb-thread:list-all-threads))

(defun interrupt-thread (thread function)
  (sb-thread:interrupt-thread thread function))

(defun destroy-thread (thread)
  (signal-error-if-current-thread thread)
  (sb-thread:terminate-thread thread))

(defun thread-alive-p (thread)
  (sb-thread:thread-alive-p thread))

(defun join-thread (thread)
  (sb-thread:join-thread thread))

(mark-supported)
