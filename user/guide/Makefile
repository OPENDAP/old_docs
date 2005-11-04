#
# Makefile for figures, and other miscellany.

# $Id$

GIF_FILES=*.gif

all: arch.gif linked.gif unlinked.gif grid.gif wish.gif

html: arch.gif linked.gif unlinked.gif grid.gif wish.gif

ps:

%.gif: %.fig
	fig2dev -L gif $< $@

#
# Cleaning up the joint.
#
clean:
	-rm -f $(GIF_FILES)
