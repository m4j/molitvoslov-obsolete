TARGET = molitvoslov_com
INCLUDEONLY = 
LATEX = pdflatex

ifdef ONLY
	INCLUDEONLY = \includeonly{$(ONLY)}
endif

ARGS = "\nonstopmode $(INCLUDEONLY) \input{$(TARGET)}"

all: clean pdf

pdf: $(TARGET).pdf

$(TARGET).pdf: *.tex img/* header/*.pdf uzory/*.pdf
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
