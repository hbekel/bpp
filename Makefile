all: example.prg

example.out: bapp example.bas
	bapp < example.bas > example.out

example.prg: example.out
	petcat -w2 < example.out > example.prg

test: example.prg
	xlink example.prg

clean:
	rm -f *.{out,prg}
