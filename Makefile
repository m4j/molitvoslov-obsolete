TARGET = molitvoslov_com
INCLUDEONLY = 
LATEX = pdflatex
HTLATEX = htlatex
TARGET_DIR=target

EPUB_DIR=epub
EPUB_TEMPLATE=$(EPUB_DIR)/template
EPUBCHECK_JAR=$(wildcard $(EPUB_DIR)/epubcheck/epubcheck*jar)
JAVA=java

TARGET_EPUB_DIR=$(TARGET_DIR)/epub
TARGET_IMG_DIR=$(TARGET_DIR)/img
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

epub: $(TARGET_EPUB_DIR) eps images $(TARGET_DIR)/$(TARGET).epub

eps: $(TARGET_IMG_DIR)/tall/*.eps $(TARGET_IMG_DIR)/wide/*.eps $(TARGET_IMG_DIR)/*.eps $(TARGET_IMG_DIR)/tall/*.jpg $(TARGET_IMG_DIR)/wide/*.jpg $(TARGET_IMG_DIR)/*.jpg

images: $(EPUB_HTML_DIR)/images/tall/*.jpg $(EPUB_HTML_DIR)/images/wide/*.jpg $(EPUB_HTML_DIR)/images/*.jpg

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

$(TARGET_IMG_DIR)/*.eps: img/*.jpg uzory/*.pdf
	for file in $?; do \
		fname=`basename $$file`; \
		cnv="convert $$file $(@D)/$${fname%.*}.eps"; \
		echo $$cnv; $$cnv; \
	done

$(TARGET_IMG_DIR)/tall/*.eps: img/tall/*.jpg
	for file in $?; do \
		fname=`basename $$file`; \
		cnv="convert $$file $(@D)/$${fname%.*}.eps"; \
		echo $$cnv; $$cnv; \
	done

$(TARGET_IMG_DIR)/wide/*.eps: img/wide/*.jpg
	for file in $?; do \
		fname=`basename $$file`; \
		cnv="convert $$file $(@D)/$${fname%.*}.eps"; \
		echo $$cnv; $$cnv; \
	done

$(TARGET_IMG_DIR)/*.jpg: img/*.jpg uzory/*.pdf
	for file in $(filter %.jpg, $?); do \
		cp -v $$file $(@D); \
	done
	for file in $(filter %.pdf, $?); do \
		fname=`basename $$file`; \
		cnv="convert $$file $(@D)/$${fname%.*}.jpg"; \
		echo $$cnv; $$cnv; \
	done

$(TARGET_IMG_DIR)/tall/*.jpg: img/tall/*.jpg
	cp -v $? $(@D)/

$(TARGET_IMG_DIR)/wide/*.jpg: img/wide/*.jpg
	cp -v $? $(@D)/

$(EPUB_HTML_DIR)/images/*.jpg: $(TARGET_IMG_DIR)/*.jpg
	cp -v $? $(@D); \

$(EPUB_HTML_DIR)/images/tall/*.jpg: $(TARGET_IMG_DIR)/tall/*.jpg
	cp -v $? $(@D); \

$(EPUB_HTML_DIR)/images/wide/*.jpg: $(TARGET_IMG_DIR)/wide/*.jpg
	cp -v $? $(@D); \

$(TARGET_DIR)/$(TARGET).epub: *.tex $(EPUB)*
	#
	# execute tex4ht process
	$(HTLATEX) $(EPUB_DIR)/$(TARGET).tex "$(EPUB_DIR)/$(TARGET)" " -cunihtf -utf8" "-d$(EPUB_HTML_DIR)/"
	#
	# generate OPF file
	export XML_CATALOG_FILES=$(XML_CATALOG); \
	export BOOK_ID="http://www.molitvoslov.com/"; \
	export TITLE="Молитвослов на всякую потребу"; \
	  export BOOK_LANG="ru"; \
	  ./epubmkopf.sh $(TARGET) $(EPUB_HTML_DIR) >$(EPUB_HTML_DIR)/content.opf
	#
	# apply XSL transformation, generate NCX file
	export XML_CATALOG_FILES=$(XML_CATALOG); \
	  xsltproc -o $(EPUB_HTML_DIR)/toc.ncx epubmkncx.xslt $(EPUB_HTML_DIR)/$(TARGET).html && \
	  ./epubapplyxslt.sh $(TARGET) $(EPUB_HTML_DIR) epubxpgt.xslt
	#
	# rename image paths
	sed -i "s;$(TARGET_IMG_DIR);images;" $(EPUB_HTML_DIR)/$(TARGET)*.html
	#
	# copy our own css
	cp -v $(EPUB_DIR)/$(TARGET).css $(EPUB_HTML_DIR)/
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
