;;; cus-keymap.el --- customize keymaps

;; Copyright (C) 2008 Jonas Bernoulli

;; Author: Jonas Bernoulli <jonas@bernoulli.cc>
;; Created: 20080830
;; Updated: 20080904
;; Version: 0.0.2
;; Homepage: http://artavatar.net
;; Keywords: extensions

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; After loading this library you can define new customizable keymap
;; variables and prefix commands using `defkeymap' and `defprefixcmd'.

;; In order to make keymaps customizable that where defined without these
;; forms use the function `custom-make-mapvars-customizable' and the
;; command `custom-make-mapvar-customizable'.

;; Function `custom-make-mapvars-customizable' makes all variables
;; customizable that are not yet customizable and whose symbol-value
;; are keymaps.  It should be called only once: in your init file, just
;; before the call to `custom-set-variables', respectively before
;; loading `custom-file'.

;; Most keymaps are undefined until some feature first requested in
;; the current session.  In order to make those keymaps customizable,
;; use command `custom-make-mapvar-customizable'.

;;; Code:

(require 'custom)
(require 'wid-keymap)
(require 'keymap-utils)

(defun custom-make-mapvars-customizable ()
  "Make all variables customizable whose symbol-value are keymaps.

Variables that are already customizable are not affected.

This function should be called only once: in your init file, just
before the call to `custom-set-variables', respectively before
loading `custom-file'.

To make a keymap variable customizable that was not defined
when this function was called use the interactive command
`custom-make-mapvar-customizable'."
  (do-symbols (symbol)
    (when (and (not (eq symbol 'symbol))
	       (boundp symbol)
	       (keymapp (symbol-value symbol)))
      (custom-make-mapvar-customizable-internal symbol))))

(defun custom-make-mapvar-customizable (feature symbol)
  "Interactively make keymap variable SYMBOL customizable.

Prompt for FEATURE which has to be loaded for SYMBOL to be defined.
If necessary FEATURE is then loaded.  Prompt for SYMBOL.

Finally make SYMBOL customizable as `custom-make-mapvars-customizable'
would but also add FEATURE to SYMBOL's `custom-request' property, which
is preserved for futur sessions if you then customize and save SYMBOL.

This command can also be used if SYMBOL is already customizable in
which case only FEATURE is added to SYMBOL's `custom-request' property.

It is actually recommended that you do so for all customized keymaps,
\(unless defined using the specialized forms) because this is the only
way to be sure that SYMBOL's `standard-value' is always correct.

Otherwise when a customized keymap variable is no longer defined by
the time Custom sets the customized variables, the saved value would
also be recorded as the standard value, which almost certainly is wrong."
  (interactive "SFeature: \nSSymbol: ")
  (unless (interactive-p)
    (error "Only for interactive use"))
  (require feature)
  (custom-make-mapvar-customizable-internal symbol (list feature)))

(defun custom-make-mapvar-customizable-internal (symbol &optional requests)
  (unless (get symbol 'custom-type)
    (put symbol 'custom-type 'keymap)
    (put symbol 'custom-set 'kmu-set-mapvar)
    (put symbol 'standard-value (list (quote (symbol-value symbol)))))
  (when requests
    (let ((current (get symbol 'custom-requests)))
      (dolist (request requests)
	(add-to-list 'current request)))))

;;; The `defkeymap' Macro.

(defmacro defkeymap (symbol value doc &rest args)
  "Declare SYMBOL as a customizable keymap that defaults to VALUE.
DOC is the variable documentation.

Neither SYMBOL nor VALUE need to be quoted.  If SYMBOL is not already
bound, initialize it to VALUE, which has to be a keymap or nil.

The remaining arguments should have the form

   [KEYWORD VALUE]...

The same keywords are meaningful as for `defcustom' with the following
restrictions:

* Keywords `:set' (value: `kmu-set-mapvar') and `:type' (value: `keymap')
  can not be overwriten.

* When setting keyword `initialize' (which you shouldn't have to) make
  sure that `kmu-set-mapvar' is used to set the value.

* Do not set keywords `:option', `:risky' and `:safe'.  They are not
  meaningful for keymaps.

Also see `defcustom'."
  (declare (doc-string 3))
  (setq args (plist-put args :type '(quote keymap)))
  (setq args (plist-put args :set  '(quote kmu-set-mapvar)))
  (nconc (list 'custom-declare-variable
	       (list 'quote symbol)
	       (list 'quote (or value (quote (make-sparse-keymap))))
	       doc)
	 args))

;;; The `defprefixcmd' Macro.

(defmacro defprefixcmd (command mapvar value doc &rest args)
  "Define MAPVAR as a customizable keymap and COMMAND as a prefix command.
DOC is the variable documentation.

Neither MAPVAR, COMMAND nor VALUE need to be quoted.  If MAPVAR is not
already bound, initialize it to VALUE, which has to be a keymap or nil.
If MAPVAR is nil store the keymap in COMMAND's `symbol-value'.

Also see `defprefixcmd' and `defkeymap'."
  `(progn (defkeymap ,(or mapvar command) ,value ,doc ,@args)
	  (fset ',command ,(or mapvar command))))

;;; Font Lock.

(defvar cus-keymap-font-lock-keywords
  '(("(\\(defkeymap\\>\\)" (1 font-lock-keyword-face))
    ("(\\(defprefixcmd\\>\\)" (1 font-lock-keyword-face))))

(defun cus-keymap-do-font-lock ()
  (font-lock-add-keywords nil cus-keymap-font-lock-keywords))

(add-hook 'emacs-lisp-mode-hook 'cus-keymap-do-font-lock)

(provide 'cus-keymap)
;;; cus-keymap.el ends here
