# SOA Exam P study program

Syllabus: `2026-09-p-syllabus.pdf` (September 2026 sitting).

## Layout

```
primer/
  topic1-general-probability/   Topic 1 (23-30%): outcomes (a)-(g), one section file each
    main.tex                    shared preamble, boxes (example/solution/keyfact/trap/practice)
    sections/a-*.tex ... g-*.tex
    Makefile                    `make` builds main.pdf with latexmk
```

Topics 2 (Univariate Random Variables, 44-50%) and 3 (Multivariate Random
Variables, 23-30%) follow the same layout when started.

```
sample-exam/
  sample-exam-p.md              SOA Exam P sample exam captured from dki.io/ab640089 (2026-09-06):
                                197 questions in 9 banks, answer choices, correct answer, solution text
  images/                       solution math and figures referenced from the markdown (209 files)
  latex/                        LaTeX transcription of the same exam, image math typeset, figures redrawn
    main.tex                    title page, one \section per bank
    preamble.tex                packages and macros (\question, choices, \correct, solution)
    sections/bank1.tex ... bank9.tex
    Makefile                    `make` builds main.pdf with latexmk
```

## Browser version (GitHub Pages)

`tools/build-site.sh` converts every `primer/topic*/main.tex` to HTML with pandoc
(MathJax for the math, `tools/boxes.lua` for the example/solution/keyfact/trap/practice
boxes, `tools/style.css` for the look) and writes the result to `site/`, one page per
topic, with the topic PDF alongside and an index page. `site/` is not committed.

`.github/workflows/pages.yml` runs the same script on every push to `main` and
deploys `site/` to GitHub Pages. Local build:

```
tools/build-site.sh && open site/index.html
```
