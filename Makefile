
TEX_DIR = tex/
MD_DIR = md/
GFM_DIR = gfm/

TEX_FILES := $(wildcard ${TEX_DIR}*.tex)
MD_FILES := $(TEX_FILES:${TEX_DIR}%.tex=${MD_DIR}%.md)
GFM_FILES := $(TEX_FILES:${TEX_DIR}%.tex=${GFM_DIR}%.md)

all: md gfm

md: ${MD_FILES}

gfm: ${GFM_FILES}

${MD_DIR}%.md: ${TEX_DIR}%.tex
	mkdir -p ${MD_DIR}
	cp $< $@.tmp
	sed -i 's/\\\[/\n\\\[/; s/\\\]/\\\]\n/;' $@.tmp
	pandoc -s -f latex -t markdown_strict $@.tmp -o $@
	sed -i '/[^ ]\*\*[^ ]/s/\*\*//g' $@
	rm $@.tmp

SPACE = \&space;
DISPLAY_EQ = !\[equation\]\(https:\/\/latex.codecogs.com\/png.latex\?\\dpi{120}\&space;
INLINE_EQ = !\[equation\]\(https:\/\/latex.codecogs.com\/gif.latex\?\\inline\&space;
END_EQ = \)

${GFM_DIR}%.md: ${TEX_DIR}%.tex
	mkdir -p ${GFM_DIR}
	cp $< $@.tmp
	pandoc -s -f latex -t gfm $@.tmp -o $@
	sed -i 's/\\\[/\n\\\[/g; s/\\\]/\\\]\n/g; s/\\(/\n\\(/g; s/\\)/\\)\n/g' $@
	sed -i '/\\(\|\\\[/s/ /${SPACE}/g;' $@
	sed -i -z 's/\n\\(/${INLINE_EQ}/g; s/\\)\n/${END_EQ}/g' $@
	sed -i 's/\\\[/\n${DISPLAY_EQ}/; s/\\\]/${END_EQ}\n/' $@
	rm $@.tmp

clean:
	rm -f ${MD_FILES} ${GFM_FILES}
