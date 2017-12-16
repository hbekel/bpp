## bpp - a basic preprocessor for use with petcat

This is a simple symbolic preprocessor for cross-developing CBM BASIC
programs in a more readable form, removing the need for line numbers
and using labels, scopes and include directives instead. The output
can then be converted to a PRG file using the petcat utilitiy that
comes with VICE.

## Example

This pointless example program is separated into two files:

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

### screen.bpp

This file contains two subroutines for clearing the screen and setting
the screen and text colors. In the example above, we will include this
file in it's own scope labeled "screen", so that we will be able to
call these routines using `gosub screen.clear` and `gosub
screen.theme`.

<pre>
clear: print "{clr}";: return
theme: poke53280,0: poke53281,0: poke646,5: return
</pre>

## Usage

bpp is implemented as a simple filter, reading from stdin and
producing output on stdout:

    $ bpp < example.bpp

This will redirect the contents of `example.bpp` to stdin and feed it
to bpp, producing the following output:

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

As you can see, all references to labels have been replaced by the
actual line number for the respective label and the file `screen.bpp`
has been included. Also, spaces and rem statements have been stripped
from the output.

To convert this to a PRG file that can be run on the C64, use the
petcat utility.  petcat is also implemented as a filter, so we can
simply use pipes and redirects:

    $ bpp < example.bpp | petcat -w2 > example.prg

## Comments

All lines starting with a semicolon or a Basic REM statement are
ignored.

## Labels

Label identifiers may include letters, numbers, and underscores,
although they have to begin with either a letter or an
underscore. BASIC keywords can not be used as label identifiers.

Labels can be defined by prefixing code with a label name, followed by
a colon character:

    label: <code>...

## Scopes

Scopes are created by enclosing code in curly brackets:

    { <code>... }

Scopes prefixed with a label definition can be referenced by the given
label, allowing code from other scopes to explicitly reference labels
local to this scope using the given identifier.

    label: { <code>... }

## Referencing Labels and Scopes

Labels can be referenced by using a label reference instead of a line number
for `goto` and `gosub` as well as implicit gotos following the `then` part of
an `if`-statement.

    goto <label>
    on <var> goto <label>, <label>, <label>...
    
    gosub <label>
    on <var> gosub <label>, <label>, <label>...
    
    if <condition> then <label>
    
A label reference may be prefixed with a reference to the scope
containing the label, separated by a dot:

    <path-to-scope>.<label>
    
Where a path to a scope may also include multiple scope references
separated by dots:

    <outer-scope-label>.<inner-scope.label>.<label>

## How references are resolved

In order to resolve a label reference, bpp first tries to find the
label by its local name in the current scope.

If the label is not found within the current scope, it is first
searched for in all subscopes of the current scope by the path
relative to the current scope.

If the label has not been found, bpp will try to resolve it in the
same manner, beginning from the parent scope of the current scope and
continuing upwards until the reference has been resolved. If not
resolved, an error is thrown and the processing is aborted.

The global scope can be explicitly referenced by the implied scope
label "global".

In the example above, the scope "answer" contains a label called
"done", which is used as the exit point for the code in this
scope. The code here can reference the "done" label by using it's
local name. The global scope also contains a label called "done",
which is the exit point for the program as a whole.

From within the "answer" scope, the global "done" label can be
referenced by explicitly using "global.done". Similary, code outside
of the "answer" scope or its parent scopes can reference the "done"
label local to the "answer" scope by using "answer.scope".

In general, labels that are unique to the whole source code can be
simply referenced by their unqualified name regardless of the current
scope, while labels that are defined in multiple scopes can be
referenced reliably by their local name only if they can be resolved
unambigiously following the above rules.

## Include directive

The include directive can be used to include code or data from
external files:

    !include <type> "<filename>"

Type can be either "source" or "data", where "source" includes the
contents of the file verbatim into the current file and "data"
interprets the contents of the file binary data and the creates the
corresponding basic DATA lines.


