TOP := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))../)
TARGET=molitvoslov_com
HTLATEX=htlatex
TARGET_DIR=target
TARGET_IMG_DIR=$(TARGET_DIR)/img
XSLTPROC=xsltproc --nonet
XSLT=$(TOP)/xslt
XML_CATALOG=$(XSLT)/catalog/catalog.xml
SCRIPTS=$(TOP)/scripts

.PHONY: site eps

site: eps $(TARGET_DIR)/$(TARGET).html

eps: $(TARGET_DIR) $(TARGET_IMG_DIR)/tall/*.eps $(TARGET_IMG_DIR)/wide/*.eps $(TARGET_IMG_DIR)/*.eps

$(TARGET_DIR): $(EPUB_DIR)/*
	#
	# create directory structure and copy template
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_IMG_DIR)/tall
	mkdir -p $(TARGET_IMG_DIR)/wide

$(TARGET_IMG_DIR)/*.eps: $(TOP)/img/*.jp*g $(TOP)/uzory/*.pdf
	cp $? $(@D)/
	for file in $?; do \
		fname=`basename $$file`; \
		cnv="convert $$file $(@D)/$${fname%.*}.eps"; \
		echo $$cnv; $$cnv; \
	done

$(TARGET_IMG_DIR)/tall/*.eps: $(TOP)/img/tall/*.jp*g
	cp $? $(@D)/
	for file in $?; do \
		fname=`basename $$file`; \
		cnv="convert $$file $(@D)/$${fname%.*}.eps"; \
		echo $$cnv; $$cnv; \
	done

$(TARGET_IMG_DIR)/wide/*.eps: $(TOP)/img/wide/*.jp*g
	cp $? $(@D)/
	for file in $?; do \
		fname=`basename $$file`; \
		cnv="convert $$file $(@D)/$${fname%.*}.eps"; \
		echo $$cnv; $$cnv; \
	done

$(TARGET)*.html: $(TOP)/*.tex $(TARGET).cfg $(TARGET).tex
	#
	# execute tex4ht process
	$(HTLATEX) $(TARGET).tex "$(TARGET)" " -cunihtf -utf8" ""
	
$(TARGET_DIR)/$(TARGET).html: $(TARGET)*.html
	for file in $?; do \
		tidy -w -q -ashtml -utf8 $$file | \
			sed 's;<a name="[-_\.[:alnum:]]*" id="[-_\.[:alnum:]]*"></a>;;' >$(TARGET_DIR)/$$file; \
	done

clean:
	rm -rf *.ps *.dvi *.aux *.toc *.idx *.ind *.ilg *.log *.out *.lof *.ptc* *.mtc* *.maf *.4ct *.4tc *.css *.html *.idv *.lg *.tmp *.xref
