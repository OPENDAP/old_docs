#--------------------------------------------------
# Makefile for the DODS/doc/archive/design/ddd-figs/ directory.
#
# $Id$
#
#--------------------------------------------------

HTML_OPTIONS=-show_section_numbers

SOURCE = class-hier.fig \
         structure.fig

# How does this work?
# PSTARGET = $(SOURCE:  %.fig= %.ps)
# EPSTARGET = $(SOURCE:  %.fig= %.eps)

PSTARGET = class-hier.ps \
           structure.ps

EPSTARGET = class-hier.eps \
            structure.eps

# use TEXINPUTS from environment variable
#TEXINPUTS:=$(TEXINPUTS)/usr/local/teTeX/texmf/tex/latex/:
# This is my TEXINPUTS '.:/upc/dods/wwwDocs/DODS/doc/latex/:'

#-----
# Main targets
#-----
all: ps

ps: $(PSTARGET)

eps: $(EPSTARGET)

#-----
# PostScript targets
#-----
%.ps : %.fig
	fig2dev -L ps -P $*.fig  $@

%.eps : %.fig
	fig2dev -L ps $*.fig  $@

#-----
# Targets for cleaning
#-----
clean:
	-rm -f *~

cleanps: clean
	-rm -f *.ps

cleaneps: clean
	-rm -f *.eps

distclean: clean cleanps
