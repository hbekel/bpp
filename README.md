## bpp - a basic preprocessor for use with petcat

This is a simple symbolic preprocessor for cross-developing CBM BASIC
programs in a more readable form, removing the need for line numbers
and using labels, scopes and include directives instead. The output
can then be converted to a PRG file using the petcat utilitiy that
comes with VICE.

## Example

This pointless example program is separated into two files:

### screen.bpp
<pre>
clear: print "{clr}";: return
theme: poke53280,0: poke53281,0: poke646,5: return
</pre>

### example.bpp
<pre>
goto main

screen: { !include source "screen.bpp" }

main: {

      gosub screen.clear
      gosub screen.theme

ask:  print "how do you feel?":print
      print "1) i feel great!"
      print "2) nothing to complain about"
      print "3) not so well..."
      print "4) quit asking"
      print
      input a

      rem check the range...

      if a < 1 goto error
      if a > 4 goto error

      print

      rem give the answer...

      on a gosub answer.good, answer.neutral, answer.bad, done

      rem repeat...

      gosub delay
      goto main

error: print: print "please enter a number between 1 and 4!":
       gosub delay: gosub screen.clear
       goto ask

answer: {

       good:    print "well that's swell!": goto done
        
       neutral: print "ok, carry on then...": goto done

       bad:     on int(rnd(23)*3)+1 goto one, two, three
        
       one:   print "here, have a cookie!": goto done
       two:   print "dont' worry, be happy!": goto done
       three: print "cheer up!": goto done

       done: return

       }               
}

done: print: print "see ya!": end

delay: { for i = 0 to 1024: next i: return }
</pre>

bpp is implemented as a simple filter, reading from stdin and producing output on stdout.

`$ bpp < example.bpp'

<pre>
0 goto3
1 print"{clr}";:return
2 poke53280,0:poke53281,0:poke646,5:return
3 gosub1
4 gosub2
5 print"how do you feel?":print
6 print"1) i feel great!"
7 print"2) nothing to complain about"
8 print"3) not so well..."
9 print"4) quit asking"
10 print
11 inputa
12 ifa<1goto18
13 ifa>4goto18
14 print
15 onagosub21,22,23,28
16 gosub29
17 goto3
18 print:print"please enter a number between 1 and 4!"
19 gosub29:gosub1
20 goto5
21 print"well that's swell!":goto27
22 print"ok, carry on then...":goto27
23 onint(rnd(23)*3)+1goto24,25,26
24 print"here, have a cookie!":goto27
25 print"dont' worry, be happy!":goto27
26 print"cheer up!":goto27
27 return
28 print:print"see ya!":end
29 fori=0to1024:nexti:return
</pre>

All references to labels have been replaced by the actual line number
for the respective label. Also, spaces and rem statements have been
stripped from the output.

## Labels

Label identifiers may include letters, numbers, and underscores,
although they have to begin with either a letter or an
underscore. BASIC keywords can not be used as label identifiers.

Labels can be defined by prefixing code with a label name, followed by
a colon character:

`label: <code>...`

## Scopes

Scopes are created by enclosing code in curly brackets:

`{ <code>... }`

Scopes prefixed with a label definition can be referenced by the given
label, allowing code from other scopes to explicitly reference labels
local to this scope using the given identifier.

`label: { <code>... }`



