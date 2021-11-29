
#
# Commands
CAT ?= cat
CP ?= cp
GIT ?= git
LATEXMK ?= latexmk
LN ?= ln
MKDIR ?= mkdir
PDFLATEX ?= pdflatex
PDF2TXT ?= pdftotext
PERL ?= perl
RM ?= rm
SED ?= sed

#
# Variables
TEX_TRASH = $(wildcard *.log) \
            $(wildcard *.aux) \
            $(wildcard *.bbl) \
            $(wildcard *.bcf) \
            $(wildcard *.blg) \
            $(wildcard *-blx.bib) \
            $(wildcard *.fls) \
            $(wildcard *.fdb_latexmk) \
            $(wildcard *.run.xml) \
            $(wildcard *-text.tex) \
            $(wildcard *-text.txt) \
            $(wildcard *-text.pdf) \
            $(NULL)

DOC_TRASH = $(filter-out $(KEEP),$(wildcard *.pdf)) \
            $(ASSIGNMENT_TEXT_COPY) \
            $(NULL)

#
# Files
BIB_TEMPLATE := homework-template.bib
HW_TEMPLATE := homework-template.tex
KEEP := $(LOGO_FILE) JPaulReed-cv.pdf
LOGO_FILE := lund-university-logo1.pdf
ASSIGNMENT_TEXT_COPY := assignment.txt

#
# Rules
all: $(patsubst %.tex,%.pdf,$(wildcard *.tex))

%.pdf: %.tex %.bib
	$(LATEXMK) -pdf -latexoption=-halt-on-error $<

# This disgustingness:
#  1. removes a trailing / from DIR (if present),
#  2. removes all characters except the /'s, then
#  3. replaces those with '../', to create a proper directory prefix.
#  FML.
DIRPREFIX = $(shell echo "$(DIR)" | $(PERL) -nle 's:/?$$::; print;' | $(PERL) -nle 's:[\w\d]+::g; print;' | $(SED) -e 's:/:../:g')..

export TEXINPUTS = .:$(shell dirname $(realpath $(CURDIR)/Makefile))/includes:

setuphomework:
ifndef DIR
	$(error DIR variable must be defined for target setuphomework)
endif
	$(MKDIR) -p "$(DIR)" || true
	cd "$(DIR)" && $(LN) -s $(DIRPREFIX)/Makefile .
	$(CP) $(HW_TEMPLATE) $(DIR)/assignment.tex
	$(CP) $(BIB_TEMPLATE) $(DIR)/assignment.bib
	$(GIT) add "$(DIR)"
	$(GIT) commit "$(DIR)"

clean:
	$(RM) -f $(TEX_TRASH) $(DOC_TRASH) .DUMMY

textcopy:
	$(CAT) assignment.tex | $(PERL) -nle 's/\\(begin|end)\{linenumbers\}//g; s/\\parencite[^}]+?\}//g; s/\\footnote\{[^}]+?\}//g; print;' > assignment-text.tex
	$(PDFLATEX) assignment-text.tex
	$(PDF2TXT) -enc ASCII7 assignment-text.pdf
	$(CAT) assignment-text.txt | $(PERL) -nle 's/\f//g; s/^\d$$//g; print;' > $(ASSIGNMENT_TEXT_COPY)

sayit: $(ASSIGNMENT_TEXT_COPY)
	$(CAT) $(ASSIGNMENT_TEXT_COPY) | festival --tts


.PHONY: all clean setuphomework textcopy sayit
