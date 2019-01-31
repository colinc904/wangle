# --------------------------------------------------------------------
#  simple 'help' facility: just type "make" and receive a list of
#  the available (useful) targets
# --------------------------------------------------------------------

.PHONY: help
help:
	@echo "Available make targets:"
	@echo ""
	@grep -E -h '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
	awk 'BEGIN {FS = ":.*?## "}; {printf "%-15s %s\n", $$1, $$2}'
	@echo ""

# --------------------------------------------------------------------
#  Some global variables to be inherited by subirectory Makefiles
# --------------------------------------------------------------------

export TOPDIR = $(PWD)
export DOCDIR = $(TOPDIR)/doc

# --------------------------------------------------------------------
#  User-facing rules
# --------------------------------------------------------------------

WEB = doc/wangle.nw
WANGLE = ./wangle
TANGLE = $(WANGLE) tangle
ROOTS = $(WANGLE) roots

.PHONY: tangle
tangle:
	cat doc/litprog/*.nw >./tmp.nw
	for f in $$($(ROOTS) tmp.nw); \
	do \
		$(TANGLE) tmp.nw $$f src/$$f; \
	done

.PHONY: build
build:			## build the fsm program
	nimble build

.PHONY: clean
clean:			## remove generated files
	-rm -f tmp.nw
	$(MAKE) -C doc clean
#	$(MAKE) -C tests clean

.PHONY: doc
doc:			## Generate the documentation
	$(MAKE) -C doc doc	# doxygen'ed pages
#	$(MAKE) -C src doc	# nim docs from code

.PHONY: test
test:			## run all unit tests
	nimble test

