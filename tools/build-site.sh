#!/usr/bin/env bash
# Build the browser-readable site from the LaTeX primers into ./site
# (one page per primer/topicN-*/main.tex, its PDF alongside, and an index).
# Requires pandoc >= 3.0. Run from the repo root: tools/build-site.sh
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/site"
tools="$root/tools"
rm -rf "$out"
mkdir -p "$out"
cp "$tools/style.css" "$out/style.css"

nav_for() { # $1 = relative path to site root, $2 = optional PDF link
  printf '<nav class="site"><a href="%sindex.html">SOA Exam P primer</a>' "$1"
  [ -n "${2:-}" ] && printf '<a href="%s">PDF of this topic</a>' "$2"
  printf '<span class="spacer"></span><a href="https://github.com/GZancewicz/soa-p">Source</a></nav>\n'
}
footer='<footer class="site">Built from the LaTeX sources with pandoc. Math is rendered by MathJax.</footer>'

topics=()
for dir in "$root"/primer/topic*/; do
  [ -f "$dir/main.tex" ] || continue
  name="$(basename "$dir")"
  mkdir -p "$out/$name"
  # Keep the optional box title: \begin{example}[T] -> \begin{example}\begin{boxtitle}T\end{boxtitle}
  # Inline \input{...} so the sed pass sees every section (pandoc would resolve them anyway).
  work="$(mktemp -d)"
  ( cd "$dir" && sed -E 's/\\begin\{(example|keyfact|trap|practice|solution)\}\[([^]]*)\]/\\begin{\1}\\begin{boxtitle}\2\\end{boxtitle}/' main.tex > "$work/main.tex" \
    && cp -R sections "$work/sections" \
    && for f in "$work"/sections/*.tex; do sed -E -i.bak 's/\\begin\{(example|keyfact|trap|practice|solution)\}\[([^]]*)\]/\\begin{\1}\\begin{boxtitle}\2\\end{boxtitle}/' "$f"; rm -f "$f.bak"; done )
  nav_for "../" "main.pdf" > "$work/nav.html"
  printf '%s\n' "$footer" > "$work/footer.html"
  ( cd "$work" && pandoc main.tex -f latex -t html5 --standalone --mathjax \
      --toc --toc-depth=2 --number-sections \
      --lua-filter "$tools/boxes.lua" \
      --css "../style.css" \
      --include-before-body nav.html --include-after-body footer.html \
      --metadata pagetitle="SOA Exam P Study Primer" \
      -o "$out/$name/index.html" )
  [ -f "$dir/main.pdf" ] && cp "$dir/main.pdf" "$out/$name/main.pdf"
  rm -rf "$work"
  # "Topic 1: General Probability (23--30\% of the exam)" from the \title line
  label="$(grep -oE 'Topic [0-9]+: [^(]*\([^)]*\)' "$dir/main.tex" | head -1 | sed -E 's/--/–/; s/\\%/%/; s/ +$//')"
  topics+=("$name|$label")
done

{
  cat <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>SOA Exam P Study Primer</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
HTML
  nav_for ""
  cat <<HTML
<header id="title-block-header">
<h1 class="title">SOA Exam P Study Primer</h1>
<p class="subtitle">September 2026 syllabus. One primer per topic, one section per learning outcome.</p>
</header>
<main>
<ul class="topics">
HTML
  for t in "${topics[@]}"; do
    name="${t%%|*}"; label="${t#*|}"
    title="${label%% (*}"; weight="${label#* (}"; weight="${weight%)}"
    printf '<li><a href="%s/index.html"><strong>%s</strong></a> <span class="weight">%s</span>' "$name" "$title" "$weight"
    [ -f "$out/$name/main.pdf" ] && printf '<div class="links"><a href="%s/main.pdf">PDF</a></div>' "$name"
    printf '</li>\n'
  done
  cat <<HTML
</ul>
<p>Topics 2 (Univariate Random Variables, 44–50%) and 3 (Multivariate Random Variables, 23–30%) appear here when drafted.</p>
</main>
$footer
</body>
</html>
HTML
} > "$out/index.html"
touch "$out/.nojekyll"
echo "Built $out:"; find "$out" -type f | sed "s|$out/||"
