all:
	echo "Make what, exactly?"

.PHONY: doc
doc:
	wangle doc wangle.nw
	doxygen Doxyfile

.PHONY: clean
clean:
	-rm -rf html
