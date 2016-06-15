#
#  A makefile for all the supported DODS documentation.
#
#    Note that this does not mean that this is all the accurate
#    documentation.  It only means that the documents mentioned here
#    are the ones that must be regularly updated and fixed.  The white
#    papers and proposals included in the documentation tree are
#    written once, and usually don't need to be re-generated.
#
#  $Id$
#
#
API_DIR=./api
USER_DIR=./user
SERVERS_DIR=$(USER_DIR)/servers

.PHONY: ff dff guide mgui pguide pref stds

all: ff dff guide mgui pguide pref stds

guide: $(USER_DIR)/guide.tex
	$(MAKE) guide.tar -C $(USER_DIR)

mgui: $(USER_DIR)/mgui.tex
	$(MAKE) mgui.tar -C $(USER_DIR)

stds: $(USER_DIR)/stds.tex
	$(MAKE) stds.tar -C $(USER_DIR)

pguide: $(API_DIR)/pguide.tex
	$(MAKE) pguide.tar.gz -C $(API_DIR)

pref: 
	$(MAKE) pref.tar.gz -C $(API_DIR)

dff: $(SERVERS_DIR)/dff.tex
	$(MAKE) dff.tar -C $(SERVERS_DIR)

ff: $(SERVERS_DIR)/ff.tex
	$(MAKE) ff.tar -C $(SERVERS_DIR)
