TARGET = molitvoslov_com
INCLUDEONLY = 
LATEX = pdflatex
HTLATEX = htlatex
TARGET_DIR=target

EPUB_DIR=epub
EPUB_TEMPLATE=$(EPUB_DIR)/template
EPUBCHECK_JAR=$(wildcard $(EPUB_DIR)/epubcheck/epubcheck*jar)
JAVA=java
XSLTPROC=xsltproc --nonet

TARGET_EPUB_DIR=$(TARGET_DIR)/epub
TARGET_IMG_DIR=$(TARGET_DIR)/img
EPUB_HTML_DIR=$(TARGET_EPUB_DIR)/OEBPS
EPUB_META_DIR=$(TARGET_EPUB_DIR)/META-INF

XML_CATALOG=catalog/catalog.xml

#FETCH_DIR = import_`date '+%Y%m%d'`

.PHONY: all pdf epub eps images fetch

fetch:
	fdir=$(FETCH_DIR); \
	if [ "$$fdir" == "" ]; then \
		fdir=import_`date '+%Y%m%d'`; \
	fi; \
	mkdir -p $$fdir/img; \
	cd $$fdir && ../cnv2tex.py 0 http://www.molitvoslov.com '[["/o-molitve"], "/content/soderzhanie", ["/slovar.php"]]'

ifdef ONLY
	INCLUDEONLY = \includeonly{$(ONLY)}
endif

ARGS = "\nonstopmode $(INCLUDEONLY) \input{$(TARGET)}"

all: clean pdf epub

pdf: $(TARGET_DIR)/$(TARGET).pdf

epub: eps images $(TARGET_DIR)/$(TARGET).epub

eps: $(TARGET_EPUB_DIR) $(TARGET_IMG_DIR)/tall/*.eps $(TARGET_IMG_DIR)/wide/*.eps $(TARGET_IMG_DIR)/*.eps

images: $(TARGET_EPUB_DIR) $(EPUB_HTML_DIR)/images/tall/*.jp*g $(EPUB_HTML_DIR)/images/wide/*.jp*g $(EPUB_HTML_DIR)/images/*.jp*g $(EPUB_HTML_DIR)/images/*.png

$(TARGET_EPUB_DIR):  $(EPUB_DIR)/*
	#
	# create directory structure and copy template
	mkdir -p $(TARGET_EPUB_DIR)
	cp -vr $(EPUB_TEMPLATE)/* $(TARGET_EPUB_DIR)/
	mkdir -p $(TARGET_IMG_DIR)/tall
	mkdir -p $(TARGET_IMG_DIR)/wide

$(TARGET_DIR)/$(TARGET).pdf: *.tex img/* header/* uzory/*
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
	mv $(TARGET).pdf $(TARGET_DIR)/

$(TARGET_IMG_DIR)/*.eps: img/*.jp*g uzory/*.pdf
	cp $? $(@D)/
	for file in $?; do \
		fname=`basename $$file`; \
		cnv="convert $$file $(@D)/$${fname%.*}.eps"; \
		echo $$cnv; $$cnv; \
	done

$(TARGET_IMG_DIR)/tall/*.eps: img/tall/*.jp*g
	cp $? $(@D)/
	for file in $?; do \
		fname=`basename $$file`; \
		cnv="convert $$file $(@D)/$${fname%.*}.eps"; \
		echo $$cnv; $$cnv; \
	done

$(TARGET_IMG_DIR)/wide/*.eps: img/wide/*.jp*g
	cp $? $(@D)/
	for file in $?; do \
		fname=`basename $$file`; \
		cnv="convert $$file $(@D)/$${fname%.*}.eps"; \
		echo $$cnv; $$cnv; \
	done

$(EPUB_HTML_DIR)/images/*.png: uzory/uzor_begin_10.pdf uzory/uzor_begin_4.pdf uzory/uzor_begin_9.pdf uzory/uzor_end_3.pdf uzory/uzor_psaltyr.pdf uzory/cross.pdf
	for file in $?; do \
		fname=`basename $$file`; \
		resize_to="600x600"; \
		if expr "$$file" : ".*end"; then \
			resize_to="250x250"; \
		fi; \
		cnv="convert $$file -depth 8 -quality 10 -resize $${resize_to} $(@D)/$${fname%.*}.png"; \
		echo $$cnv; $$cnv; \
	done

$(EPUB_HTML_DIR)/images/tall/*.jp*g: img/tall/*.jp*g
	for file in $?; do \
		fname=`basename $$file`; \
		resize_to="500x500<"; \
		cnv="convert $$file -resize $${resize_to} $(@D)/$$fname"; \
		echo $$cnv; $$cnv; \
	done

$(EPUB_HTML_DIR)/images/wide/*.jp*g: img/wide/*.jp*g
	cp -v $? $(@D)/

$(EPUB_HTML_DIR)/images/*.jp*g: img/*.jp*g
	for file in $?; do \
		fname=`basename $$file`; \
		resize_to="500x500<"; \
		cnv="convert $$file -resize $${resize_to} $(@D)/$$fname"; \
		echo $$cnv; $$cnv; \
	done

$(TARGET)*.html: *.tex $(EPUB_DIR)/$(TARGET).cfg $(EPUB_DIR)/$(TARGET).tex
	#
	# execute tex4ht process
	$(HTLATEX) $(EPUB_DIR)/$(TARGET).tex "$(EPUB_DIR)/$(TARGET)" " -cunihtf -utf8" ""

$(EPUB_HTML_DIR)/$(TARGET)*.html: $(TARGET)*.html epub*.xslt epub*sh
	#
	# generate OPF and NCX files
	export XML_CATALOG_FILES=$(XML_CATALOG); \
	export BOOK_ID="http://www.molitvoslov.com/"; \
	export CREATOR="www.molitvoslov.com"; \
	export PUBLISHER="www.molitvoslov.com"; \
	export RIGHTS="Public domain"; \
	export TITLE="Молитвослов на всякую потребу"; \
	export BOOK_LANG="ru"; \
		./epubmkopf.sh $(TARGET) $(EPUB_HTML_DIR) >$(EPUB_HTML_DIR)/content.opf && \
	export XML_CATALOG_FILES=$(XML_CATALOG); \
	$(XSLTPROC) \
		--stringparam xml_lang "$$BOOK_LANG" \
		--stringparam dtb_uid "$$BOOK_ID" \
		--stringparam docTitle "$$TITLE" \
		--stringparam docAuthor "$$CREATOR" \
		--stringparam docFirstPage "$(TARGET).html" \
		--stringparam docFirstPageLabel "Оглавление" \
		-o $(EPUB_HTML_DIR)/toc.ncx epubmkncx.xslt $(TARGET).html && \
	./epubapplyxslt.sh $(TARGET) $(EPUB_HTML_DIR) epubxpgt.xslt
	#
	# rename image paths
	sed -i "s;$(TARGET_IMG_DIR);images;" $(EPUB_HTML_DIR)/$(TARGET)*.html
	
$(EPUB_HTML_DIR)/$(TARGET).css: $(EPUB_DIR)/$(TARGET).css
	#
	# copy our own css
	cp -v $(EPUB_DIR)/$(TARGET).css $(EPUB_HTML_DIR)/

$(TARGET_DIR)/$(TARGET).epub: $(EPUB_HTML_DIR)/$(TARGET)*.html $(EPUB_HTML_DIR)/$(TARGET).css images
	#
	# package everything
	cd $(TARGET_EPUB_DIR); \
	  zip -0Xq $(TARGET).epub mimetype; \
	  zip -Xr9Dq $(TARGET).epub META-INF OEBPS
	#
	# move the result and display contents
	mv $(TARGET_EPUB_DIR)/$(TARGET).epub $(TARGET_DIR)/
	unzip -l $(TARGET_DIR)/$(TARGET).epub

epubcheck: $(EPUBCHECK_JAR)
	$(JAVA) -jar $(EPUBCHECK_JAR) $(TARGET_DIR)/$(TARGET).epub

clean:
	rm -rf *.ps *.dvi *.aux *.toc *.idx *.ind *.ilg *.log *.out *.lof *.ptc* *.mtc* *.maf *.4ct *.4tc *.css *.html *.idv *.lg *.tmp *.xref $(TARGET_DIR)
