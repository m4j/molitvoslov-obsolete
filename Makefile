TOP := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
TARGET=molitvoslov_com
INCLUDEONLY=
LATEX=pdflatex
PDFTK=pdftk
TARGET_DIR=target
VERSION_FILE=VERSION
VERSION=$(shell cat $(VERSION_FILE))
SCRIPTS=$(TOP)/scripts

FETCH_RESOURCES=[["/o-molitve"], "/content/soderzhanie", ["/slovar.php"]]

ifdef ONLY
INCLUDEONLY=\includeonly{$(ONLY)}
endif

.PHONY: all clean pdf fetch

fetch:
	fdir=import_`date '+%Y%m%d'`; \
	mkdir -p $$fdir/img && \
	cd $$fdir && $(SCRIPTS)/cnv2tex.py 0 http://www.molitvoslov.com '$(FETCH_RESOURCES)'

ARGS = "\nonstopmode $(INCLUDEONLY) \input{$(TARGET)}"

all: clean pdf

pdf: $(TARGET_DIR)/$(TARGET)-$(VERSION).pdf

$(TARGET_DIR)/header:
	mkdir -p $(TARGET_DIR)/header

$(TARGET_DIR)/header/%.pdf: header/%.pdf $(VERSION_FILE)
	# Edit title page pdf:
	# uncompress title page pdf and replace version string 0123456789 with
	# the contents of VERSION file and then recompress into target folder
	$(PDFTK) $< output - uncompress | sed "s/\[( 012345)3(6789)\]TJ/( $(VERSION))Tj/" | $(PDFTK) - output $@ compress

$(TARGET_DIR)/$(TARGET)-$(VERSION).pdf: *.tex img/* $(TARGET_DIR)/header $(TARGET_DIR)/header/$(TARGET)_a4.pdf uzory/*
	mkdir -p $(TARGET_DIR)
	$(LATEX) $(ARGS)
	#makeindex $(TARGET).idx
	#pdflatex $(TARGET).tex
	latex_count=5 ; \
	while egrep -s 'Rerun (LaTeX|to get cross-references right)' $(TARGET).log && [ $$latex_count -gt 0 ] ;\
		do \
		  echo "Rerunning latex...." ;\
		  $(LATEX) $(ARGS) ;\
		  latex_count=`expr $$latex_count - 1` ;\
		done
	mv $(TARGET).pdf $(TARGET_DIR)/$(TARGET)-$(VERSION).pdf

clean:
	rm -rf *~ *.ps *.dvi *.aux *.toc *.idx *.ind *.ilg *.log *.out *.lof *.ptc* *.mtc* *.maf *.4ct *.4tc *.css *.html *.idv *.lg *.tmp *.xref $(TARGET_DIR)
