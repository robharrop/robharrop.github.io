RSCRIPT:=Rscript
JEKYLL:=jekyll

R_BUILD:=build.R
R_SERVE:=serve.R

POST_DIRS:= _drafts _posts
RMD_FILES:=$(foreach dir, $(POST_DIRS), $(shell find $(dir) -type f -iname '*.Rmd'))
RMD_TARGETS:=$(patsubst %.Rmd, %.md, $(RMD_FILES))

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
	rm $(RMD_TARGETS)
	$(JEKYLL) clean
