echo 'R' | xelatex cv
echo 'R' | xelatex cv
find . -maxdepth 1 -type f ! -name '*.sh' ! -name '*.tex' ! -name '*.bib' ! -name '*.cls' ! -name '*.git' ! -name '*.gitignore' ! -name '*.pdf' -delete
