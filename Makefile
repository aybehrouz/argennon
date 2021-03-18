
PANDOC = pandoc --columns=120 -s -f latex

TEX_DIR = tex/
MD_DIR = md/
GFM_DIR = gfm/
HTML_DIR = htm/

TEX_FILES := $(wildcard ${TEX_DIR}*.tex)
MD_FILES := $(TEX_FILES:${TEX_DIR}%.tex=${MD_DIR}%.md)
GFM_FILES := $(TEX_FILES:${TEX_DIR}%.tex=${GFM_DIR}%.md)
HTML_FILES := $(TEX_FILES:${TEX_DIR}%.tex=${HTML_DIR}%.html)

all: md gfm html

md: ${MD_FILES}

gfm: ${GFM_FILES}

html: ${HTML_FILES}

${TEX_DIR}%.tmp: ${TEX_DIR}%.tex
	cp $< $@
	sed -i 's/\\\[/\n\\\[/; s/\\\]/\\\]\n/; s/\\end{algorithm}/@\n/; s/%\\/\n\\/' $@
	sed -i -z 's/\\begin{algorithm}[^@]*@//g; s/\\ref{[^}]*}//g' $@

${HTML_DIR}%.html: ${TEX_DIR}%.tmp
	mkdir -p ${HTML_DIR}
	${PANDOC} --mathjax='https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js' $< -o $@

${MD_DIR}%.md: ${TEX_DIR}%.tmp
	mkdir -p ${MD_DIR}
	${PANDOC} -t markdown_strict $< -o $@
	sed -i '/[^ ]\*\*[^ ]/s/\*\*//g' $@
	cp $@ proposal.md

#${GFM_DIR}%.md: ${TEX_DIR}%.tmp
#	mkdir -p ${GFM_DIR}
#	${PANDOC} --webtex -t gfm $< -o $@

SPACE = \&space;
DISPLAY_EQ = !\[equation\]\(https:\/\/latex.codecogs.com\/gif.latex\?\\dpi{120}\&space;
INLINE_EQ = !\[equation\]\(https:\/\/latex.codecogs.com\/gif.latex\?\\inline\&space;
END_EQ = \)

${GFM_DIR}%.md: ${TEX_DIR}%.tmp
	mkdir -p ${GFM_DIR}
	${PANDOC} -t gfm $< -o $@
	sed -i 's/\\\[/\n\\\[/g; s/\\\]/\\\]\n/g; s/\\(/\n\\(/g; s/\\)/\\)\n/g' $@
	sed -i '/\\(\|\\\[/s/ /${SPACE}/g;' $@
	sed -i -z 's/\n\\(/${INLINE_EQ}/g; s/\\)\n/${END_EQ}/g' $@
	sed -i 's/\\\[/\n${DISPLAY_EQ}/; s/\\\]/${END_EQ}\n/' $@

clean:
	rm -fr ${HTML_DIR} ${MD_DIR} ${GFM_DIR}
