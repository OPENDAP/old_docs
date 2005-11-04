#
# Makefile for various DODS guides. The books described here are as
# follows: 
#
#    install.tex - A guide for installing DODS servers

# $Id$

TEX_AUX_FILES=*.aux *.cls *.ilg *.log *.bbl *.ind *.lot *.blg *.idx *.lof *.toc
HTML_OPTIONS=-show_section_numbers

SERVER_DIR=.
INSTALL_CHAP_DIR=$(SERVER_DIR)/install
INSTALL_DEPENDS=$(INSTALL_CHAP_DIR)/install-def.tex
INSTALL_HTML_DIR=install-html
INSTALL_FIGS_DIR=$(INSTALL_CHAP_DIR)/figs

AGG_CHAP_DIR=$(SERVER_DIR)/agg
AGG_DEPENDS=$(AGG_CHAP_DIR)/agg-def.tex
AGG_HTML_DIR=agg-html
AGG_FIGS_DIR=$(AGG_CHAP_DIR)/figs

.PHONY: all ps pdf tar

all: pdf tar

pdf: install.pdf agg.pdf

tar: install.tar.gz agg.tar.gz


install.aux: $(INSTALL_DEPENDS)
	latex install.tex
	@while ( grep "Rerun to get cross-references" \
	                install.log >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex install.tex; \
	done


install.dvi: install.aux
	makeindex -s ../latex/dods-book.ist install.idx
	latex install.tex

install.ps: install.dvi
	dvips -o install.ps install.dvi

install.pdf: install.ps
	ps2pdf install.ps install.pdf

install.html: install.tex $(INSTALL_DEPENDS)
	hyperlatex $<
	cp $(INSTALL_HTML_DIR)/$@ $(INSTALL_HTML_DIR)/index.html
	@echo '$@ will contain a redirect to $(INSTALL_HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(INSTALL_HTML_DIR)/index.html"></head><body>Wrong page.  Wait a moment, please.</body></html>' >$@


install.tar:  install.html 
	tar cf $@ $(INSTALL_HTML_DIR)

agg.aux: $(AGG_DEPENDS)
	latex agg.tex
	@while ( grep "Rerun to get cross-references" \
	                agg.log >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex agg.tex; \
	done
	echo "%% done" >>agg.idx

agg.ind: agg.aux
	if ( grep "%% done" agg.idx ); \
	  then makeindex -s ../latex/dods-book.ist agg.idx ;\
	fi

agg.dvi: agg.ind
	latex agg.tex

agg.ps: agg.dvi
	dvips -o agg.ps agg.dvi

agg.pdf: agg.ps
	ps2pdf agg.ps agg.pdf



agg.html: agg.tex $(AGG_DEPENDS) 
	hyperlatex $<
	cp $(AGG_HTML_DIR)/$@ $(AGG_HTML_DIR)/index.html
	@echo '$@ will contain a redirect to $(AGG_HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(AGG_HTML_DIR)/index.html"></head><body>Wrong page, but close.  Please wait a moment.</body></html>' >$@

agg.tar: agg.html 
	tar cf $@ $(AGG_HTML_DIR)

# For a simple directory, containing a single document with no index
# or bibliography, you won't have to change anything else.  Otherwise,
# edit where noted.

# Stop GNU make from overzealous deletion of intermediate files.  We
# take care of these explicitly, with the clean-up rules.
.PRECIOUS: %.ps %.dvi %.pdf %.aux %.bbl %.ind %.tar \
	%.all %.ps.gz %.tar.gz

#
# Cleaning up the joint.
#

# Get rid of intermediate files
clean:
	-rm -f *.dvi *.ps *~
	-rm -f $(TEX_AUX_FILES)

# The html is in tar files, so they are possibly intermediate files.
realclean: clean
	-rm *.html
	-cd $(INSTALL_HTML_DIR) ; rm *.html *.gif 
	-cd $(AGG_HTML_DIR) ; rm *.html *.gif

# Get rid of everything except the source.
distclean: realclean
	-rm *.gz
	-rm *.tar
	-rm *.pdf

