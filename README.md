gimme-cat
=========

Elisp snippet to give you a cat picture in Emacs. Put the file
gimme-cat.el somewhere on your elisp path or copy the contents into
your .emacs file. Then bind the command gimme-cat to a key, as
follows:

    (global-set-key "\C-c\k" 'gimme-cat)

And now enjoy kittens in Emacs. While visiting a cat image opened by
gimme-cat, you can load a new file by pressing space. You can then
close all the opened cat images by pressing `k`.

Images can be displayed only with Emacs versions capable of windowing,
btw (so not on the command line).

The list of images from which random picks are made is updated every
hour. If you want to force the update, call the `gimme-cat` command
with a prefix arg (i.e. `C-u`).

For every image, a new buffer is opened. If you don't want to bother
closing them individually, use the `close-gimmecat-buffers` to close
all the buffers opened by gimme-cat. This function is bound to `k` in
a cat buffer.

Fixing the path on MAC OS X
---------------------------

Unfortunately, Emacs on MAC OS comes with a rather botched PATH
variable for its shell mode. gimme-cat uses the shell command wget to
download stuff, so you have to fix the PATH in your Emacs
configuration to get it to run. Here is how you do it. Go to a command
line and run `which wget`. That should print out something like
`/usr/local/bin/wget`. Now take the directory part of that path, and
append it to PATH in your Emacs configuration with the following
expression:

    (setenv "PATH" (concat "/usr/local/bin:" (getenv "PATH")))

Reload your configuration, and everything should run smoothly.