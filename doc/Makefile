all:
	echo "Make what, exactly?"

.PHONY: doc
doc:
	doxygen Doxyfile

.PHONY: clean
clean:
	-rm -rf html

WEAVE = ../wangle weave
.PHONY: weave
weave:
	for f in litprog/*.nw; \
	do \
		$(WEAVE) $$f woven/$$(basename $$f).md; \
	done
