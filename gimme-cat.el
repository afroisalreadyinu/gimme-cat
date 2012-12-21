;; This work is licensed under the Creative Commons Attribution 3.0
;; Unported License. To view a copy of this license, visit
;; http://creativecommons.org/licenses/by/3.0/ or send a letter to
;; Creative Commons, 444 Castro Street, Suite 900, Mountain View,
;; California, 94041, USA.

(defvar gimme-cat-urls nil)
(defvar gimme-cat-last-updated 0)
(defvar gimme-cat-api-key "ac6d4ba1e8c5ab491d534b480c830c37")
(defvar gimme-cat-tag "kitten")
(defvar gimme-cat-url-batch-size 500)
(defvar gimme-cat-mode nil)
(make-variable-buffer-local 'gimme-cat-mode)

(defun gimme-cat-mode (&optional arg)
  "gimme-cat minor mode"
  (interactive "P")
  (setq gimme-cat-mode (if (null arg) (not gimme-cat-mode)
			 (> (prefix-numeric-value arg) 0))))

(defvar gimme-cat-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "SPC") 'gimme-cat)
    (define-key map (kbd "k") 'close-gimmecat-buffers)
    map))

(unless (assq 'gimme-cat-mode minor-mode-alist)
  (setq minor-mode-alist
	(cons '(gimme-cat-mode " gimme-cat-mode")
	      minor-mode-alist)))

(unless (assq 'gimme-cat-mode minor-mode-map-alist)
  (setq minor-mode-map-alist
	(cons (cons 'gimme-cat-mode gimme-cat-keymap)
	      minor-mode-map-alist)))


(defun parse-photo-info ()
  (let ((finished nil)
        (urls '()))
    (while (not finished)
      (condition-case nil
          (re-search-forward "\"id\":\"\\([0-9]+\\)\"[^\{]*\"secret\":\"\\([a-z0-9]+\\)\"[^\{]*\"server\":\"\\([0-9]+\\)\"[^\{]*\"farm\":\\([0-9]+\\)")
        (error (setq finished 't)))
      (let ((id (match-string-no-properties 1))
            (secret (match-string-no-properties 2))
            (server (match-string-no-properties 3))
            (farm (match-string-no-properties 4)))
        (setq urls (cons (format "http://farm%s.staticflickr.com/%s/%s_%s_z.jpg" farm server id secret) urls))))
    urls))

(defun dl-url (url)
  (let ((gimme-wget (shell-command-to-string "which wget")))
    (when (equal gimme-wget "")
      (error "You don't have wget on your Emacs path. Please consult the README on how to fix this.")))
  (let* ((tempfile-path (make-temp-file "catfile"))
	(command (format "wget \"%s\" -O %s" url tempfile-path)))
    (shell-command-to-string command)
    (find-file tempfile-path)))


(defun get-cat-urls (kitten-tag)
  (message "Getting image list from flickr")
  (let* ((url (format "http://api.flickr.com/services/rest/?format=json&sort=random&method=flickr.photos.search&tags=%s&tag_mode=all&api_key=%s&per_page=%d" gimme-cat-tag gimme-cat-api-key gimme-cat-url-batch-size)))
    (dl-url url)
    (let* ((photo-urls (parse-photo-info)))
      (kill-buffer (current-buffer))
      (setq gimme-cat-last-updated (float-time))
      (setq gimme-cat-urls photo-urls))))


(defun gimme-cat (arg)
  (interactive "P")
  (when (or arg
            (not gimme-cat-urls)
            (> (/ (- (float-time) gimme-cat-last-updated) (* 60 60)) 1))
    (get-cat-urls gimme-cat-tag))
  (let ((img-url (nth (random (length gimme-cat-urls)) gimme-cat-urls)))
    (dl-url img-url)
    (image-mode)
    (gimme-cat-mode)
    (setq gimme-cat-urls (delete img-url gimme-cat-urls))))


(defun close-if-cat (buffer)
  (with-current-buffer buffer
    (when gimme-cat-mode
      (kill-buffer))))


(defun close-gimmecat-buffers ()
  (interactive)
  (mapcar 'close-if-cat (buffer-list)))


(provide 'gimme-cat)

;; TODO
;; - Show image info somehow
;; - Bind r key to loading a new image
;; - Save images in the same file in a temp directory.
