RSCRIPT:=Rscript
JEKYLL:=jekyll

R_BUILD:=build.R
R_SERVE:=serve.R

POST_DIRS:= _drafts _posts
RMD_FILES:=$(foreach dir, $(POST_DIRS), $(shell find $(dir) -type f -iname '*.Rmd'))
RMD_TARGETS:=$(patsubst %.Rmd, %.md, $(RMD_FILES))

WRITE_GOOD_JS:=node_modules/write-good/bin/write-good.js

%.md : %.Rmd
	$(RSCRIPT) $(R_BUILD) $< $@

default: $(RMD_TARGETS)

.PHONY: build
build: default
	$(JEKYLL) build --drafts

.PHONY: serve
serve: $(R_SERVE)
	$(RSCRIPT) $<

.PHONY: clean
clean:
	$(JEKYLL) clean

$(WRITE_GOOD_JS):
	npm install write-good

.PHONY: write-good
write-good: $(WRITE_GOOD_JS)
	$(WRITE_GOOD_JS) $(RMD_FILES)
