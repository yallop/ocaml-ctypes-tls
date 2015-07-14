BUILDDIR=_build
VPATH=$(BUILDDIR)
OCAMLDIR=$(shell ocamlopt -where)
$(shell mkdir -p $(BUILDDIR) $(BUILDDIR)/lib $(BUILDDIR)/stub-generator $(BUILDDIR)/test $(BUILDDIR)/generated)
PACKAGES=ctypes.stubs

# The files used to build the stub generator.
GENERATOR_FILES=$(BUILDDIR)/lib/tls_types.cmx \
		$(BUILDDIR)/lib/tls_dummy.cmx \
		$(BUILDDIR)/lib/tls_errors.cmx \
                $(BUILDDIR)/lib/tls_stable.cmi \
		$(BUILDDIR)/lib/tls_stable.cmx \
		$(BUILDDIR)/lib/tls_bindings.cmx		\
                $(BUILDDIR)/stub-generator/generate.cmx

# The files from which we'll build a shared library.
LIBFILES=$(BUILDDIR)/lib/tls_types.cmx \
         $(BUILDDIR)/lib/tls_dummy.cmx \
         $(BUILDDIR)/lib/tls_errors.cmx \
         $(BUILDDIR)/lib/tls_stable.cmi \
         $(BUILDDIR)/lib/tls_stable.cmx \
         $(BUILDDIR)/lib/tls_bindings.cmx \
         $(BUILDDIR)/generated/tls_generated_bindings.cmx	\
         $(BUILDDIR)/generated/tls.o \
         $(BUILDDIR)/lib/apply_bindings.cmx 

# The files that we'll generate
GENERATED=$(BUILDDIR)/generated/tls.c \
          $(BUILDDIR)/generated/tls_generated_bindings.ml

GENERATOR=$(BUILDDIR)/generate

CTYPES_PATH=$(shell ocamlfind query ctypes)

all: stubs sharedlib

sharedlib: $(BUILDDIR)/libtls.so

$(BUILDDIR)/libtls.so: $(LIBFILES)
	ocamlfind opt -o $@ -linkpkg -output-obj -runtime-variant _pic -package $(PACKAGES) $(filter %.cmx,$(LIBFILES))

stubs: $(GENERATED)

$(GENERATED): $(GENERATOR)
	$(BUILDDIR)/generate $(BUILDDIR)/generated

$(BUILDDIR)/%.o: %.c
	gcc -c -o $@ -fPIC -I. -I $(CTYPES_PATH) $<

$(BUILDDIR)/%.cmx: %.ml
	ocamlfind opt -c -o $@ -I $(BUILDDIR)/generated -I $(BUILDDIR)/lib -package $(PACKAGES) $<

$(BUILDDIR)/%.cmi: %.mli
	ocamlfind opt -c -o $@ -I $(BUILDDIR)/generated -I $(BUILDDIR)/lib -package $(PACKAGES) $<

$(GENERATOR): $(GENERATOR_FILES)
	ocamlfind opt -o $@ -linkpkg -package $(PACKAGES) $(filter %.cmx,$(GENERATOR_FILES))

clean:
	rm -rf $(BUILDDIR)

# test: all
# 	$(MAKE) -C $@
# 	LD_LIBRARY_PATH=$(BUILDDIR) _build/test/test.native test/ocaml.svg

# .PHONY: test
