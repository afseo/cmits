# --- BEGIN DISCLAIMER ---
# Those who use this do so at their own risk;
# AFSEO does not provide maintenance nor support.
# --- END DISCLAIMER ---
# --- BEGIN AFSEO_DATA_RIGHTS ---
# This is a work of the U.S. Government and is placed
# into the public domain in accordance with 17 USC Sec.
# 105. Those who redistribute or derive from this work
# are requested to include a reference to the original,
# at <https://github.com/afseo/cmits>, for example by
# including this notice in its entirety in derived works.
# --- END AFSEO_DATA_RIGHTS ---
all: sudo-boldface.pdf

clean:
	rm -f deps sudo-boldface.{aux,log,pdf} svnversion.txt

%.pdf: %.tex
	pdflatex $^
	pdflatex $^

sudo-boldface.pdf: sudo-boldface.tex svnversion.txt


include deps

deps:
	find . -name .svn -prune -o -type f \
		\! -name '*~' \! -name '*.pdf' \! -name deps \
		\! -name svnversion.txt \! -name '.nfs*' \
		-printf "svnversion.txt: %p\\ndeps: %p\\n" > $@

svnversion.txt:
	svnversion > $@

.PHONY: all clean