# NeuroLoop utilities - Documentation - Makefile
# Written by Christopher Thomas.

CHANGUIDE=chantool-guide
CHANBASE=changuide

REFNAME=neuroloop-utility-libraries
REFBASE=nlutilref


CHANBITS=\
	$(CHANGUIDE).tex		\
	$(CHANBASE)-over.tex		\
	$(CHANBASE)-howto.tex

REFBITS=\
	$(REFNAME).tex			\
	$(REFBASE)-over.tex

REFAUTO=\
	$(REFBASE)-ft.tex		\
	$(REFBASE)-io.tex		\
	$(REFBASE)-plot.tex		\
	$(REFBASE)-proc.tex		\
	$(REFBASE)-util.tex		\
	$(REFBASE)-intan.tex		\
	$(REFBASE)-vend-intan.tex	\
	$(REFBASE)-openephys.tex	\
	$(REFBASE)-chantool.tex		\
	$(REFBASE)-sanity.tex		\
	$(REFBASE)-examples.tex		\
	$(REFBASE)-notes-core.tex	\
	$(REFBASE)-notes-vendor.tex	\
	$(REFBASE)-notes-apps.tex


default: force

changuide: $(CHANGUIDE).pdf
libref: $(REFNAME).pdf

force: clean changuide libref
	make autoclean

clean: tclean autoclean
	rm -f $(CHANGUIDE).pdf
	rm -f $(REFNAME).pdf

autoclean:
	rm -f $(REFAUTO)

tclean:
	rm -f $(CHANGUIDE)*.log $(CHANGUIDE)*.aux $(CHANGUIDE)*.toc
	rm -f $(REFNAME)*.log $(REFNAME)*.aux $(REFNAME)*.toc
	rm -f texput.*


$(CHANGUIDE).pdf: $(CHANBITS)
	pdflatex $(CHANGUIDE).tex
	pdflatex $(CHANGUIDE).tex
	make tclean


refauto-bits: refauto-corelibs refauto-vendorlibs refauto-applibs \
	refauto-examples refauto-notes

DIRSCORE=\
	../libraries/lib-nloop-io	\
	../libraries/lib-nloop-plot	\
	../libraries/lib-nloop-proc	\
	../libraries/lib-nloop-util

refauto-corelibs:
	./copy-code.pl --outfile=$(REFBASE)-ft.tex --matlabdoc \
		"--chapter=\`\`nlFT'' Functions" --label=sect-ft \
		../libraries/lib-nloop-ft/*.m
	./copy-code.pl --outfile=$(REFBASE)-io.tex --matlabdoc \
		"--chapter=\`\`nlIO'' Functions" --label=sect-io \
		../libraries/lib-nloop-io/*.m
	./copy-code.pl --outfile=$(REFBASE)-plot.tex --matlabdoc \
		"--chapter=\`\`nlPlot'' Functions" --label=sect-plot \
		../libraries/lib-nloop-plot/*.m
	./copy-code.pl --outfile=$(REFBASE)-proc.tex --matlabdoc \
		"--chapter=\`\`nlProc'' Functions" --label=sect-proc \
		../libraries/lib-nloop-proc/*.m
	./copy-code.pl --outfile=$(REFBASE)-util.tex --matlabdoc \
		"--chapter=\`\`nlUtil'' Functions" --label=sect-util \
		../libraries/lib-nloop-util/*.m

DIRSVENDOR=\
	../libraries/lib-nloop-ft	\
	../libraries/lib-nloop-intan	\
	../libraries/lib-vendor-intan	\
	../libraries/lib-nloop-openephys

refauto-vendorlibs:
	./copy-code.pl --outfile=$(REFBASE)-intan.tex --matlabdoc \
		"--chapter=\`\`nlIntan'' Functions" --label=sect-intan \
		../libraries/lib-nloop-intan/*.m
	./copy-code.pl --outfile=$(REFBASE)-vend-intan.tex --matlabdoc \
		"--chapter=\`\`vIntan'' Functions" --label=sect-vend-intan \
		../libraries/lib-vendor-intan/*.m
	./copy-code.pl --outfile=$(REFBASE)-openephys.tex --matlabdoc \
		"--chapter=\`\`nlOpenE'' Functions" --label=sect-openephys \
		../libraries/lib-nloop-openephys/*.m

DIRSAPPS=\
	../libraries/lib-nloop-chantool		\
	../libraries/lib-nloop-sanitycheck

refauto-applibs:
	./copy-code.pl --outfile=$(REFBASE)-chantool.tex --matlabdoc \
		"--chapter=\`\`nlChan'' Functions" --label=sect-chan \
		../libraries/lib-nloop-chantool/*.m
	./copy-code.pl --outfile=$(REFBASE)-sanity.tex --matlabdoc \
		"--chapter=\`\`nlCheck'' Functions" --label=sect-sanity \
		../libraries/lib-nloop-sanitycheck/*.m

refauto-examples:
	./copy-code.pl --outfile=$(REFBASE)-examples.tex --verbatim \
		"--chapter=Sample Code" --label=sect-examples \
		../code-examples/*.m

refauto-notes:
	./copy-code.pl --outfile=$(REFBASE)-notes-core.tex --verbatim \
		"--chapter=Core Library Structures and Additional Notes" \
		--label=sect-notes `find $(DIRSCORE)|grep txt`
	./copy-code.pl --outfile=$(REFBASE)-notes-vendor.tex --verbatim \
		"--chapter=Hardware Library Structures and Additional Notes" \
		--label=sect-notes `find $(DIRSVENDOR)|grep txt`
	./copy-code.pl --outfile=$(REFBASE)-notes-apps.tex --verbatim \
	"--chapter=Application Library Structures and Additional Notes" \
		--label=sect-notes `find $(DIRSAPPS)|grep txt`

$(REFNAME).pdf: $(REFBITS) refauto-bits
	pdflatex $(REFNAME).tex
	pdflatex $(REFNAME).tex
	make tclean

#
# This is the end of the file.
