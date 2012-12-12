gimme-cat
=========

Elisp snippet to give you a cat picture in Emacs. Put the file
gimme-cat.el somewhere on your elisp path or copy the contents into
your .emacs file. Then bind the command gimme-cat to a key, as
follows:

    (global-set-key "\C-c\k" 'gimme-cat)

And now enjoy kittens in Emacs. Images can be displayed only with
Emacs versions capable of windowing, btw (so not on the command line).

The list of images from which random picks are made is updated every
hour. If you want to force the update, call the `gimme-cat` command
with a prefix arg (i.e. `C-u`).

For every image, a new buffer is opened. If you don't want to bother
closing them individually, use the `close-gimmecat-buffers` to close
all the buffers opened by gimme-cat.