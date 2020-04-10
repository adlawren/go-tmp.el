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
