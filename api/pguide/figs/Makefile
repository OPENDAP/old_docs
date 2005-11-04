#--------------------------------------------------
# Makefile for the DODS/doc/api/pguide/figs/ directory.
# Converts the .fig files to .ps
#
# $Id$
#
#--------------------------------------------------

HTML_OPTIONS=-show_section_numbers

SOURCE = Connect.fig \
         DAS.fig \
         DDS.fig \
         DataDDS.fig \
         attrtable.fig \
         orig-client.fig \
         arch.fig \
         client-arch1.fig \
         client-arch2.fig \
         nest-attrtable.fig

# How does this work?
# PSTARGET = $(SOURCE:  %.fig= %.ps)
# EPSTARGET = $(SOURCE:  %.fig= %.eps)

GIFTARGET = Connect.gif \
           DAS.gif \
           DDS.gif \
           DataDDS.gif \
           attrtable.gif \
           orig-client.gif \
           arch.gif \
           client-arch1.gif \
           client-arch2.gif \
           nest-attrtable.gif

PSTARGET = Connect.ps \
           DAS.ps \
           DDS.ps \
           DataDDS.ps \
           attrtable.ps \
           orig-client.ps \
           arch.ps \
           client-arch1.ps \
           client-arch2.ps \
           nest-attrtable.ps

EPSTARGET = Connect.eps \
            DAS.eps \
            DDS.eps \
            DataDDS.eps \
            attrtable.eps \
            orig-client.eps \
            arch.eps \
            client-arch1.eps \
            client-arch2.eps \
            nest-attrtable.eps

# use TEXINPUTS from environment variable
#TEXINPUTS:=$(TEXINPUTS)/usr/local/teTeX/texmf/tex/latex/:
# This is my TEXINPUTS '.:/upc/dods/wwwDocs/DODS/doc/latex/:'

#-----
# Main targets
#-----
all: ps gif

gif: $(GIFTARGET)

ps: $(PSTARGET)

eps: $(EPSTARGET)

#-----
# PostScript targets
#-----
%.ps : %.fig
	fig2dev -L ps $*.fig  $@

%.eps : %.fig
	fig2dev -L ps $*.fig  $@

%.gif : %.fig
	fig2dev -L gif $*.fig $@

#-----
# Targets for cleaning
#-----
clean:
	-rm -f *~

cleanps: clean
	-rm -f *.ps

cleangif: clean
	-rm -f *.gif

cleaneps: clean
	-rm -f *.eps

distclean: clean cleanps cleangif
