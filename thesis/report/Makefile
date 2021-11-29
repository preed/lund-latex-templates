
#
# Commands
CAT ?= cat
CP ?= cp
DATE ?= date
EXIFTOOL ?= exiftool
GIT ?= git
GREP ?= grep
GS ?= gs
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
            $(wildcard *.lof) \
            $(wildcard *.lot) \
            $(wildcard *-text.tex) \
            $(wildcard *-text.txt) \
            $(wildcard *-text.pdf) \
            $(wildcard *.toc) \
            $(NULL)

DOC_TRASH = $(filter-out $(KEEP),$(wildcard *.pdf)) \
            $(wildcard *.pdf_original) \
            $(GIT_HASH_MARKER) \
            $(ASSIGNMENT_TEXT_COPY) \
            $(NULL)

#
# Files
BIB_TEMPLATE := homework-template.bib
HW_TEMPLATE := homework-template.tex
KEEP := $(LOGO_FILE) \
        chart-orgsize-vs-artifact-dist.pdf \
        chart-orgsize-vs-availability.pdf \
        chart-orgsize-vs-templateuse.pdf \
        chart-orgsize-vs-templateuse-types.pdf \
        interview-guide-p1.pdf \
        interview-guide-p2.pdf \
        lit-review-diagram.pdf \
        lund-cover-page.pdf \
        methodology-diagram.pdf \
        pm-template-facilitator.pdf \
        pm-template-record-keeper.pdf \
        pm-template-signpost.pdf \
        $(NULL)

LOGO_FILE := lund-university-logo1.pdf
ASSIGNMENT_TEXT_COPY := assignment.txt

GIT_HASH_MARKER := git-hash.txt
TODAY = $(shell $(DATE) +%Y%m%d)

DRAFT_THESIS_FILE = jpaulreed-thesis-DRAFT-$(TODAY).pdf
FINAL_THESIS_FILE = jpaulreed-lund-thesis-v1_1.pdf

#
# Rules

# For final.
all: $(FINAL_THESIS_FILE)

# For drafts...
#all: $(DRAFT_THESIS_FILE)

# Note the ordering of these dependencies matters (because we use $^ in the
# rule)
$(DRAFT_THESIS_FILE) $(FINAL_THESIS_FILE): lund-cover-page.pdf title-page.pdf abstract-page.pdf thesis.pdf
	$(GS) -dBATCH -dNOPAUSE -q -dPDFSETTINGS=/prepress -dEmbedAllFonts=true -dAutoRotatePages=/None -sDEVICE=pdfwrite -sOutputFile=$@ $^
	$(EXIFTOOL) -Title="Maps, Context, and Tribal Knowledge: On the Structure and Use of Post-Incident Analysis Artifacts in Software Development and Operations" $@

thesis.pdf: $(wildcard *.tex) thesis.bib r-analysis.r r-analysis-notable.r $(KEEP)
	$(LATEXMK) -pdf -latexoption=-halt-on-error thesis.tex

title-page.pdf: title-page.tex
	$(LATEXMK) -pdf -latexoption=-halt-on-error $^

abstract-page.pdf: abstract-page.tex
	$(RM) $(GIT_HASH_MARKER)
	$(GIT) rev-parse HEAD | $(GREP) -Eo '^\w{7}' > $(GIT_HASH_MARKER)
	$(LATEXMK) -pdf -latexoption=-halt-on-error $^

# This disgustingness:
#  1. removes a trailing / from DIR (if present),
#  2. removes all characters except the /'s, then
#  3. replaces those with '../', to create a proper directory prefix.
#  FML.
DIRPREFIX = $(shell echo "$(DIR)" | $(PERL) -nle 's:/?$$::; print;' | $(PERL) -nle 's:[\w\d]+::g; print;' | $(SED) -e 's:/:../:g')..

export TEXINPUTS = .:$(CURDIR)/../../includes:

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
