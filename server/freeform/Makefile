#
# Makefile for various DODS guides. The books described here are as
# follows: 
#
#    ff.tex - The DODS FreeForm ND Server User Guide

# $Id$

FF_DIR=.
FF_CHAP_DIR=$(FF_DIR)/ff
FF_CHAPTERS= $(FF_CHAP_DIR)/arrayfmt.tex \
          $(FF_CHAP_DIR)/convs.tex \
          $(FF_CHAP_DIR)/convvars.tex \
          $(FF_CHAP_DIR)/datachk.tex \
          $(FF_CHAP_DIR)/errors.tex \
          $(FF_CHAP_DIR)/ff-server.tex \
          $(FF_CHAP_DIR)/ffapps.tex \
          $(FF_CHAP_DIR)/fmtconv.tex \
          $(FF_CHAP_DIR)/hdfutils.tex \
          $(FF_CHAP_DIR)/hdrfmts.tex \
          $(FF_CHAP_DIR)/intro.tex \
          $(FF_CHAP_DIR)/preface.tex \
          $(FF_CHAP_DIR)/query.tex \
          $(FF_CHAP_DIR)/quick.tex \
          $(FF_CHAP_DIR)/tblfmt.tex \
          $(FF_CHAP_DIR)/varnames.tex 

DFF_CHAPTERS= $(FF_CHAP_DIR)/arrayfmt.tex \
          $(FF_CHAP_DIR)/convs.tex \
          $(FF_CHAP_DIR)/datachk.tex \
          $(FF_CHAP_DIR)/errors.tex \
          $(FF_CHAP_DIR)/ff-server.tex \
          $(FF_CHAP_DIR)/fmtconv.tex \
          $(FF_CHAP_DIR)/hdfutils.tex \
          $(FF_CHAP_DIR)/hdrfmts.tex \
          $(FF_CHAP_DIR)/dintro.tex \
          $(FF_CHAP_DIR)/preface.tex \
          $(FF_CHAP_DIR)/query.tex \
          $(FF_CHAP_DIR)/dquick.tex \
          $(FF_CHAP_DIR)/tblfmt.tex 

TEX_AUX_FILES=*.aux *.cls *.ilg *.log *.bbl *.ind *.lot *.blg *.idx *.lof *.toc
HTML_OPTIONS=-show_section_numbers

FF_HTML_DIR=ff-html
DFF_HTML_DIR=dff-html

.PHONY: pdf html tar
all: tar pdf

pdf: ff.pdf dff.pdf

html: ff.html dff.html

tar: dff.tar.gz ff.tar.gz

# dff.tex is the DODS FreeForm Server Manual

dff.aux: dff.tex $(DFF_CHAPTERS)
	latex dff.tex
	@while ( grep "Rerun to get cross-references" \
	                dff.log >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex dff.tex; \
	done
	echo "%% done" >>dff.idx

dff.ind: dff.aux
	if ( grep "%% done" dff.idx ); \
	  then makeindex -s ../../latex/dods-book.ist dff.idx ;\
	fi

dff.dvi: dff.ind
	latex dff.tex

dff.ps: dff.dvi
	dvips -o dff.ps dff.dvi

dff.pdf: dff.ps
	ps2pdf dff.ps dff.pdf


dff.html: dff.tex $(DFF_CHAPTERS) 
	hyperlatex $<
	cp $(DFF_HTML_DIR)/$@ $(DFF_HTML_DIR)/index.html
	@echo '$@ will contain a redirect to $(DFF_HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(DFF_HTML_DIR)/index.html"></head><body>Wrong page, but close.  Please wait a moment.</body></html>' >$@

dff.tar: dff.html 
	tar cf $@ $(DFF_HTML_DIR)

dff.tar.gz: dff.tar
	gzip dff.tar

# The following is for the `pure' FreeForm manual.

ff.aux: ff.tex $(FF_CHAPTERS)
	latex ff.tex
	@while ( grep "Rerun to get cross-references" \
	                ff.log >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex ff.tex; \
	done
	echo "%% done" >>ff.idx

ff.ind: ff.aux
	if ( grep "%% done" ff.idx ); \
	  then makeindex -s ../../latex/dods-book.ist ff.idx ;\
	fi

ff.dvi: ff.ind
	latex ff.tex

ff.ps: ff.dvi
	dvips -o ff.ps ff.dvi

ff.pdf: ff.ps
	ps2pdf ff.ps ff.pdf


ff.html: ff.tex $(FF_CHAPTERS) 
	hyperlatex $<
	cp $(FF_HTML_DIR)/$@ $(FF_HTML_DIR)/index.html
	@echo '$@ will contain a redirect to $(FF_HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(FF_HTML_DIR)/index.html"></head><body>Wrong page, but close.  Please wait a moment.</body></html>' >$@

ff.tar: ff.html 
	tar cf $@ $(FF_HTML_DIR)

ff.tar.gz: ff.tar
	gzip ff.tar
#
# Cleaning up the joint.
#
clean:
	-rm -f *.dvi *.ps *~
	-rm -f $(TEX_AUX_FILES)

cleaner: clean
	-cd $(FF_CHAP_DIR);rm -f *~;rm -f $(TEX_AUX_FILES)
	-cd $(DFF_CHAP_DIR);rm -f *~;rm -f $(TEX_AUX_FILES)

distclean: cleaner
	-rm -f ff.html
	-rm -f dff.html
	-rm -f -r $(FF_HTML_DIR)
	-rm -f -r $(DFF_HTML_DIR)

realclean: distclean cleaner
	-rm -f ff.tar.gz
	-rm -f ff.pdf
	-rm -f dff.tar.gz
	-rm -f dff.pdf

