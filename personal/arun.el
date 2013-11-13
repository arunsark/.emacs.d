;;(global-set-key (kbd "C-x C-f") 'helm-find-files)
;;(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
;; use Ido
(ido-mode                      1)
(setq ido-everywhere           t)
(setq ido-enable-flex-matching t)

;; rbenv
(setq exec-path (cons "~/.rbenv/bin" exec-path))
(setenv "PATH" (concat "~/.rbenv/bin:" (getenv "PATH")))
(setq exec-path (cons "~/.rbenv/shims" exec-path))
(setenv "PATH" (concat "~/.rbenv/shims:" (getenv "PATH")))

(setq rsense-home "/usr/lib/rsense-0.3")
(add-to-list 'load-path (concat rsense-home "/etc"))
(require 'rsense)
(add-hook 'before-save-hook 'whitespace-cleanup)

(setq next-line-add-newlines t)
(require 'ace-jump-mode)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

(require 'rspec-mode)

(define-prefix-command 'trim-map)
(global-set-key (kbd "C-c w") 'trim-map)

(global-unset-key (kbd "C-c t"))

(global-set-key (kbd "C-c -")       'split-window-vertically)
(global-set-key (kbd "C-c |")       'split-window-horizontally)
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)
(global-set-key (kbd "C-x O")       (lambda ()
                                      (interactive)
                                      (other-window -1)))


;; activate character pairing
(electric-pair-mode 1)
(global-set-key (kbd "'")
                (lambda () (interactive) (insert "'")))  ; don't pair ' anywhere
(add-hook 'ruby-mode-hook
          (lambda () (add-to-list (make-local-variable 'electric-pair-pairs)
                                  '(?| . ?|))))   ; do pair | in Ruby
(add-hook 'css-mode-hook
          (lambda () (add-to-list (make-local-variable 'electric-pair-pairs)
                                  '(?: . ?\;))))   ; pair : with ; in CSS
(add-hook 'markdown-mode-hook
          (lambda () (add-to-list (make-local-variable 'electric-pair-pairs)
                                  '(?` . ?`))))   ; do pair ` in Markdown

;; Git
(global-set-key (kbd "C-c m s") 'magit-status)

(global-set-key (kbd "C-c v l") 'linum-mode)

;;show time and date
(setq display-time-day-and-date t
      display-time-24hr-format  t)
(display-time)

;;from JEG2 insert newline above and below
(defun jeg2s-newline-below (skip-eol)
  "Insert a new line below the current line and indent it."
  (interactive "P")
  (unless (or (eolp) skip-eol)
    (end-of-line))
  (newline-and-indent))
(global-set-key (kbd "C-c l") 'jeg2s-newline-below)

(defun jeg2s-newline-above ()
  "Insert a new line above the current line and indent it."
  (interactive)
  (unless (bolp)
    (beginning-of-line))
  (newline)
  (previous-line)
  (indent-according-to-mode))
(global-set-key (kbd "C-c L") 'jeg2s-newline-above)


(defun jeg2s-duplicate-line-or-region ()
  "Duplicate the current region, or line, and leave it selected."
  (interactive)
  (let (deactivate-mark)
    (unless (region-active-p)
      (if (and (= 1 (line-number-at-pos))
               (= 1 (count-lines (point-min) (point-max))))
          (progn (call-interactively 'jeg2s-newline-below)
                 (previous-line)))
      (unless (bolp)
        (beginning-of-line))
      (call-interactively 'set-mark-command)
      (next-line)
      (unless (bolp)
        (beginning-of-line)))
    (call-interactively 'kill-region)
    (yank)
    (yank)
    ;; I would prefer to use (activate-mark) below, but it fails in the
    ;; starting case of an unselected line
    (kmacro-exec-ring-item (quote ("" 0 "%d")) nil)))
(global-set-key (kbd "C-c d") 'jeg2s-duplicate-line-or-region)


(defun jeg2s-toggle-string-and-symbol ()
  "Toggle between strings and symbols."
  (interactive)
  (let ((regex (concat "\\`\\(?:"
                       "\"\\(?:\\\\\\\\\\|\\\\\.\\|[^\"\\]+\\)*\""
                       "\\|"
                       "'\\(?:\\\\\\\\\\|\\\\\.\\|[^'\\]+\\)*'"
                       "\\|"
                       ":\\w+"
                       "\\)\\'")))
    (while (or (not (region-active-p))
               (not (or (and (= (point-min) (region-beginning))
                             (= (point-max) (region-end)))
                        (string-match regex (buffer-substring-no-properties
                                             (region-beginning)
                                             (region-end))))))
      (call-interactively 'er/expand-region))
    (let ((matched (buffer-substring-no-properties (region-beginning)
                                                   (region-end))))
      (if (string-match regex matched)
          (cond ((or (string= (substring matched 0 1) "\"")
                     (string= (substring matched 0 1) "'"))
                 (call-interactively 'backward-delete-char-untabify)
                 (let ((old_point (point)))
                   (insert (concat ":" (substring matched 1 -1)))
                   (goto-char (+ old_point 1))))
                ((string= (substring matched 0 1) ":")
                 (call-interactively 'backward-delete-char-untabify)
                 (let ((old_point (point)))
                   (insert (concat "\"" (substring matched 1) "\""))
                   (goto-char (+ old_point 1)))))))))
(global-set-key (kbd "C-c t S") 'jeg2s-toggle-string-and-symbol)

(defun jeg2s-trim-backwards ()
  "Removes all whitespace behind the point."
  (interactive)
  (while (looking-back "[\s\t\n]")
    (backward-delete-char-untabify 1)))

(global-set-key (kbd "C-c w b") 'jeg2s-trim-backwards)

(defun jeg2s-trim-forwards ()
  "Removes all whitespace in front of the point."
  (interactive)
  (while (looking-at "[\s\t\n]")
    (delete-char 1)))
(global-set-key (kbd "C-c w f") 'jeg2s-trim-forwards)

(defun jeg2s-trim-backwards-and-forwards ()
  "Removes all whitespace behind and in front of the point."
  (interactive)
  (jeg2s-trim-backwards)
  (jeg2s-trim-forwards))
(global-set-key (kbd "C-c w w") 'jeg2s-trim-backwards-and-forwards)


(defun jeg2s-nest-new-section ()
  "Splits content before and after the point to insert new content between."
  (interactive)
  (indent-for-tab-command)
  (newline)
  (newline)
  (indent-for-tab-command)
  (previous-line)
  (indent-for-tab-command))
(global-set-key (kbd "C-c RET") 'jeg2s-nest-new-section)

(add-hook 'html-mode-hook               ; override HTML's command
          (lambda ()
            (local-set-key (kbd "C-c RET") 'jeg2s-nest-new-section)))


(defun jeg2s-html-insert-open-and-close-tag ()
  "Generates an open and close HTML snippet using the current word."
  (interactive)
  (let ((inserting-new-tag nil))
    (if (looking-back "[-A-Za-z0-9:_]")
        (progn (set-mark-command nil)
               (while (looking-back "[-A-Za-z0-9:_]")
                 (backward-char)))
      (setq inserting-new-tag t)
      (set-mark-command nil)
      (insert "p")
      (exchange-point-and-mark))
    (let ((tag (buffer-substring (region-beginning) (region-end))))
      (delete-char (string-width tag))
      (cond ((string-match "\\`[bh]r\\'" tag)
             (insert (concat "<" tag ">")))
            ((string-match (concat "\\`\\(?:img\\|meta\\|link\\|"
                                   "input\\|base\\|area\\|col\\|"
                                   "frame\\|param\\)\\'")
                           tag)
             (yas/expand-snippet (concat "<" tag " $1>$0")))
            (t
             (yas/expand-snippet
              (if inserting-new-tag
                  (concat "<${1:"
                          tag
                          "}>$0</${1:"
                          "$(and (string-match \"[-A-Za-z0-9:_]+\" text) "
                          "(match-string 0 text))}>")
                (concat "<"
                        tag
                        "$1>$0</"
                        tag
                        ">"))))))))
(global-set-key (kbd "C-c <") 'jeg2s-html-insert-open-and-close-tag)

(defun jeg2s-erb-insert-or-toggle-erb-tag ()
  "Insert an ERb tag if the point isn't currently in one, or toggle the type."
  (interactive)
  (let ((action))
    (save-excursion
      (let ((regex (concat "\\`<%.*%>\\'")))
        (while (or (not (region-active-p))
                   (not (or (and (= (point-min) (region-beginning))
                                 (= (point-max) (region-end)))
                            (string-match regex (buffer-substring-no-properties
                                                 (region-beginning)
                                                 (region-end))))))
          (er/expand-region 1))
        (let ((matched (buffer-substring-no-properties (region-beginning)
                                                       (region-end))))
          (if (string-match regex matched)
              (progn (goto-char (+ (if (< (point) (mark)) (point) (mark)) 2))
                     (cond ((looking-at "=")
                            (delete-char 1))
                           ((looking-at "#")
                            (delete-char 1)
                            (insert "="))
                           (t
                            (insert "#"))))
            (setq action 'insert)))))
    (if (eq action 'insert)
        (progn (insert "<%=  %>")
               (backward-char 3)))))
(global-set-key (kbd "C-c >") 'jeg2s-erb-insert-or-toggle-erb-tag)


(defun jeg2s-toggle-ruby-hash-type ()
  "Toggle between symbol key hash types."
  (interactive)
  (while (and (not
               (looking-at
                "\\(?::[A-Za-z0-9_]+\s*=>\\|[^A-Za-z0-9_][A-Za-z0-9_]+:\\)"))
              (> (point) (point-min)))
    (backward-char))
  (if (looking-at ":[A-Za-z0-9_]+\s*=>")
      (progn (delete-char 1)
             (while (not (looking-at "\s*=>")) (forward-word))
             (while (looking-at "\s") (delete-char 1))
             (delete-char 2)
             (insert ":")
             (backward-char 2))
    (forward-char)
    (insert ":")
    (let ((end_point (point)))
      (while (not (looking-at ":")) (forward-word))
      (delete-char 1)
      (insert " =>")
      (goto-char end_point))))
(add-hook 'ruby-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c t h") 'jeg2s-toggle-ruby-hash-type)))

(defun jeg2s-toggle-ruby-block-type ()
  "Toggle between brace and do/end block types."
  (interactive)
  (let ((regex (concat "\\`\\(?:"
                       "{.*}"
                       "\\|"
                       "do\\b.+\\bend"
                       "\\)\\'")))
    (while (or (not (region-active-p))
               (not (or (and (= (point-min) (region-beginning))
                             (= (point-max) (region-end)))
                        (string-match regex (buffer-substring-no-properties
                                             (region-beginning)
                                             (region-end))))))
      (call-interactively 'er/expand-region))
    (let ((matched (buffer-substring-no-properties (region-beginning)
                                                   (region-end))))
      (if (string-match regex matched)
          (cond ((string= (substring matched 0 1) "{")
                 (let ((lines (split-string
                               (concat "do"
                                       (if (= (count-matches "\n"
                                                             (point)
                                                             (mark)) 0)
                                           (substring
                                            (jeg2s-regex-replace
                                             (jeg2s-regex-replace
                                              matched
                                              "\\`\\({\\(?:\s*|[^|]*|\\)?\\)\s*"
                                              "\\1\n")
                                             "\s*}\\'"
                                             "\n}")
                                            1
                                            -1)
                                         (substring matched 1 -1))
                                       "end")
                               "\n")))
                   (call-interactively 'backward-delete-char-untabify)
                   (loop for line in lines do
                         (unless (string= line (car lines)) (newline))
                         (insert line))
                   (indent-for-tab-command)
                   (previous-line)
                   (unless (eolp) (move-end-of-line nil))
                   (indent-for-tab-command)))
                ((string= (substring matched 0 2) "do")
                 ;; need to fix expand-region before this can be made to work
                  ))))))
(add-hook 'ruby-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c t b") 'jeg2s-toggle-ruby-block-type)))


(defun jeg2s-find-subpath-in-path (subpath path)
  "Walks up the passed path hunting for subpath at each level."
  (let ((match (concat (file-name-as-directory path) subpath)))
    (if (file-exists-p match)
        match
      (unless (string= path "/")
        (jeg2s-find-subpath-in-path
         subpath
         (file-name-directory (substring path 0 -1)))))))

(defun jeg2s-find-in-path (subpath)
  "Walks up the current path hunting for subpath at each level."
  (jeg2s-find-subpath-in-path
   subpath
   (expand-file-name (if (buffer-file-name)
                         (file-name-directory (buffer-file-name))
                       default-directory))))

(defun jeg2s-read-rails-database-config (path)
  "Loads the database config as:  adapter database username [password]."
  (split-string
   (shell-command-to-string
    (concat "ruby -ryaml -rerb -e 'puts YAML.load(ARGF)[%q{"
            (or (getenv "RAILS_ENV") "development")
            "}].values_at(*%w[adapter database username password])"
            ".compact.join(%q{ })' "
            path))))


;; add keystrokes for inf-ruby
(require 'inf-ruby)
(setq inf-ruby-first-prompt-pattern "^>>\s*")
(setq inf-ruby-prompt-pattern       "^\\(>>\s*\\)")
(global-set-key (kbd "C-c o r") 'inf-ruby)

(defun jeg2s-rails-console ()
  "Invoke inf-ruby with Rails environment loaded."
  (interactive)
  (let ((config (jeg2s-find-in-path "config/environment.rb")))
    (if config
        (run-ruby (concat "irb --inf-ruby-mode -r irb/completion -r " config)
                  "ruby"))))
(global-set-key (kbd "C-c o R") 'jeg2s-rails-console)

;; load theme
(load-theme 'sanityinc-tomorrow-bright t)

(setq org-todo-keywords
      '((sequence "TODO" "WIP" "WAITING" "|" "DONE" "CANCELLED")))


(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("WIP" :foreground "yellow" :weight bold)
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold)
              ("PHONE" :foreground "forest green" :weight bold))))

;;truncate long lines
(setq-default truncate-lines t)
(setq rinari-tags-file-name  "TAGS")
(setq projectile-enable-caching t)

;; add some shotcuts in popup menu mode
;; (define-key popup-menu-keymap (kbd "M-n") 'popup-next)
;; (define-key popup-menu-keymap (kbd "TAB") 'popup-next)
;; (define-key popup-menu-keymap (kbd "<tab>") 'popup-next)
;; (define-key popup-menu-keymap (kbd "<backtab>") 'popup-previous)
;; (define-key popup-menu-keymap (kbd "M-p") 'popup-previous)

(defun yas/popup-isearch-prompt (prompt choices &optional display-fn)
  (when (featurep 'popup)
    (popup-menu*
     (mapcar
      (lambda (choice)
        (popup-make-item
         (or (and display-fn (funcall display-fn choice))
             choice)
         :value choice))
      choices)
     :prompt prompt
     ;; start isearch mode immediately
     :isearch t
     )))

(setq yas/prompt-functions '(yas/popup-isearch-prompt yas/no-prompt))
