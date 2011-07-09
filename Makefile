TARGET = molitvoslov_com
INCLUDEONLY = 
LATEX = pdflatex
FETCH_DIR = import_`date '+%Y%m%d'`

ifdef ONLY
	INCLUDEONLY = \includeonly{$(ONLY)}
endif

ARGS = "\nonstopmode $(INCLUDEONLY) \input{$(TARGET)}"

fetch:
	fdir=$(FETCH_DIR); \
	if [ "x$$fdir" == "x" ]; then 		fdir=import_`date '+%Y%m%d'`; 	fi \
	mkdir -p $$fdir; \
	cd $$fdir; \
	../cnv2tex.py 0 http://www.molitvoslov.com '[["/o-molitve"], "/content/soderzhanie", ["/slovar.php"]]'

all: clean pdf

pdf: $(TARGET).pdf

$(TARGET).pdf: *.tex img/* header/* uzory/*
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


clean:
	rm -f *.ps *.dvi *.aux *.toc *.idx *.ind *.ilg *.log *.out *.lof *.ptc* *.mtc* *.maf $(TARGET).pdf
