;; -*- emacs-lisp -*-
;; Time-stamp: <Last changed 2014-05-28 09:55:38 by Liyun Dai, dailiyun>

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.


(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://stable.melpa.org/packages/"))
(package-initialize)


(message "Reading configuration file...")

;;;;;;;;;;;;;
;; ;;                                         ;color theme
;; ;; ;;;;;;;;;;;;
(when window-system       ;start speedbar if we're using a window system like X, etc
  (add-to-list 'load-path "~/.emacs.d/color-theme-6.6.0")
  (set-face-attribute 'default nil :height 115)
  (require 'color-theme)
  (color-theme-initialize)
  (color-theme-robin-hood)
)





(menu-bar-mode -1)                        ;;never have a retarded menu-bar at top

(setq-default indicate-empty-lines t)     ;;show (in left margin) marker for empty lines




;; (add-to-list 'load-path "~/.emacs.d/plugins/sml-modeline-0.5")

;;Modline-------------------------------------
(line-number-mode t)                        ;; show line numbers
(column-number-mode t)                      ;; show column numbers
(global-linum-mode t)
(require 'hl-line) ;;high light current row

(global-hl-line-mode t)

(size-indication-mode t)                    ;; show file size (emacs 22+)





;;Uniquify-buffers ----------------------------
(when (require 'uniquify nil 'noerror)  ;; make buffer names more unique
  (setq
   uniquify-buffer-name-style 'post-forward
   uniquify-separator ":"
   uniquify-after-kill-buffer-p t       ;; rename after killing uniquified
   uniquify-ignore-buffers-re "^\\*"))  ;; don't muck with special buffers
;;---------------------------------------------


;;Remove/kill completion buffer when done-----
;;could use ido-find-file instead, since it never uses *Completions*
;;Note that ido-mode affects both buffer switch, &  find file.
(add-hook 'minibuffer-exit-hook
          '(lambda ()
             (let ((buffer "*Completions*"))
               (and (get-buffer buffer)
                    (kill-buffer buffer)))
             ))
;; TODO: Kill: *dictem buffer*, *Apropos, *Help*
;; kill them when you leave the buffer, like: C-x o
;;--------------------------------------------


;;---------------------------------------------
;; pressing S saves all unsaved buffers, try hitting SPC at [Org]-label.
;; See what happens
;; RET folds a filter (like folders and hierarchies)

(require 'ibuffer)

;;replace default with ibuffer. Open i other window, and take me there.
(global-set-key (kbd "C-x C-b") 'ibuffer-other-window)

;;sort on major-mode
(setq ibuffer-default-sorting-mode 'major-mode)

(setq ibuffer-saved-filter-groups
      (quote (("default"
               ("Org" ;; all org-related buffers
                (mode . org-mode))
               ;; ("equfitter"
               ;;  (filename . "equationfitter/"))
               ("Programming C++" ;; prog stuff not already in MyProjectX
                (or
                 (mode . c-mode)
                 (mode . c++-mode)
                 ))

               ("Source Code" ;; non C++ related stuff.
                (or
                 (mode . python-mode)
                 (mode . emacs-lisp-mode)
                 (mode . shell-script-mode)
                 (mode . f90-mode)
                 (mode . scheme-mode)
                 ;; etc
                 ))

               ("LaTeX"
                (or
                 (mode . tex-mode)
                 (mode . latex-mode)
                 (name . ".tex")
                 (name . ".bib")
                 ))

               ("Text" (name . ".txt"))

               ("Mail"
                (or  ;; mail-related buffers
                 (mode . message-mode)
                 (mode . mail-mode)
                 (mode . mime-mode)
                 ;;                   (mode . MIME-mode)

                 ;; etc.; all your mail related modes
                 ))

               ("Web" (or (mode . html-mode)
                          (mode . css-mode)))

               ("ERC"   (mode . erc-mode))

               ;; ("Subversion" (name . "\*svn"))
               ;; ("Magit" (name . "\*magit"))

               ("Emacs-created"
                (or
                 (name . "\*Help\*")
                 (name . "\*Apropos\*")
                 (name . "\*info\*")
                 (name . "\**\*")))
               ))))



(add-hook 'ibuffer-mode-hook
          (lambda ()
            ;;(ibuffer-auto-mode 1)   ;auto update the buffer-list
            (ibuffer-switch-to-saved-filter-groups "default")
            ))


;;Don't show (filter) groups that are empty.
(setq ibuffer-show-empty-filter-groups nil)
;;(autoload 'ibuffer "ibuffer" "List buffers." t)

;; keep from warning, twice, about deleting buffers.
;; only warn about deleting modified buffers.
(setq ibuffer-expert t)


;; Switching to ibuffer puts the cursor on the most recent buffer
(defadvice ibuffer (around ibuffer-point-to-most-recent) ()
           "Open ibuffer with cursor pointed to most recent buffer name"
           (let ((recent-buffer-name (buffer-name)))
             ad-do-it
             (ibuffer-jump-to-buffer recent-buffer-name)))
(ad-activate 'ibuffer)
;---------------------------------------------


;;---------------------------------------------
(define-key ibuffer-mode-map [remap ibuffer-visit-buffer]
  '(lambda () (interactive)
     (ibuffer-visit-buffer t)))

;;-------------------


;;---------------------------------------------
(defun ibuffer-ediff-marked-buffers ()
  (interactive)
  (let* ((marked-buffers (ibuffer-get-marked-buffers))
         (len (length marked-buffers)))
    (unless (= 2 len)
      (error (format "%s buffer%s been marked (needs to be 2)"
                     len (if (= len 1) " has" "s have"))))
    (ediff-buffers (car marked-buffers) (cadr marked-buffers))))

(define-key ibuffer-mode-map "e" 'ibuffer-ediff-marked-buffers)


;;buffer switching ----------------------------
;;better C-x b  (ido does the same for C-x C-f)
(iswitchb-mode t)
;;---------------------------------------------


(icomplete-mode t)       ;;minibuffer compeltion/suggestions

(add-hook 'c-mode-common-hook
          (lambda ()
            (define-key c-mode-map [(ctrl tab)] 'complete-tag)))


;;One-Line commands---------------------------
(defalias 'yes-or-no-p 'y-or-n-p)     ;;answer "y/n" rather than "yes/no"

;(delete-selection-mode t)            ;;delete region at key press, not needed due to cua-mode nil (in rectangle)

;(setq visible-bell t)                 ;;blink instead of beep
(setq inhibit-startup-message t)      ;;Don't show start up message/buffer
(file-name-shadow-mode t)             ;;be smart about file names in mini buffer
(global-font-lock-mode t)             ;;syntax highlighting on...
(setq font-lock-maximum-decoration t) ;;...as much as possible
(setq frame-title-format '(buffer-file-name "%f" ("%b"))) ;;titlebar=buffer unless filename

(setq-default indent-tabs-mode nil)   ;;use spaces instead of evil tabs

(setq tetris-score-file "~/.emacs.d/tetris-scores") ;;keep home-folder clean
;;--------------------------------------------


;;Key-Bindings--------------------------------

;;(global-set-key (kbd "C-M-p") 'backward-list) ;; back jump to match  parenthetical group 

(global-set-key (kbd "M-#")   'sort-lines)            ;;sort lines with Alt-#
(global-set-key (kbd "C-#")   'sort-paragraphs)       ;;sort paragraphs Ctrl-#
(global-set-key [(control tab)] 'hippie-expand)       ;;Ctrl-Tab, word-completion
(global-set-key (kbd "C-z")   'undo)                  ;;better than "C-_"
(global-set-key (kbd "<f8>")  'comment-or-uncomment-region) ;; comment/un-comment region




;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;copy from other softwares
;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun h-insert-x-selection () (interactive)
       (insert (x-selection 'CLIPBOARD)))

(global-set-key [(meta insert)] 'h-insert-x-selection)
(global-set-key  [(shift insert)] 'x-insert-selection)

(define-key global-map (kbd "C-<left>") 'windmove-left)
(define-key global-map (kbd "C-<right>") 'windmove-right)
(define-key global-map (kbd "C-<up>") 'windmove-up)
(define-key global-map (kbd "C-<down>") 'windmove-down)


(global-set-key [f1] 'manual-entry )

(global-set-key [C-f1] 'info)
(global-set-key [f3] 'grep-find)
(global-set-key [M-f3] 'kill-this-buffer)

                                        ;(global-set-key [f5] 'tool-bar-mode)

                                        ;(global-set-key [C-f5] 'menu-bar-mode)


(global-set-key [(f4)] 'speedbar-get-focus)
(when window-system       ;start speedbar if we're using a window system like X, etc
  (speedbar t)) 

(global-set-key (kbd "M-1") 'delete-other-windows)
(global-set-key (kbd "M-4") 'delete-window)

(add-to-list 'load-path "~/.emacs.d/cl-lib")
(require 'cl-lib)
(require 'cc-mode)

;; (define-key c-mode-base-map [(f6)] 'gud-gdb)
(define-key c++-mode-map [(f6)] 'gdb)
(setq-default display-buffer-reuse-frames t)
(define-key c-mode-base-map [C-f8] 'gdb-restore-windows)
;(define-key c++-mode-map [C-f8] 'gdb-restore-windows)

(global-set-key [S-f3] 'find-grep)
(setq grep-find-command 
      "grep -rnH --exclude=.hg --include=\*.{c,cpp,h} --include=-e 'pattern' ~/src_top/*")






                                        ;(define-key c-mode-map [(f7)] 'compile)
(define-key c-mode-base-map [(f12)] 'compile)
                                        ;(define-key c++-mode-map [(f7)] 'compile)





;;Auto compile *.elc-files on save -----------
(defun auto-byte-recompile ()
  "If the current buffer is in emacs-lisp-mode and there already exists an `.elc'
file corresponding to the current buffer file, then recompile the file on save."
  (interactive)
  (when (and (eq major-mode 'emacs-lisp-mode)
             (file-exists-p (byte-compile-dest-file buffer-file-name)))
    (byte-compile-file buffer-file-name)))
(add-hook 'after-save-hook 'auto-byte-recompile)




;;Parantes-matchning--------------------------
;;Match parenthesis through highlighting rather than retarded jumps. Good!
(when (fboundp 'show-paren-mode)
  (show-paren-mode t)
  (setq show-paren-style 'parenthesis))

;;----------------------------------------

;; hippie-expand ------------------------------
;; (setq hippie-expand-try-functions-list
;;       '(yas/hippie-try-expand
;;         try-expand-all-abbrevs
;;         try-expand-dabbrev
;;         try-expand-dabbrev-from-kill
;;         try-expand-dabbrev-all-buffers
;;         try-complete-file-name-partially
;;         try-complete-file-name
;;         ;;         try-expand-list
;;         ;;         try-expand-line
;;         ;;        try-complete-lisp-symbol-partially
;;         ;;        try-complete-lisp-symbol
;;         ))


;;preserve case on expand with dabbrev
;;(setq dabbrev-case-replace nil)

;;---------------------------------------------


                                        ;(add-to-list 'load-path "~/.emacs.d/elpa/volatile-highlights-1.10")

                                        ;(when (require 'volatile-highlights nil 'noerror)
                                        ;  (volatile-highlights-mode t))




;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;c++ mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;Generic -------------------------------------
;; C++-specific. Which extensions should be associated with C++ (rather than C)
(add-to-list 'auto-mode-alist '("\\.h$"  . c++-mode)) ;h-files
(add-to-list 'auto-mode-alist '("\\.c$"  . c++-mode)) ;c-files
(add-to-list 'auto-mode-alist '("\\.icc" . c++-mode)) ;implementation files
(add-to-list 'auto-mode-alist '("\\.tcc" . c++-mode)) ;files with templates


(add-to-list 'auto-mode-alist '("\\.kml" . xml-mode)) ;files with templates

;;Indentation style:
;;(add-hook 'c-mode-common-hook '(lambda () (c-set-style "stroustrup")))
;; (add-hook 'c-mode-common-hook '(lambda () (setq c-default-style "linux"
;;                                                 c-basic-offset 4 )  ) )



;;--------------------------------------------

;;Navigate .h och .cpp ------------------------
;;Now, we can quickly switch between myfile.cc and myfile.h with C-c o.
;;Note the use of the c-mode-common-hook, so it will work for both C and C++.
(add-hook 'c-mode-common-hook
          (lambda()
            (local-set-key  (kbd "C-c o") 'ff-find-other-file)))
;;--------------------------------------------




;; ;;Fold code-block-----------------------------
;; (add-hook 'c-mode-common-hook
;;           (lambda()
;;             ;; ;; Collides with winner mode:
;;             ;; (local-set-key (kbd "C-c <right>") 'hs-show-block)
;;             ;; (local-set-key (kbd "C-c <left>")  'hs-hide-block)
;;             ;; (local-set-key (kbd "C-c <up>")    'hs-hide-all)
;;             ;; (local-set-key (kbd "C-c <down>")  'hs-show-all)

;;             ;; Now same/similar to org-mode hirarcy, but collides with
;;             ;; my (previous) setting for next-error/previous-error
;;             (local-set-key (kbd "M-<right>") 'hs-show-block)
;;             (local-set-key (kbd "M-<left>")  'hs-hide-block)
;;             (local-set-key (kbd "M-<up>")    'hs-hide-all)
;;             (local-set-key (kbd "M-<down>")  'hs-show-all)
;;             ;;hide/show code-block
;;             (hs-minor-mode t)))
;; ;;--------------------------------------------


;; ;;---------------------------------------------


;; Better compile buffer ----------------------
(require 'compile)
(add-hook 'c-mode-common-hook
          (lambda ()
            (setq
             compilation-scroll-output 'first-error  ; scroll until first error
             ;; compilation-read-command nil          ; don't need enter
             compilation-window-height 11)

            (local-set-key (kbd "<M-up>")   'previous-error)
            (local-set-key (kbd "<M-down>") 'next-error)
            
            )

          ;;(number of things in " " in format must match number of arg. in getenv.)
          ;;This will run Make if there is a Makefile in the same directory as the
          ;;source-file, or it will create a command for compiling a single
          ;;file and name the executable the same name as the file with the extension
          ;;stripped.
          )


;; Note: the M-x grep command will print its result as a Compilation
;; buffer (named *grep*), but we do not want to kill that one.
;;--------------------------------------------


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;kill the frame when the compile does not occur errors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun kill-buffer-when-compile-success (process)
  "Close current buffer when `shell-command' exit."
  (set-process-sentinel process
                        (lambda (proc change)
                          (when (string-match "finished" change)
                            (run-at-time 0.5 nil 'delete-windows-on (process-buffer proc))))))

(add-hook 'compilation-start-hook 'kill-buffer-when-compile-success)


(defun my-recompile ()
    "Run compile and resize the compile window closing the old one if necessary"
    (interactive)
    (progn
        (if (get-buffer "*compilation*") ; If old compile window exists
            (progn
                (delete-windows-on (get-buffer "*compilation*")) ; Delete the compilation windows
                (kill-buffer "*compilation*") ; and kill the buffers
                )
            )
        (call-interactively 'compile)
        (enlarge-window 20)
        )
    )
(defun my-next-error () 
    "Move point to next error and highlight it"
    (interactive)
    (progn
      (next-error)
      (end-of-line-nomark)
      (beginning-of-line-mark)
      )
  )
  
(defun my-previous-error () 
    "Move point to previous error and highlight it"
    (interactive)
    (progn
        (previous-error)
        (end-of-line-nomark)
        (beginning-of-line-mark)
        )
    )
(global-set-key (kbd "C-n") 'my-next-error)
(global-set-key (kbd "C-p") 'my-previous-error)
  
(global-set-key [f5] 'my-recompile)



;; (load-file "~/.emacs.d/cedet-1.1/common/cedet.el")

;; Enable EDE (Project Management) features
;(global-ede-mode 1)

;; Enable EDE for a pre-existing C++ project
;; (ede-cpp-root-project "NAME" :file "~/myproject/Makefile")


;; Enabling Semantic (code-parsing, smart completion) features
;; Select one of the following:

;;; ; * This enables the database and idle reparse engines
;; (semantic-load-enable-minimum-features)

;; ;; * This enables some tools useful for coding, such as summary mode,
;; ;;   imenu support, and the semantic navigator
;;(semantic-load-enable-code-helpers)
;; ;
;; * This enables even more coding tools such as intellisense mode,
;;   decoration mode, and stickyfunc mode (plus regular code helpers)
;;(semantic-load-enable-gaudy-code-helpers)

;; * This enables the use of Exuberant ctags if you have it installed.
;;   If you use C++ templates or boost, you should NOT enable it.
;;(semantic-load-enable-all-exuberent-ctags-support)
;;   Or, use one of these two types of support.
;;   Add support for new languages only via ctags.
;; (semantic-load-enable-primary-exuberent-ctags-support)
;;   Add support for using ctags as a backup parser.
;; (semantic-load-enable-secondary-exuberent-ctags-support)

;; Enable SRecode (Template management) minor-mode.
;; (global-srecode-minor-mode 1)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;gdb;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;; ;;Make up/down behave as in terminal
;; ;;run it like this "M-x gdb",
;; ;;  gdb --annotate=3 ./yourBinary
(add-hook 'gud-mode-hook
          '(lambda ()
             (local-set-key [home] ; move to beginning of line, after prompt
                            'comint-bol)
             (local-set-key [up] ; cycle backward through command history
                            '(lambda () (interactive)
                               (if (comint-after-pmark-p)
                                   (comint-previous-input 1)
                                 (previous-line 1))))
             (local-set-key [down] ; cycle forward through command history
                            '(lambda () (interactive)
                               (if (comint-after-pmark-p)
                                   (comint-next-input 1)
                                 (forward-line 1))))
             )
          (setq gdb-many-windows t)
          (setq gdb-show-main t))
;; ;; ;;============================================





;; ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; ;old old old old old
;; ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;







;; ;start auto-complate when emacs start
(add-to-list 'load-path "~/.emacs.d/elpa/auto-complete-1.5.1")
(add-to-list 'load-path "~/.emacs.d/plugins/popup")
(require 'auto-complete)

(require 'auto-complete-config)
 (ac-config-default)

(setq ac-quick-help-delay 0.5)






(add-to-list 'load-path "~/.emacs.d/iedit/")
(require 'iedit)
                                        ;change the default key bings
(define-key global-map (kbd "C-c ;") 'iedit-mode)





;;                                        trun on Semantic
                                        ;and hook this function to c-mode-common-hook

(defun my:add-semantics-to-auto-complete()
  (add-to-list 'ac-sources 'ac-source-semantic)
  )
(add-hook 'c-mode-common-hook 'my:add-semantics-to-auto-complete)
                                        (add-hook 'c++-mode-common-hook 'my:add-semantics-to-auto-complete)

                                        ;turn on ede model


;; ;;;;;;;;;;;;;;;;;;
;; ;;;latex
;; ;;;;;;;;;;;;;;;;;

 (load-file "~/.emacs.d/latex.el")


;;Math-$$-matchning---------------------------
(setq LaTeX-mode-hook'
      (lambda () (defun TeX-insert-dollar ()
                   "custom redefined insert-dollar"
                   (interactive)
                   (insert "$$")           ;;in LaTeX mode, typing "$" automatically
                   (backward-char 1))))    ;;insert "$$" and move back one char.
;;--------------------------------------------


;; ;;; set the trigger key so that it can work together with yasnippet on tab key,
;; ;;; if the word exists in yasnippet, pressing tab will cause yasnippet to
;; ;;; activate, otherwise, auto-complete will

(add-hook 'LaTeX-mode-hook
          (lambda()
            (auto-complete-mode)
            (global-set-key  [C-tab] 'auto-complete-mode )
            )
          )


;; set XeTeX mode in TeX/LaTeX
(add-hook 'LaTeX-mode-hook 
          (lambda()
            (add-to-list 'TeX-command-list '("XeLaTeX" "%`xelatex%(mode)%' %t" TeX-run-TeX nil t))
            (setq TeX-command-default "XeLaTeX")
            (setq TeX-save-query nil)
                                        ;(setq TeX-show-compilation t)
            ))




(setq frame-title-format "emacs@%b")
(setq user-full-name "Liyun Dai")
(setq user-mail-address "dlyun2009@gmail.com")

                                        ;(setq dired-recursive-copies 'top)
                                        ;(setq dired-recursive-deletes 'top)  


;; ;;clang two slow
(add-to-list 'load-path "~/.emacs.d/plugins/auto-complete-clang")

;; (require 'auto-complete-clang)  
;; (setq ac-clang-auto-save nil)  
;; (setq ac-auto-start t)
;; (setq ac-quick-help-delay 0.5)


;; (define-key ac-mode-map  [(control tab)] 'auto-complete)
;; (ac-set-trigger-key "tab")
;; (ac-set-trigger-key "<tab>")

;; (defun my-ac-config ()  
;;   (setq ac-clang-flags  
;;         (mapcar(lambda (item)(concat "-I" item))  
;;                (split-string  
;;                 "  
;; . 
;; include
;; ../include
;; /usr/include/c++/4.2.1
;;  /usr/include/c++/4.2.1/backward
;;  /usr/lib/gcc/x86_64-linux-gnu/4.6/include
;;  /usr/local/include
;;  /usr/lib/gcc/x86_64-linux-gnu/4.6/include-fixed
;;  /usr/include/x86_64-linux-gnu
;;  /usr/include  
;; ")))


;;   (setq-default ac-sources '(ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers))  
;;   (add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-mode-setup)  
;;   (add-hook 'c-mode-common-hook 'ac-cc-mode-setup)  
;;   (add-hook 'ruby-mode-hook 'ac-ruby-mode-setup)  
;;  (add-hook 'css-mode-hook 'ac-css-mode-setup)  
;;   (add-hook 'auto-complete-mode-hook 'ac-common-setup)  
;;   (global-auto-complete-mode t) 
;;   )

;; (defun my-ac-cc-mode-setup ()  
;;   (setq ac-sources (append '(ac-source-clang ac-source-yasnippet) ac-sources)))  
;;                                         ;; clang two slow
;; (add-hook 'c-mode-common-hook 'my-ac-cc-mode-setup)  

;; ;; ac-source-gtags
;; (my-ac-config)  





;; ;; ;;==========================================================
;; ;; ;;load cscope
;; ;; ;;==========================================================
(load-file "~/.emacs.d/xcscope.el")

(add-hook 'c-mode-common-hook
          '(lambda ()
             (require 'xcscope)))
(add-hook 'c-mode-base-hook
          '(lambda ()
               (require 'xcscope)))


;; (define-key global-map [(control f3)]  'cscope-set-initial-directory)
;; (define-key global-map [(control f4)]  'cscope-unset-initial-directory)
;; (define-key global-map [(control f5)]  'cscope-find-this-symbol)
;; (define-key global-map [(control f6)]  'cscope-find-global-definition)
;; (define-key global-map [(control f7)]    'cscope-find-global-definition-no-prompting)
;; (define-key global-map [(control f8)]  'cscope-pop-mark)
;; (define-key global-map [(control f9)]  'cscope-next-symbol)
;; (define-key global-map [(control f10)] 'cscope-next-file)
;; (define-key global-map [(control f11)] 'cscope-prev-symbol)
;; (define-key global-map [(control f12)] 'cscope-prev-file)
;; (define-key global-map [(meta f9)]  'cscope-display-buffer)
;; (define-key global-map [(meta f10)] 'cscope-display-buffer-toggle)



;;compile 

(defun file-name-base (&optional filename)
  "Return the base name of the FILENAME: no directory, no extension.
FILENAME defaults to `buffer-file-name'."
  (file-name-sans-extension
   (file-name-nondirectory (or filename (buffer-file-name)))))



(defun quick-compile ()  
  "A quick compile funciton for C++"
  (save-buffer)  
  (interactive)

  (compile (concat "g++ -o " (file-name-base) "  "  (buffer-name(current-buffer)) " -g -pg "))

  )  

;;Short key F9  
(define-key c-mode-base-map [(f9)] 'quick-compile)
(define-key c++-mode-map [(f9)] 'quick-compile)



(defun quick-run()
  "A quick run function for c++"
  (interactive)
  (shell-command (concat "./" (file-name-base))))

(define-key c-mode-base-map [C-f10] 'quick-run)
(define-key c++-mode-map [C-f10] 'quick-run)

                                        ;(define-key c-mode-base-map [M-f12] 'eassist-switch-h-cpp)



;; ;; ;;;;;;;;;;;;;;;;;;;;;
;; ;; ; tags
;; ;; ;;;;;;;;;;;;;;;;;
;;  (defun create-tags()
;;   "create tags under this dir"
;;   (interactive)
;;   (shell-command  (concat "gtags -v ") )
;; ;  (visit-tags-table (concat ".") )
;; )
;;   (global-set-key  [C-f12] 'create-tags )





;;TODO use backup-directory-alist instead!
(defconst my-backup-dir "~/.backups")

(setq make-backup-files t ;;make backup first time a file is saved
      backup-by-copying t ;; and copy them to...
      backup-directory-alist '(("." . "~/.backups")) ;; ...here
      ;;delete-auto-save-files t   ;;this is default (rm #file# if file is saved)
      version-control t
      kept-new-versions 2
      kept-old-versions 5
      delete-old-versions t
      ;;make-backup-files nil      ;;No annoying "~file.txt"
      ;;auto-save-default nil      ;;no auto saves to #file#
      )

;; if no backup directory exists, then create it:
(if (not (file-exists-p my-backup-dir))
    (make-directory my-backup-dir t))


;;TAB cyckles if fewer than 5 completions. Else show *Completions*
;;buffer.
(if (>= emacs-major-version 24)
    (setq completion-cycle-threshold 5))
;;;;;;;;;;;;;;
                                        ;maple
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(load-file "~/.emacs.d/maple/maplev.el") 



;(require 'sr-speedbar)




 (add-to-list 'load-path "~/.emacs.d/plugins/google-style")
 (require 'google-c-style)  
 (add-hook 'c-mode-common-hook 'google-set-c-style)  
 (add-hook 'c-mode-common-hook 'google-make-newline-indent) 



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;doxymacs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (add-to-list 'load-path "~/.emacs.d/plugins/doxymacs-1.8.0/lisp")
 (require 'doxymacs)

(doxymacs-mode);doxymacs-mode常true  
(add-hook 'c-mode-common-hook 'doxymacs-mode) ;; 启动doxymacs-mode  
(add-hook 'c++-mode-common-hook 'doxymacs-mode) ;; 启动doxymacs-mode



;;hightlight coment for c and c++ program
(defun my-doxymacs-font-lock-hook ()  
  (if (or (eq major-mode 'c-mode) (eq major-mode 'c++-mode))  
      (doxymacs-font-lock)))  
(add-hook 'font-lock-mode-hook 'my-doxymacs-font-lock-hook)




;; 防止页面滚动时跳动，scroll-margin 3  
(setq scroll-margin 3  
    scroll-conservatively 10000)  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;括号配对
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-c-mode-auto-pair ()
  (interactive)
  (make-local-variable 'skeleton-pair-alist)
  (setq skeleton-pair-alist  '(
    (?` ?` _ "''")
    (?\( ?  _ " )")
    (?\[ ?  _ " ]")
    (?{ \n > _ \n ?} >)))
  (setq skeleton-pair t)
  (local-set-key (kbd "(") 'skeleton-pair-insert-maybe)
  (local-set-key (kbd "{") 'skeleton-pair-insert-maybe)
  (local-set-key (kbd "`") 'skeleton-pair-insert-maybe)
  (local-set-key (kbd "[") 'skeleton-pair-insert-maybe))
(add-hook 'c-mode-hook 'my-c-mode-auto-pair)
(add-hook 'c++-mode-hook 'my-c-mode-auto-pair)


(defun insert-date ()
  "Insert current date yyyy-mm-dd."
  (interactive)
  (when (use-region-p)
    (delete-region (region-beginning) (region-end) )
    )
  (insert (format-time-string "%Y-%m-%d"))
  )



;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;clang format
;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; indentiation stuff (maybe some variable is missing for other language
(setq-default indent-line-function 4)
(setq-default tab-width 4)
(setq-default c-basic-offset 4)
(setq-default lisp-indent-offset 4)

(put 'scroll-left 'disabled nil)
(setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq auto-window-vscroll nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
    '(package-selected-packages
         (quote
             (ac-c-headers clang-format auto-compile auto-complete-clang zenburn-theme yasnippet volatile-highlights flymake-easy flycheck auto-complete-c-headers))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


(load-file "~/.emacs.d/plugins/auto-complete-c-headers/auto-complete-c-headers.el")	
(defun my:ac-c-header-init()
  (require 'auto-complete-c-headers)
  (add-to-list 'ac-sources 'ac-source-c-headers)
    (add-to-list 'achead:include-directoires "/usr/include/c++/4.2.1/")
  )


(add-hook 'c++-mode-hook 'my:ac-c-header-init)
(add-hook 'c-mode-hook 'my:ac-c-header-init)

(add-hook 'org-mode-hook (lambda () (setq truncate-lines nil)))


(org-babel-do-load-languages
    'org-babel-load-languages
    '(
         (sh . t)
         (python . t)
         (R . t)
         (ruby . t)
         (ditaa . t)
         (dot . t)
         (octave . t)
         (sqlite . t)
         (perl . t)
         (C . t)
         ))
;;  org-mode 8.0
(setq org-latex-pdf-process '("xelatex -interaction nonstopmode %f"
                                 "xelatex -interaction nonstopmode %f"))

