(defvar gimme-cat-urls nil)
(defvar gimme-cat-last-updated 0)
(defvar gimme-cat-api-key "ac6d4ba1e8c5ab491d534b480c830c37")
(defvar gimme-cat-tag "kitten")

(defun parse-photo-info (photo-ids)
  (let ((finished nil)
	(location-in-string 0)
	(urls '()))
    (while (not finished)
      (if
	  (not (string-match "\"id\":\"\\([0-9]+\\)\"[^\{]*\"secret\":\"\\([a-z0-9]+\\)\"[^\{]*\"server\":\"\\([0-9]+\\)\"[^\{]*\"farm\":\\([0-9]+\\)" photo-ids location-in-string))
	  (setq finished 't)
	(setq location-in-string (match-end 4))
	(let ((id (match-string-no-properties 1 photo-ids))
	      (secret (match-string-no-properties 2 photo-ids))
	      (server (match-string-no-properties 3 photo-ids))
	      (farm (match-string-no-properties 4 photo-ids)))
	  (setq urls (cons (format "http://farm%s.staticflickr.com/%s/%s_%s_m.jpg" farm server id secret) urls)))))
    urls))


(defun dl-url (url suffix)
  (let* ((tempfile-path (make-temp-file "catfile" nil suffix))
	(command (format "wget \"%s\" -O %s" url tempfile-path)))
    (shell-command-to-string command)
    (find-file tempfile-path)))


(defun get-cat-urls (kitten-tag)
  (message "Getting image list from flickr")
  (let* ((url (format "http://api.flickr.com/services/rest/?format=json&sort=random&method=flickr.photos.search&tags=%s&tag_mode=all&api_key=%s&per_page=200" gimme-cat-tag gimme-cat-api-key)))
    (dl-url url ".json")
    (goto-char (point-min))
    (re-search-forward "\"photo\":\\[\{\\(.*\\)\\]\}")
    (let* ((photo-urls (parse-photo-info (match-string-no-properties 1))))
      (kill-buffer (current-buffer))
      (setq gimme-cat-last-updated (float-time))
      (setq gimme-cat-urls photo-urls))))


(defun gimme-cat (arg)
  (interactive "P")
  (when (or
	 arg
	 (> (/ (- (float-time) gimme-cat-last-updated) (* 60 60)) 1))
    (get-cat-urls gimme-cat-tag))
  (dl-url (nth (random (length gimme-cat-urls)) gimme-cat-urls) ".jpg"))


(defun close-if-cat (buffer)
  (let ((filename (buffer-file-name buffer))
	(buffername (buffer-name buffer)))
    (when (and filename (string-match "catfile.*[\.json|\.jpg]" filename))
      (kill-buffer buffer)
      (message (format "cat buffer %s closed." buffername)))))


(defun close-gimmecat-buffers ()
  (interactive)
  (mapcar 'close-if-cat (buffer-list)))


(provide 'gimme-cat)
