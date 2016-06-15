#--------------------------------------------------
# Makefile for the DODS/doc/archive/design/ddd-figs/ directory.
#
# $Id$
#
#--------------------------------------------------

HTML_OPTIONS=-show_section_numbers

SOURCE = api-rpc.fig \
         api-server.fig \
         data-resources.fig \
         dods-server.fig \
         fig3-serv-conf2.fig \
         fig4-trans-ds2.fig \
         fig5-df-serv2.fig \
         glenn-2.fig \
         http-interface.fig \
         jimg-multi-api3.fig \
         new-trans-serv.fig \
         prog2client-server.fig \
         prog2client-server2.fig \
         simple-server.fig \
         stand-alone2.fig \
         stand-alone3.fig

# How does this work?
# PSTARGET = $(SOURCE:  %.fig= %.ps)
# EPSTARGET = $(SOURCE:  %.fig= %.eps)

PSTARGET = api-rpc.ps \
           api-server.ps \
           data-resources.ps \
           dods-server.ps \
           fig3-serv-conf2.ps \
           fig4-trans-ds2.ps \
           fig5-df-serv2.ps \
           glenn-2.ps \
           http-interface.ps \
           jimg-multi-api3.ps \
           new-trans-serv.ps \
           prog2client-server.ps \
           prog2client-server2.ps \
           simple-server.ps \
           stand-alone2.ps \
           stand-alone3.ps

EPSTARGET = api-rpc.eps \
            api-server.eps \
            data-resources.eps \
            dods-server.eps \
            fig3-serv-conf2.eps \
            fig4-trans-ds2.eps \
            fig5-df-serv2.eps \
            glenn-2.eps \
            http-interface.eps \
            jimg-multi-api3.eps \
            new-trans-serv.eps \
            prog2client-server.eps \
            prog2client-server2.eps \
            simple-server.eps \
            stand-alone2.eps \
            stand-alone3.eps

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
