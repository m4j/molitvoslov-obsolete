TOP := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))../)
TARGET=molitvoslov_com
HTLATEX=htlatex
TARGET_DIR=target
IMG_DIR=$(TOP)/img
XSLTPROC=xsltproc --nonet
XSLT=$(TOP)/xslt
XML_CATALOG=$(XSLT)/catalog/catalog.xml
SCRIPTS=$(TOP)/scripts
FB2XSD=xsd/FictionBook2.1.xsd
IMAGE_PREFIX=img_
VERSION_FILE=$(TOP)/VERSION
#UNICODE4HF=$(shell kpsewhich unicode.4hf)

.PHONY: fb2 fb2check

fb2: $(TARGET_DIR) $(TARGET_DIR)/$(TARGET).fb2.zip

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
	
$(TARGET).html.0: $(TARGET).html
	cp -v $? $@
	# append cover image
	$(SCRIPTS)/fbcnvimg.sh "./" "$(IMAGE_PREFIX)" cover >>$@
	# append all other images used in the document
	sed -n 's/^.*<image xlink:href="#$(IMAGE_PREFIX)\(.*\)".*$$/\1/p' $? | xargs \
		$(SCRIPTS)/fbcnvimg.sh "$(IMG_DIR)" "$(IMAGE_PREFIX)" >>$@
	echo '</FictionBook>' >> $@

$(TARGET_DIR)/$(TARGET).fb2: $(TARGET).html.0
	#
	# call xsl transformation for finishing touch-ups
	export XML_CATALOG_FILES=$(XML_CATALOG); \
	$(XSLTPROC) \
		--stringparam document-info-version "`cat $(VERSION_FILE)`" \
		--stringparam cover-image-id "$(IMAGE_PREFIX)cover" \
		$(XSLT)/fb2.xslt $? >$@

$(TARGET_DIR)/$(TARGET).fb2.zip: $(TARGET_DIR)/$(TARGET).fb2
	#
	# package fb2.zip
	zip -X9Dq $@ $?
	
fb2check: $(TARGET_DIR)/$(TARGET).fb2
	xmllint --noout --schema $(FB2XSD) $?


clean:
	rm -rf *.ps *.dvi *.aux *.toc *.idx *.ind *.ilg *.log *.out *.lof *.ptc* *.mtc* *.maf *.4ct *.4tc *.css *.html* *.idv *.lg *.tmp *.xref $(TARGET_DIR)

