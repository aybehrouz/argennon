
TEX_DIR = tex/
MD_DIR = md/

TEX_FILES := $(wildcard ${TEX_DIR}*.tex)
MD_FILES := $(TEX_FILES:${TEX_DIR}%.tex=${MD_DIR}%.md)

md: ${MD_FILES}

${MD_DIR}%.md: ${TEX_DIR}%.tex
	cp $< $@.tmp
	sed -i 's|\\\[|\n\\\[|; s|\\\]|\\\]\n|' $@.tmp
	pandoc -s -f latex -t markdown_strict $@.tmp -o $@
	sed -i 's|\\\[|\n\\\[|; s|\\\]|\\\]\n|' $@
	rm $@.tmp
clean:
	rm -f ${MD_FILES}
