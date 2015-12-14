all: test.prg

test.bas: bpp test.bpp
	bpp < test.bpp > test.bas

test.prg: test.bas
	petcat -w2 < test.bas > test.prg

test: test.prg
	xlink test.prg

clean:
	rm -f *.{bas,prg}
