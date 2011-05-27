LIB = fdinfo
FLAGS =

OCAMLLIBDIR := $(shell ocamlc -where)
OCAMLDESTDIR ?= $(OCAMLLIBDIR)
OCAMLFIND_INSTALL_FLAGS ?= -destdir $(OCAMLDESTDIR) -ldconf ignore

all: byte native

interface:
	ocamlc -o $(LIB).cmi -c $(LIB).mli

byte:interface
	ocamlc $(FLAGS) -c $(LIB).ml
	ocamlc -a -o $(LIB).cma $(LIB).cmo

native:interface
	ocamlopt $(FLAGS) -c $(LIB).ml
	ocamlopt -a -o $(LIB).cmxa $(LIB).cmx

fdinfo_example: fdinfo_example.ml
	OCAMLPATH=../ ocamlfind ocamlopt -linkpkg -package fdinfo,str -c fdinfo_example.ml
	OCAMLPATH=../ ocamlfind ocamlopt -linkpkg -package fdinfo,str fdinfo_example.cmx -o fdinfo_example

install:
	ocamlfind install $(OCAMLFIND_INSTALL_FLAGS) $(LIB) META fdinfo.cmi fdinfo.mli fdinfo.cma fdinfo.cmxa *.a *.cmx

install-byte:
	ocamlfind install $(OCAMLFIND_INSTALL_FLAGS) $(LIB) META fdinfo.cmi fdinfo.mli fdinfo.cma

install-native:
	ocamlfind install $(OCAMLFIND_INSTALL_FLAGS) $(LIB) META fdinfo.cmi fdinfo.mli fdinfo.cmxa *.a *.cmx

uninstall:
	ocamlfind remove $(OCAMLFIND_INSTALL_FLAGS) $(LIB)

clean:
	rm -f *.cm[oixa] *.cmxa *.annot *.[ao] *~ fdinfo_example
