#
# New standard DODS documentation Makefile (5/2001) ts.

# $Id$

# $Log: Makefile,v $
# Revision 1.7  2002/05/10 15:08:47  tom
# minimal changes
#
# Revision 1.6  2002/03/01 23:44:51  tom
# Added nv.tex
#
# Revision 1.5  2001/05/14 14:51:08  tom
# added redirect to .html processing
#
# Revision 1.4  2001/05/11 21:18:42  tom
# oops.  forgot a couple of entries to the .PRECIOUS directive
#
# Revision 1.3  2001/05/11 21:04:12  tom
# fixed what errors I found
#
# Revision 1.2  2001/05/10 16:19:54  tom
# fixed a few things
#

HOME_DIR=.
TEX_AUX_FILES=*.aux *.blg *.ent *.ilg *.log *.bbl *.ind \
              *.lot *.blg *.idx *.lof *.toc *.all
DODS_DOC=~/DODS-doc
# Customize the following for each new document.

# Edit the following to point to the directory where the hyperlatex
# output will go.  Do *NOT* use this file if the hyperlatex output
# doesn't get put in a subdirectory. (see "realclean" and ".html" for why).
SYNTH_HTML_DIR=synth
SYNTH_DEPENDS= synthesis.tex appI.tex appII.tex appIII.tex appIV.tex appV.tex

# For any file added to this one, make a definition like this, and you may 
# be able to avoid the specialized definitions shown here.
# synthesis.tex: $(SYNTH_DEPENDS)

synthesis.aux: $(SYNTH_DEPENDS)
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

synthesis.html: $(SYNTH_DEPENDS)
	hyperlatex $<
	cp $(SYNTH_HTML_DIR)/$@ $(SYNTH_HTML_DIR)/index.html
	@echo '$@ will contain a redirect to $(SYNTH_HTML_DIR)'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$(SYNTH_HTML_DIR)/index.html"></head><body>wrong page.</body></html>' >$@

# For a simple directory, containing a single document with no index
# or bibliography, you won't have to change anything else.  Otherwise,
# edit where noted.

# Stop GNU make from overzealous deletion of intermediate files.  We
# take care of these explicitly, with the clean-up rules.
.PRECIOUS: %.ps %.dvi %.pdf %.aux %.bbl %.ind %.tar \
	%.all %.ps.gz %.tar.gz

%.dvi: %.tex

# If there is a bibliography, add %.bbl to the following dependency
# list.  If there is an index, add %.ind.  If there is neither, 
# use this short version instead:
%.dvi: %.aux
	@echo 'no need to run LaTeX again'

#%.dvi: %.aux %.bbl %.ind
#	latex $*.tex
#	@while ( grep "Rerun to get cross-references" \
#	                $(subst .tex,.log,$<) >/dev/null ); do \
#	      echo '** Re-running LaTeX **'; \
#	      latex $<; \
#	done

%.ind: %.aux
	makeindex -s $(DODS_DOC)/latex/dods-book.ist $*.idx

%.bbl:  %.aux
	bibtex $*

%.ps: %.dvi
	dvips -o $@ $<

%.ps.gz: %.ps
	gzip -f $*.ps

%.pdf: %.ps
	ps2pdf $< $@

%.all: %.ps %.html %.pdf 
	echo "All dependent files are generated." > $@

%.tar:  %.all
	tar cf $@ $*

%.tar.gz: %.tar %.ps.gz %.pdf
	gzip -f $*.tar

# The %.aux and the %.html rules below are for default simple files.
# You probably need the more precise version, with an explicit list of
# dependencies.  Edit them and put them in above.
%.aux: %.tex
	latex $<
	@while ( grep "Rerun to get cross-references" \
	                $(subst .tex,.log,$<) >/dev/null ); do \
	      echo '** Re-running LaTeX **'; \
	      latex $<; \
	done

# The dvi file is in the following dependency list because some
# hyperlatex steps occasionally read the LaTeX byproduct files, like
# for the bibliography.  Also, LaTeX catches errors that hyperlatex
# does not.  If there's no bibliography, you can delete that
# dependency.  The html file in the current directory will contain a
# redirect to the sub-directory page.  Note that this will have the
# same name as the product of the hyperlatex run.  This file will not
# be included in the tar file products.
#
# This definition assumes that the html directory for `nv.tex' is `nv'. 
# This may not be true, in which case an explicit define is important.
%.html: %.tex %.dvi
	hyperlatex $<
	cp $*/$@ $*/index.html
	@echo '$@ will contain a redirect to $*'
	echo '<html><head><title>oops</title><META HTTP-EQUIV="Refresh" CONTENT="1;URL=$*/index.html"></head><body>wrong page.</body></html>' >$@

#
# Cleaning up the joint.
#
clean:
	-rm -f *.dvi *~
	-rm -f $(TEX_AUX_FILES)

# If there's more than one HTML directory, this needs to be changed.
realclean: clean
	-rm *.html
	-rm -rf $(SYNTH_HTML_DIR)

distclean: realclean
	-rm *.gz
	-rm *.pdf
	-rm *.ps
