;;; macro-math.el --- in-buffer mathematical operations
;;
;; Copyright (C) 2007 Nikolaj Schumacher
;;
;; Author: Nikolaj Schumacher <bugs * nschum de>
;; Version: 0.9
;; Keywords: convenience
;; URL: http://nschum.de/src/emacs/macro-math/
;; Compatibility: GNU Emacs 21.x, GNU Emacs 22.x
;;
;; This file is NOT part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; Add the following to your .emacs file:
;;
;; (require 'macro-math)
;; (global-set-key "\C-x~" 'macro-math-eval-and-round-region)
;; (global-set-key "\C-x=" 'macro-math-eval-region)
;;
;; At any time, especially during macros, add an expression to the buffer and
;; mark it.  Then call `macro-math-eval-region' to get the result.
;;
;; For example, use it to increase all numbers in a buffer by one.
;; Call `kmacro-start-macro', move the point behind the next number, type "+ 1",
;; mark the number and + 1, call `macro-math-eval-region'.  Finish the macro
;; with `kmacro-end-macro', then call it repeatedly.
;;
;;; Change Log ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;    Changed back-end to `calc-eval'.
;;
;; 2007-04-10 (0.9)
;;    Initial release.
;;
;;; Code:

(eval-when-compile (require 'cl))

(defgroup macro-math nil
  "In-buffer mathematical operations"
  :group 'convenience)

(defcustom macro-math-rounding-precision 3
  "*Number of decimal places macro-math will round to by default."
  :type 'number
  :group 'macro-math)

;;;###autoload
(defun macro-math-eval-region (beg end &optional copy-to-kill-ring digits)
  "Evaluate the marked mathematical expression and replace it with the result.
With prefix arg COPY-TO-KILL-RING, don't replace the region, but save the result
to the kill-ring.
When digits is non-nil, it determines the number of decimal digits to round to."
  (interactive "r\nP")
  (let* ((calc-multiplication-has-precedence nil)
         (result (macro-math-eval (buffer-substring-no-properties beg end)))
         (rounded (if digits
                      (macro-math-round result digits)
                    (number-to-string result))))
    (if copy-to-kill-ring
        (progn (deactivate-mark)
               (kill-new rounded))
      (delete-region beg end)
      (insert rounded))))

;;;###autoload
(defun macro-math-eval-and-round-region (beg end &optional digits)
  "Call `macro-math-eval-region' and round the number to DIGITS places.
If DIGITS is nil, `macro-math-rounding-precision' will be used."
  (interactive "r\nP")
  (macro-math-eval-region
   beg end nil (or digits macro-math-rounding-precision)))

;;; Internal ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun macro-math-eval (expression)
  (string-to-number (calc-eval expression)))

(defun macro-math-round (number digits)
  "Return a string representation of NUMBER rounded to DIGITS places."
  (if (<= digits 0)
      (number-to-string (round number))
    (format
     (format "%%.%df" digits) number)))

(provide 'macro-math)
