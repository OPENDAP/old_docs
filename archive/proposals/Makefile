#--------------------------------------------------
# Makefile for the DODS/doc/archive/proposal/ directory.
#
# $Id$
#
#--------------------------------------------------

CAN_DIR=.
CAN_HTML_DIR=can-97-mtpe-01-html

TEX_AUX_FILES=*.aux *.cls *.ilg *.log *.bbl *.ind *.lot *.blg *.idx *.lof *.toc
HTML_OPTIONS=-show_section_numbers

# use TEXINPUTS from environment variable
#TEXINPUTS:=$(TEXINPUTS)/usr/local/teTeX/texmf/tex/latex/:
# This is my TEXINPUTS '.:/upc/dods/wwwDocs/DODS/doc/latex/:'

#-----
# Main targets
#-----
all: ps html

ps: can-97-mtpe-01.ps

html: can-97-mtpe-01.html

#-----
# CAN-97-MTPE-01 (NASA CAN proposal) targets
#-----
can-97-mtpe-01 can-97-mtpe-01.dvi: can-97-mtpe-01.tex
	latex can-97-mtpe-01.tex
	latex can-97-mtpe-01.tex

can-97-mtpe-01.ps: can-97-mtpe-01.dvi
	dvips can-97-mtpe-01.dvi -o can-97-mtpe-01.ps

can-97-mtpe-01.html: can-97-mtpe-01.tex can-97-mtpe-01.dvi
	latex2html $(HTML_OPTIONS) -dir ${CAN_HTML_DIR} can-97-mtpe-01.tex 

#-----
# Targets for cleaning
#-----
clean:
	-rm -f $(TEX_AUX_FILES) *~ *.dvi

distclean: clean
	-rm -f -r *.ps can-97-mtpe-01-html

