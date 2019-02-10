build_dir := build
excluded := README.md
sources := $(filter-out $(excluded),$(wildcard *.md))
reports = $(addprefix $(build_dir)/,$(sources:.md=.pdf))
vector_images = $(wildcard *.svg)
images := $(addprefix $(build_dir)/,$(vector_images:.svg=.png))
static := static

# Look up your bibliography style at https://www.zotero.org/styles
# Download the CSL file to the static directory and modify `bibstyle`
# below
bibstyle := apa.csl

.PHONY: default
default: $(reports)

$(build_dir)/:
	mkdir -p $@

$(reports): $(build_dir)/%.pdf : %.md | $(images)
	# See https://pandoc.org/MANUAL.html#extensions for a list of extensions
	pandoc --from markdown+implicit_figures \
	       --template $(static)/latex.template \
	       -V repository="REPOSITORY" \
	       -V archive_doi="ARCHIVE-DOI" \
	       -V paper_url="PAPER-URL" \
	       -V journal_name='JOURNAL-NAME' \
	       -V formatted_doi="FORMATTED-DOI" \
	       -V review_issue_url="REVIEW-ISSUE-URL" \
	       -V graphics="true" \
	       -V issue="PAPER-ISSUE" \
	       -V volume="PAPER-VOLUME" \
	       -V page="REVIEW-ISSUE-ID" \
	       -V logo_path=$(static)/joss-logo.png \
	       -V year="PAPER-YEAR" \
	       -V submitted="SUBMITTED" \
	       -V published="PUBLISHED" \
	       -V citation_author="CITATION-AUTHOR" \
	       -V paper_title='PAPER-TITLE' \
	       -V footnote_paper_title='PLAIN-TITLE' \
	       --filter pandoc-citeproc --csl $(static)/$(bibstyle) \
	       --pdf-engine=xelatex \
	       -s -o $@ $<

$(images): $(build_dir)/%.png : %.svg
	-inkscape --export-png=$@ --export-dpi=300 $<

# Add the build directory as an order only prerequisite
$(foreach report,$(reports),$(eval $(report): | $(dir $(report))))
$(foreach image,$(images),$(eval $(image): | $(dir $(image))))

clean: $(build_dir)
	rm -rf $(build_dir)

sync:
	cp paper.md paper.bib screen*.png ../skyportal/doc/papers/joss
