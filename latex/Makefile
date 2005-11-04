#
# Makefile for various DODS LaTeX and Hyperlatex styles.
#

# $Id$

# Modify the following:
HLX_DIR=/usr/lib/hyperlatex

# Shouldn't need to modify anything else.
LATEX_DIR=.

.PHONY: all install clean doc

all: dods-book.cls dods-paper.cls nasa-ese.cls dods-book2.cls 

doc:	dods-book2.dtx dods-book2.ind dods-book.dtx dods-book.ind \
        dods-paper.dtx mparhack.dvi vcode.dvi nasa-ese.dtx
	latex dods-book.dtx
	latex dods-book2.dtx
	latex dods-paper.dtx
	latex nasa-ese.dtx

dods-book.ind: dods-book.idx
	makeindex -s gind.ist dods-book.idx

dods-book.idx idx: dods-book.dtx
	latex dods-book.dtx

dods-book dods-book.hlx dods-book.cls: dods-book.dtx dods-book.ins
	latex dods-book.ins

dods-book2.ind: dods-book2.idx
	makeindex -s gind.ist dods-book2.idx

dods-book2.idx idx: dods-book2.dtx
	latex dods-book2.dtx

dods-book2 dods-book2.hlx dods-book2.cls: dods-book2.dtx dods-book2.ins
	latex dods-book2.ins

dods-paper.ind: dods-paper.idx
	makeindex -s gind.ist dods-paper.idx

dods-paper.idx idx: dods-paper.dtx
	latex dods-paper.dtx

dods-paper dods-paper.hlx dods-paper.cls: dods-paper.dtx dods-paper.ins
	latex dods-paper.ins

nasa-ese nasa-ese.hlx nasa-ese.cls: nasa-ese.dtx nasa-ese.ins
	latex nasa-ese.ins

vcode.dvi: vcode.dtx
	latex vcode.dtx
	makeindex -s gind.ist vcode.idx
	latex vcode.dtx

mparhack.dvi: mparhack.dtx
	latex mparhack.dtx
	makeindex -s gind.ist mparhack.idx
	latex mparhack.dtx

install: dods-book.hlx dods-book2.hlx dods-paper.hlx vcode.hlx
	cp dods-book.hlx $(HLX_DIR)
	cp dods-book2.hlx $(HLX_DIR)
	cp dods-paper.hlx $(HLX_DIR)
	cp emulate.hlx $(HLX_DIR)
	cp vcode.hlx $(HLX_DIR)

clean:	
	-rm -f *.aux
	-rm -f *.ind
	-rm -f *.idx
	-rm -f *.glo
	-rm -f *.ilg
	-rm -f *.log
	-rm -f *.toc

cleaner: clean
	-rm -f *.dvi
	-rm -f dods-book.cls
	-rm -f dods-book.hlx
	-rm -f dods-book.ist
	-rm -f dods-book2.cls
	-rm -f dods-book2.hlx
	-rm -f dods-book2.ist
	-rm -f dods-paper.cls
	-rm -f dods-paper.hlx
	-rm -f dods-paper.ist
	-rm -f vcode.sty
	-rm -f vcode.hlx
	-rm -f mparhack.sty

