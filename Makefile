TARGET = molitvoslov_com
INCLUDEONLY = 
LATEX = pdflatex
HTLATEX = htlatex
TARGET_DIR=target

EPUB_DIR=epub
EPUB_TEMPLATE=$(EPUB_DIR)/template

TARGET_EPUB_DIR=$(TARGET_DIR)/epub
TARGET_EPS_DIR=$(TARGET_DIR)/eps
EPUB_HTML_DIR=$(TARGET_EPUB_DIR)/OEBPS
EPUB_META_DIR=$(TARGET_EPUB_DIR)/META-INF

XML_CATALOG=catalog/catalog.xml

#FETCH_DIR = import_`date '+%Y%m%d'`

#fetch:
	#fdir=$(FETCH_DIR); \
	#if [ "x$$fdir" == "x" ]; then 		fdir=import_`date '+%Y%m%d'`; 	fi \
	#mkdir -p $$fdir; \
	#cd $$fdir; \
	#../cnv2tex.py 0 http://www.molitvoslov.com '[["/o-molitve"], "/content/soderzhanie", ["/slovar.php"]]'


ifdef ONLY
	INCLUDEONLY = \includeonly{$(ONLY)}
endif

ARGS = "\nonstopmode $(INCLUDEONLY) \input{$(TARGET)}"

all: clean pdf epub

pdf: $(TARGET_DIR)/$(TARGET).pdf

epub: $(TARGET_EPUB_DIR) | eps images $(TARGET_DIR)/$(TARGET).epub

eps: $(TARGET_EPS_DIR)/*.eps

images: $(EPUB_HTML_DIR)/images/*.jpg

$(TARGET_EPUB_DIR):  $(EPUB_TEMPLATE)
	#
	# create directory structure and copy template
	mkdir -p $(TARGET_EPUB_DIR) && cp -avr $(EPUB_TEMPLATE)/* $(TARGET_EPUB_DIR)/
	mkdir -p $(TARGET_EPS_DIR)

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

$(TARGET_EPS_DIR)/%.eps: img/%.jpg uzory/%.pdf
	for file in $?; do \
		fname=`basename $$file`; \
		cnv="convert $$file $(@D)/$${fname%.*}.eps"; \
		echo $$cnv; $$cnv; \
	done

$(EPUB_HTML_DIR)/images/*.jpg:: uzory/*.pdf
	for file in $?; do \
		fname=`basename $$file`; \
		cnv="convert $$file $(@D)/$${fname%.*}.jpg"; \
		echo $$cnv; $$cnv; \
	done

$(EPUB_HTML_DIR)/images/*.jpg:: img/*.jpg
	cp -v $? $(@D)/

$(TARGET_DIR)/$(TARGET).epub: *.tex $(EPUB) $(EPUB)*
	#
	# execute tex4ht process
	$(HTLATEX) $(EPUB_DIR)/$(TARGET).tex "$(EPUB_DIR)/$(TARGET)" " -cunihtf -utf8" "-d$(EPUB_HTML_DIR)/"
	#
	# generate OPF file
	export XML_CATALOG_FILES=$(XML_CATALOG); \
	export BOOK_ID="http://www.molitvoslov.com/"; \
	  export BOOK_LANG="ru"; \
	  ./epubmkopf.sh $(TARGET) $(EPUB_HTML_DIR) >$(EPUB_HTML_DIR)/content.opf
	#
	# apply XSL transformation, generate NCX file
	export XML_CATALOG_FILES=$(XML_CATALOG); \
	  ./epubapplyxslt.sh $(TARGET) $(EPUB_HTML_DIR) epubxpgt.xslt && \
	  xsltproc -o $(EPUB_HTML_DIR)/toc.ncx epubmkncx.xslt $(EPUB_HTML_DIR)/$(TARGET).html
	#
	# rename image paths
	sed -i "s;$(TARGET_EPS_DIR);images;" $(EPUB_HTML_DIR)/$(TARGET)*.html
	#
	# copy our own css
	cp -av $(EPUB_DIR)/$(TARGET).css $(EPUB_HTML_DIR)/
	#
	# package everything
	cd $(TARGET_EPUB_DIR); \
	  zip -0Xq $(TARGET).epub mimetype; \
	  zip -Xr9Dq $(TARGET).epub META-INF OEBPS
	#
	# move the result and display contents
	mv $(TARGET_EPUB_DIR)/$(TARGET).epub $(TARGET_DIR)/
	unzip -l $(TARGET_DIR)/$(TARGET).epub

clean:
	rm -rf *.ps *.dvi *.aux *.toc *.idx *.ind *.ilg *.log *.out *.lof *.ptc* *.mtc* *.maf *.4ct *.4tc *.css *.html *.idv *.lg *.tmp *.xref $(TARGET_DIR)
