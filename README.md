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
```
