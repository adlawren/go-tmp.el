;;; go-tmp.el --- Helper functions to run Go code in a local throwaway project

;; Author: A.L. <adlawren010@gmail.com>
;; Maintainer: A.L. <adlawren010@gmail.com>
;; Created: 11 Apr 2020
;; Version: 0.0.1
;; Keywords: languages, go
;; URL: https://github.com/adlawren/go-tmp.el

;; This file is not part of GNU Emacs.

;;; Commentary:
;; In lieu of copying/uploading code to The Go Playground, this package creates a local throwaway project at $GOPATH/src/go-tmp.el/tmp which can be used to run the code instead. Code from a selected region can be automatically executed in this project and the output illustrated.
;; Within the throwaway project, the goimports tool is used to import dependencies needed by the selected code. As such, in order for this package to work, goimports must be installed and accessible from $PATH in an arbitrary shell.

;;; Code:

(defvar
  go-tmp-dir
  (concat (getenv "GOPATH") "/src/go-tmp.el/tmp")
  "The path to the throwaway project.")

(defun go-tmp-main-file ()
  "Return the path to the main.go file in the throwaway project."
  (concat go-tmp-dir "/main.go"))

(defun go-tmp-run-text (text)
  "Run the given Go code in a throwaway project, and return the output as a string. goimports is used to import required dependencies."
  (mkdir go-tmp-dir t)
  (string-to-file
   (concat "package main\nfunc main() {\n" text "\n}\n")
   (go-tmp-main-file))
  (shell-command-to-string
   (concat "cd \"" go-tmp-dir "\" && goimports -w -e . && go run .")))

(defun go-tmp-region ()
  "Run the Go code from the selected region in a throwaway project, and print the output."
  (interactive)
  (message
   (go-tmp-run-text (buffer-substring (region-beginning) (region-end)))))

(defun go-tmp-region-focus ()
  "Same as go-tmp-region, but also opens the main.go file from the throwaway project in a buffer, and switches to that buffer. If the file is open in an existing buffer, that buffer is used, after the file has been reloaded from disk - any changes in the existing buffer are discarded."
  (interactive)
  (let ((run-output
         (go-tmp-run-text
          (buffer-substring (region-beginning) (region-end)))))
    (with-temp-buffer
      (let ((file-buffer (find-buffer-visiting (go-tmp-main-file))))
        (cond
         (file-buffer
          (switch-to-buffer file-buffer)
          (revert-buffer :ignore-auto :noconfirm)))))
    (find-file (go-tmp-main-file))
    (message run-output)))

;;; go-tmp.el ends here
