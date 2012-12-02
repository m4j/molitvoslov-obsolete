TOP := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))../)
TARGET=molitvoslov_com
HTLATEX=htlatex
TARGET_DIR=target
IMG_DIR=$(TOP)/img
XSLTPROC=xsltproc --nonet
XSLT=$(TOP)/xslt
XML_CATALOG=$(XSLT)/catalog/catalog.xml
SCRIPTS=$(TOP)/scripts
#UNICODE4HF=$(shell kpsewhich unicode.4hf)

.PHONY: fb2

fb2: $(TARGET_DIR) $(TARGET_DIR)/$(TARGET).fb2

$(TARGET_DIR):
	#
	# create directory structure and copy template
	mkdir -p $(TARGET_DIR)

#unicode.4hf: $(UNICODE4HF)
	# override unicode to html entities table
	# because character entities like &hellip; do not work well
	# for fb2...
	#sed "s/^'\([&\#;[:alnum:]]*\)'.*$/'\1' '' '\1' ''/" $? >$@

$(TARGET).html: $(TOP)/*.tex $(TARGET).cfg $(TARGET).tex unicode.4hf
	#
	# execute tex4ht process
	$(HTLATEX) $(TARGET).tex "$(TARGET)" " -cunihtf -utf8" ""
	
$(TARGET_DIR)/$(TARGET).fb2: $(TARGET).html
	cp -v $? $@
	cp cover.png $(TARGET_DIR)/
	$(SCRIPTS)/fbcnvimg.sh $(TARGET_DIR) cover >>$@
	sed -n 's/^.*<image xlink:href="#\(.*\)".*$$/\1/p' $? | xargs $(SCRIPTS)/fbcnvimg.sh $(IMG_DIR) >>$@
	echo '</FictionBook>' >> $@
	#
	# package fb2.zip
	zip -X9Dq $@.zip $@

clean:
	rm -rf *.ps *.dvi *.aux *.toc *.idx *.ind *.ilg *.log *.out *.lof *.ptc* *.mtc* *.maf *.4ct *.4tc *.css *.html *.idv *.lg *.tmp *.xref $(TARGET_DIR)

