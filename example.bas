goto ask

screen: { !include source "screen.bas" }

gosub screen.clear
gosub screen.theme

ask: {
      print "please answer (y/n/q)";

what:
      input a$
      a$ = left$(a$, 1)
      if a$ = "y" then gosub positive:goto ask
      if a$ = "n" then negative
      if a$ = "q" then end
      print "what";:goto what
}

positive:
	print"you said yes"
	return

negative:
	print"you said no"
	goto ask

!include data "data.bin"

    