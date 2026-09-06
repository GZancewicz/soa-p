.PHONY: all clean
all: main.pdf
main.pdf: main.tex sections/*.tex
	latexmk -pdf -interaction=nonstopmode main.tex
clean:
	latexmk -C
	rm -f sections/*.aux
