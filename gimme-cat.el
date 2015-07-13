;; This work is licensed under the Creative Commons Attribution 3.0
;; Unported License. To view a copy of this license, visit
;; http://creativecommons.org/licenses/by/3.0/ or send a letter to
;; Creative Commons, 444 Castro Street, Suite 900, Mountain View,
;; California, 94041, USA.

(require 'json)

(defvar gimme-cat--urls nil)
(defvar gimme-cat--last-updated 0)
(defvar gimme-cat--api-key "ac6d4ba1e8c5ab491d534b480c830c37")
(defvar gimme-cat-tag "kitten")
(defvar gimme-cat-url-batch-size 500)
(defvar gimme-cat-mode nil)
(make-variable-buffer-local 'gimme-cat-mode)
(defvar gimme-cat-current nil)
(make-variable-buffer-local 'gimme-cat-current)


(defun gimme-cat-mode (&optional arg)
  "gimme-cat minor mode"
  (interactive "P")
  (setq gimme-cat-mode (if (null arg) (not gimme-cat-mode)
                         (> (prefix-numeric-value arg) 0))))


(defun gimme-cat-start-catsup (&optional arg)
  (interactive "P")
  (let ((seconds (if arg
                     (* (car arg) 60)
                   (* 25 60))))
    (setq gimme-cat--catsup-timer (run-at-time seconds nil 'gimme-cat 5))))


(defun gimme-cat-stop-catsup ()
  (interactive)
  (cancel-timer gimme-cat--catsup-timer))


(defvar gimme-cat-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "SPC") 'gimme-cat)
    (define-key map (kbd "k") 'gimme-cat-close-gimmecat-buffers)
    (define-key map (kbd "o") 'gimme-cat-open-img-page)
    map))

(unless (assq 'gimme-cat-mode minor-mode-alist)
  (setq minor-mode-alist
        (cons '(gimme-cat-mode " gimme-cat-mode")
              minor-mode-alist)))

(unless (assq 'gimme-cat-mode minor-mode-map-alist)
  (setq minor-mode-map-alist
        (cons (cons 'gimme-cat-mode gimme-cat-keymap)
              minor-mode-map-alist)))


(defun gimme-cat--photo-to-data (photo)
  (cons (format "https://farm%s.staticflickr.com/%s/%s_%s_z.jpg"
                (gethash "farm" photo)
                (gethash "server" photo)
                (gethash "id" photo)
                (gethash "secret" photo))
        (format "https://www.flickr.com/photos/%s/%s/"
                (gethash "owner" photo)
                (gethash "id" photo))))

(defun gimme-cat--parse-photo-info ()
  (let ((json-object-type 'hash-table))
    (let* ((parsed-json (json-read))
           (photos (gethash "photo"
                            (gethash "photos" parsed-json))))
      (mapcar 'gimme-cat--photo-to-data photos))))


(defun gimme-cat--dl-url (url)
  (let ((gimme-wget (shell-command-to-string "which wget")))
    (when (equal gimme-wget "")
      (error "You don't have wget on your Emacs path. Please consult the README on how to fix this.")))
  (let* ((tempfile-path (make-temp-file "catfile"))
         (command (format "wget \"%s\" -O %s" url tempfile-path)))
    (shell-command-to-string command)
    (find-file tempfile-path)))


(defun gimme-cat--get-cat-urls (kitten-tag)
  (let* ((url (format "https://api.flickr.com/services/rest/?format=json&sort=random&method=flickr.photos.search&tags=%s&tag_mode=all&api_key=%s&per_page=%d&nojsoncallback=1" gimme-cat-tag gimme-cat--api-key gimme-cat-url-batch-size)))
    (gimme-cat--dl-url url)
    (let* ((photo-urls (gimme-cat--parse-photo-info)))
      (kill-buffer (current-buffer))
      (setq gimme-cat--last-updated (float-time))
      (setq gimme-cat--urls photo-urls))))


(defun gimme-cat (arg)
  (interactive "P")
  (when (or arg
            (not gimme-cat--urls)
            (> (/ (- (float-time) gimme-cat--last-updated) (* 60 60)) 1))
    (gimme-cat--get-cat-urls gimme-cat-tag))
  (let ((img-and-page-url (nth (random (length gimme-cat--urls)) gimme-cat--urls)))
    (gimme-cat--dl-url (car img-and-page-url))
    (image-mode)
    (gimme-cat-mode)
    (setq gimme-cat--urls (delete img-and-page-url gimme-cat--urls))
    (setq gimme-cat-current img-and-page-url)))


(defun gimme-cat--close-if-cat (buffer)
  (with-current-buffer buffer
    (when gimme-cat-mode
      (kill-buffer))))


(defun gimme-cat-close-gimmecat-buffers ()
  (interactive)
  (mapcar 'gimme-cat--close-if-cat (buffer-list)))

(defun gimme-cat-open-img-page ()
  (interactive)
  (browse-url (cdr gimme-cat-current)))

(provide 'gimme-cat)
