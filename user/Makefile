#
# Makefile for various DODS guides. The books described here are as
# follows: 
#
#    guide.tex - The DODS User Guide
#    mgui.tex  - The DODS Matlab Browser User Guide
#    stds.tex  = The (Emerging) DODS Data Standards Guide

# $Id$

GUIDE_DIR=.
BOILER_DIR=../boiler
OPENDAP_HOME=../opendap_home

CHAP_DIR=$(GUIDE_DIR)/guide
CHAPTERS=$(CHAP_DIR)/preface.tex  $(CHAP_DIR)/ch01.tex $(CHAP_DIR)/ch02.tex \
	 $(CHAP_DIR)/ch03.tex $(CHAP_DIR)/ch04.tex  $(CHAP_DIR)/ch05.tex \
         $(CHAP_DIR)/ch06.tex $(CHAP_DIR)/appa.tex  $(CHAP_DIR)/glossary.tex \
         $(BOILER_DIR)/acronyms.tex

#	 $(CHAP_DIR)/ch07.tex $(CHAP_DIR)/ch08.tex  $(CHAP_DIR)/ch09.tex
#        $(CHAP_DIR)/ch10.tex $(CHAP_DIR)/ch11.tex 

QUICK_CHAP_DIR=$(GUIDE_DIR)/quick
QUICK_CHAPTERS=$(QUICK_CHAP_DIR)/quick-def.tex

MGUI_CHAP_DIR=$(GUIDE_DIR)/mgui
MGUI_CHAPTERS=$(MGUI_CHAP_DIR)/preface.tex  $(MGUI_CHAP_DIR)/ch01.tex \
	$(MGUI_CHAP_DIR)/ch02.tex $(MGUI_CHAP_DIR)/appa.tex \
	$(MGUI_CHAP_DIR)/ch03.tex $(MGUI_CHAP_DIR)/appb.tex 

STDS_CHAP_DIR=$(GUIDE_DIR)/stds
STDS_CHAPTERS=$(STDS_CHAP_DIR)/preface.tex  $(STDS_CHAP_DIR)/ch01.tex \
	$(STDS_CHAP_DIR)/ch02.tex $(STDS_CHAP_DIR)/appa.tex 

TEX_AUX_FILES=*.aux *.cls *.ilg *.log *.bbl *.ind *.lot *.blg *.idx *.lof *.toc
HTML_OPTIONS=-show_section_numbers


HTML_DIR=guide-html
MGUI_HTML_DIR=mgui-html
STDS_HTML_DIR=stds-html
QUICK_HTML_DIR=quick-html
REGEX_HTML_DIR=regex-html
HTML_DIRS=${HTML_DIR} ${MGUI_HTML_DIR} $(STDS_HTML_DIR)

.PHONY: guide mgui ps html all dbg mgui.all guide.all stds.all quick.all
all: ps html

tar: guide.tar mgui.tar stds.tar quick.tar regex.tar

ps: guide.ps mgui.ps stds.ps quick.ps regex.ps

html: guide.html mgui.html stds.html quick.html regex.html

mgui.all: mgui.html mgui.ps

guide.all: guide.html guide.ps

stds.all: stds.ps stds.html

quick.all: quick.ps quick.html

regex.all: regex.ps regex.html

guide guide.dvi:  guide.aux guide.ind guide.bbl
	latex guide.tex

guide.ind: guide.idx
	makeindex -s $(GUIDE_DIR)/../latex/dods-book.ist guide.idx

guide.idx: guide.aux
	latex guide.tex

guide.aux: guide.tex $(GUIDE_CHAPTERS)
	latex guide.tex
	latex guide.tex

guide.bbl: guide.aux
	bibtex guide
	latex guide.tex

install-guide: 
	@echo "Build target guide.all first, then cd to $(OPENDAP_HOME) and check in."
	cp guide.pdf $(OPENDAP_HOME)/pdf/
	cp -r guide-html/*.html guide-html/*.gif \
		$(OPENDAP_HOME)/user/guide-html/
	cp -r guide-html/DTD/*.dtd $(OPENDAP_HOME)/user/guide-html/DTD/

mgui mgui.dvi:  mgui.aux mgui.ind
	latex mgui.tex

mgui.ind: mgui.idx
	makeindex -s $(GUIDE_DIR)/../latex/dods-book.ist mgui.idx
	latex mgui.tex

mgui.idx: mgui.aux
	latex mgui.tex

mgui.aux: mgui.tex $(MGUI_CHAPTERS) 
	latex mgui.tex
	latex mgui.tex

dbg: mgui.tex $(MGUI_CHAPTERS) $(MGUI_CHAP_DIR)/mgui-def.tex
	latex mgui.tex

guide.ps: guide.dvi
	dvips guide.dvi -o guide.ps
	ps2pdf guide.ps guide.pdf
#	cp guide.ps $(HOME)/guide.ps

mgui.ps:  mgui.dvi
	dvips mgui.dvi -o mgui.ps

mgui.pdf: mgui.ps
	ps2pdf mgui.ps mgui.pdf

guide.html: guide.tex $(CHAPTERS)
	$(MAKE) html -C $(CHAP_DIR)
	hyperlatex  guide.tex
	cp guide-html/guide.html guide-html/index.html

mgui.html: mgui.tex 
	hyperlatex  mgui.tex
	cp mgui-html/mgui.html mgui-html/index.html

guide.tar: guide.ps guide.html
	gzip -f guide.ps
	tar cf guide.tar $(HTML_DIR)
	gzip -f guide.tar

mgui.tar: mgui.ps mgui.html mgui.pdf
	gzip -f mgui.ps
	tar cf mgui.tar $(MGUI_HTML_DIR)
	gzip -f mgui.tar

stds stds.dvi:  stds.aux stds.ind
	latex stds.tex

stds.ind: stds.idx
	makeindex -s $(GUIDE_DIR)/../latex/dods-book.ist stds.idx
	latex stds.tex

stds.idx: stds.aux
	latex stds.tex

stds.aux: stds.tex $(STDS_CHAPTERS) 
	latex stds.tex
	latex stds.tex

stds.ps:  stds.dvi
	dvips stds.dvi -o stds.ps

stds.html: stds.tex $(STDS_CHAPTERS) 
	hyperlatex  stds.tex
	cp stds-html/stds.html stds-html/index.html

stds.tar: stds.ps stds.html
	gzip -f stds.ps
	tar cf stds.tar $(STDS_HTML_DIR)
	gzip -f stds.tar

$(STDS_CHAP_DIR)/appa.tex  fff: $(STDS_CHAP_DIR)/names.dat
	$(STDS_CHAP_DIR)/names.pl $(STDS_CHAP_DIR)/names.dat \
	$(STDS_CHAP_DIR)/appa.tex

quick quick.dvi:  quick.aux quick.ind
	latex quick.tex

quick.ind: quick.idx
	makeindex -s $(GUIDE_DIR)/../latex/dods-book.ist quick.idx
	latex quick.tex

quick.idx: quick.aux
	latex quick.tex

quick.aux: quick.tex $(QUICK_CHAPTERS) 
	latex quick.tex
	latex quick.tex

quick.ps:  quick.dvi
	dvips quick.dvi -o quick.ps
	ps2pdf quick.ps quick.pdf

quick.html: quick.tex $(QUICK_CHAPTERS) 
	hyperlatex  quick.tex
	cp quick-html/quick.html quick-html/index.html

quick.tar: quick.ps quick.html $(QUICK_HTML_DIR)/index.html
	gzip -f quick.ps
	tar cf quick.tar $(QUICK_HTML_DIR)
	gzip -f quick.tar

regex regex.dvi:  regex.aux 
	latex regex.tex

#regex.ind: regex.idx
#	makeindex -s $(GUIDE_DIR)/../latex/dods-book.ist regex.idx
#	latex regex.tex
#
#regex.idx: regex.aux
#	latex regex.tex

regex.aux: regex.tex 
	latex regex.tex
	latex regex.tex

regex.ps:  regex.dvi
	dvips regex.dvi -o regex.ps
	ps2pdf regex.ps regex.pdf

regex.html: regex.tex 
	hyperlatex  regex.tex

$(REGEX_HTML_DIR)/index.html: regex.html
	cp regex-html/regex.html regex-html/index.html

regex.tar: regex.ps regex.html $(REGEX_HTML_DIR)/index.html
	gzip -f regex.ps
	tar cf regex.tar $(REGEX_HTML_DIR)
	gzip -f regex.tar

#
# Cleaning up the joint.
#
clean:
	-rm -f *.dvi *~

cleaner: clean
	-rm -f $(TEX_AUX_FILES)
	-cd $(MGUI_CHAP_DIR);rm -f *~;rm -f $(TEX_AUX_FILES)
	-cd $(STDS_CHAP_DIR);rm -f *~;rm -f $(TEX_AUX_FILES)
	-cd $(QUICK_CHAP_DIR);rm -f *~;rm -f $(TEX_AUX_FILES)
	-cd $(CHAP_DIR);rm -f *~;rm -f $(TEX_AUX_FILES)

realclean: cleaner
	-rm -f guide.ps mgui.ps stds.ps quick.ps
	$(MAKE) clean -C $(CHAP_DIR)
	-rm -f $(HTML_DIR)/*.html $(HTML_DIR)/*.gif 
	-rm -f $(MGUI_HTML_DIR)/*.html $(MGUI_HTML_DIR)/*.gif 
	-rm -f $(STDS_HTML_DIR)/*.html $(STDS_HTML_DIR)/*.gif 
	-rm -f $(QUICK_HTML_DIR)/*.html $(QUICK_HTML_DIR)/*.gif 
	-rm -f $(REGEX_HTML_DIR)/*.html $(REGEX_HTML_DIR)/*.gif 

distclean: realclean
	-rm *.gz

