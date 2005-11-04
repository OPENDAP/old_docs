#--------------------------------------------------
# Makefile for the DODS/doc/archive/design/ddd-figs/ directory.
#
# $Id$
#
#--------------------------------------------------

HTML_OPTIONS=-show_section_numbers

SOURCE = client-close.fig \
         client-metaread.fig \
         client-open.fig \
         client-read.fig \
         client-write.fig \
         data-transport.fig \
         process-config4.fig \
         server-das.fig \
         server-executables.fig \
         server-send.fig \
         url-params.fig

# How does this work?
# PSTARGET = $(SOURCE:  %.fig= %.ps)
# EPSTARGET = $(SOURCE:  %.fig= %.eps)

PSTARGET = client-close.ps \
           client-metaread.ps \
           client-open.ps \
           client-read.ps \
           client-write.ps \
           data-transport.ps \
           process-config4.ps \
           server-das.ps \
           server-executables.ps \
           server-send.ps \
           url-params.ps

EPSTARGET = client-close.eps \
           client-metaread.eps \
           client-open.eps \
           client-read.eps \
           client-write.eps \
           data-transport.eps \
           process-config4.eps \
           server-das.eps \
           server-executables.eps \
           server-send.eps \
           url-params.eps

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
