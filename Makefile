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

export WANGLE = wangle
export TOPDIR = $(PWD)
export DOCDIR = $(TOPDIR)/doc
export SRCDIR = $(TOPDIR)/src

# --------------------------------------------------------------------
#  User-facing rules
# --------------------------------------------------------------------

WANGLE = wangle

.PHONY: tangle
tangle:
	for f in $$($(WANGLE) roots wangle.nw); \
	do \
		$(WANGLE) tangle wangle.nw $$f $(SRCDIR)/$$f; \
	done

.PHONY: build
build: tangle		## build the fsm program
	nimble build

.PHONY: clean
clean:			## remove generated files
	-rm -f $(NW)
	$(MAKE) -C doc clean
#	$(MAKE) -C tests clean

.PHONY: doc
doc:			## Generate the documentation
	$(MAKE) -C doc doc	# doxygen'ed pages
#	$(MAKE) -C src doc	# nim docs from code

.PHONY: test
test:			## run all unit tests
	nimble test

