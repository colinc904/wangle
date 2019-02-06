all:
	echo "Make what, exactly?"

.PHONY: doc
doc: weave
	doxygen Doxyfile

.PHONY: clean
clean:
	-rm -f woven/*.md
	-rm -f html/*.html
	-rm -f html/*.js
	-rm -f html/*.css
	-rm -f html/*.png
	-rm -f html/*.md5
	-rm -rf html/search

.PHONY: weave
NW = $(TOPDIR)/wangle.nw

weave:
	$(WANGLE) weave $(NW) woven/$$(basename $(NW) .nw).md;
