# Code from blog post at azumanga.org
#
gap> Intersection(1,2);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for Intersection2(1, 2) called from
Intersection2( I, D ) at /Users/caj/reps/gap/gap/lib/coll.gi:2479 called from
<function "Intersection">( <arguments> )
 called from read-eval loop at line 1 of *stdin*
you can 'quit;' to quit to outer loop, or
you can 'return;' to continue
#### --
gap> Print(10/0);
Error, Rational operations: <divisor> must not be zero
not in any function at *stdin*:1
you can replace <divisor> via 'return <divisor>;'
brk> return 2;
5
#### --
mult := function(x,y)
  local i;
  i := x * y;
  return i;
end;

f := function(a,b)
  local i,j;
  i := mult(a,b);
  j := mult(a,-1);
  return i * j;
end;

#### --
gap> f((1,2),(3,4));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `*' on 2 arguments called from
x * y at test.g:3 called from
mult( a, -1 ) at test.g:10 called from
<function "f">( <arguments> )
 called from read-eval loop at line 16 of *stdin*
you can 'quit;' to quit to outer loop, or
you can 'return;' to continue
brk>
#### --
brk> x;
(1,2)
brk> y;
-1
brk> i;
Error, Variable: <debug-variable-0-3> must have a value in
  <compiled or corrupted statement>  called from
x * y at /Users/caj/temp/t.g:3 called from
mult( a, -1 ) at /Users/caj/temp/t.g:10 called from
<function "f">( <arguments> )
 called from read-eval loop at line 3 of *errin*
#### --
brk> a;
(1,2)
brk> b;
(3,4)
#### --
brk> DownEnv();
brk> DownEnv();
brk> i;
(1,2)(3,4)
#### --
brk> ShowArguments();
[ (1,2), -1 ]
brk> ShowDetails();
--------------------------------------------
Information about a `No method found'-error:
--------------------------------------------
Operation           : *
Number of Arguments : 2
Operation traced    : false
IsConstructor       : false
Choice              : 1st
brk> ShowMethods(5);
#I  Searching Method for * with 2 arguments:
#I  Total: 246 entries
#I  Method 1: ``*: additive element with zero * zero integer'', value: 1*SUM_FLAGS+24
#I   - 1st argument needs [ "IsNearAdditiveElementWithZero" ]
#I   - 2nd argument needs [ "IsZeroCyc" ]
#I  Method 2: ``*: zero integer * additive element with zero'', value: 1*SUM_FLAGS+24
#I   - 1st argument needs [ "IsInt", "IsZeroCyc" ]
....
#### --
Error, no method returned in
  i := x * y; at test.g:3 called from
mult( a, -1 ) at test.g:10 called from
<function "f">( <arguments> )
 called from read-eval loop at *stdin*:2
#### --
