%.pdf : %.svg
	./svg-to-pdf $<

%.svg : %.dia
	dia $< --export=$@

%.pdf : %.dot
	dot -Tpdf $< > $@

INKSPACE_SVGS = \
	inkscape/gdb-modules-highlight-native.svg \
	inkscape/gdb-modules-highlight-rsp-and-native.svg \
	inkscape/gdb-vs-gdbserver.svg

DIA_FILES = \
	dia/gdb-async-event-loop.dia \
	dia/gdb-sync-event-loop.dia

INKSPACE_PDFS=$(INKSPACE_SVGS:.svg=.pdf)
DIA_PDFS=$(DIA_FILES:.dia=.pdf)
DIA_SVGS=$(DIA_FILES:.dia=.svg)

PDFS=${INKSPACE_PDFS} ${DIA_PDFS} ${DOT_PDFS}

DITAA_IMGS=gdb-rsp-gdbserver.png

NODES= \
	start \
	itsets \
	th_groups \
	all_stop_non_stop \
	non_stop \
	target_async \
	async_by_default \
	local_remote_parity \
	multi_target \
	multi_process

all: presentation.pdf
.PHONY:all

presentation.pdf: ${PDFS} generate-dots presentation.org
	emacs -nw \
		--visit=presentation.org \
		--funcall=org-export-as-pdf \
		--eval "(kill-emacs)"

.PHONY: generate-dots
generate-dots: dot/world_domination.dot.in gendots
	for i in $(NODES); do \
		./gendots $$i dot/world_domination.dot.in dot/world_domination-$$i.dot; \
		dot -Tpdf dot/world_domination-$$i.dot > dot/world_domination-$$i.pdf; \
	done; \
	./gendots start dot/world_domination.dot.in dot/world_domination.dot; \
	dot -Tpdf dot/world_domination.dot > dot/world_domination.pdf;

clean-generated-dots:
	@for i in $(NODES); do \
		rm -f dot/world_domination-$$i.dot dot/world_domination-$$i.pdf; \
	done; \
	rm -f dot/world_domination.dot dot/world_domination.pdf

clean: clean-generated-dots
	rm -f ${PDFS} ${DIA_SVGS} ${DITAA_IMGS} presentation.tex presentation.pdf
