---
layout: post
title: The Break Loop
tags: GAP
---

Spend any amount of time in GAP, and eventually you will hit the break loop. This is the message GAP prints when code breaks, either because of incorrect arguments, or an algorithm has started producing incorrect values. Here is an example:

{% highlight gap %}
gap> Intersection(1,2);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for Intersection2(1, 2) called from
Intersection2( I, D ) at /Users/caj/reps/gap/gap/lib/coll.gi:2479 called from
<function "Intersection">( <arguments> )
 called from read-eval loop at line 1 of *stdin*
you can 'quit;' to quit to outer loop, or
you can 'return;' to continue
{% endhighlight %}

The break loop acts like the debugger in most other languages. So, what can we do once we are here?

# Escaping the break loop

If you just want to get out of the break loop, either type `quit;` or press *ctrl+d*.

Break loops will often say you can `'return;' to continue`, or sometimes tell you that you can return a new value (see example below), to fix up the broken computation. My advice is to ignore these options to `return`. They are rarely useful, and a good way to end up with further break loops, incorrect answers, or even crashing GAP!

{% highlight gap %}
gap> Print(10/0);
Error, Rational operations: <divisor> must not be zero
not in any function at *stdin*:1
you can replace <divisor> via 'return <divisor>;'
brk> return 2;
5
{% endhighlight %}

# Exploring what went wrong

Let's use the break loop to understand what went wrong. We will begin with the general break loop, and also the extra methods when provided when the break loop is caused by `NoMethodFound` (the most common type of break loop).

Let's start with some silly code. If you want to follow along, save this to a file `test.g` and use `Read("test.g")` to read it in (so line numbers will be set correctly).

{% highlight gap %}
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

{% endhighlight %}

Now, let's call our function. If your output doesn't have the files and line numbers you are using GAP 4.7 or earlier.

{% highlight gap  %}
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
{% endhighlight %}

From this, we can already see what went wrong:

* We tried to execute `(1,2) * -1` 
* The line which caused the problem was line 3, `x * y`.
* We ran that code by performing `mult(a,-1)` on line 10.
* We ran that code by running `f`, which we run from `*stdin*`, which represents the user typing into GAP.

From the break loop we can execute any normal GAP code. We can see the value of variables in the function `mult`. If we try to read a variable without a value, we get a slightly scary message, which tells us that `i` has not got a value yet.

{% highlight gap %}
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
{% endhighlight %}

We can also get the value of variables from functions higher up the stack:

{% highlight gap %}
brk> a;
(1,2)
brk> b;
(3,4)
{% endhighlight %}

However, how can we get access to the `i` from `f`? To do this, we use `UpEnv` and `DownEnv`. These allow us to step up and down through the functions which have been called, and read their variables.

{% highlight gap %}
brk> DownEnv();
brk> DownEnv();
brk> i;
(1,2)(3,4)
{% endhighlight %}

# No Method Found

The first line of our error loop is `No Method Found`. There is extra support in GAP to help understand why GAP failed to find a method call. We will describe them each, then give an example.

* `ShowArguments` shows the arguments to the function
* `ShowDetails` gives some general information about the function call
* `ShowMethods` shows all methods which were considered, and why they were rejected. This can often be a very long list! The argument to this function sets how verbose the function is (5 displays the most information).

{% highlight gap %}
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
{% endhighlight %}

Finally, we should exit the loop. The best idea is to press _ctrl+d_, or type `quit;`. If we try typing `return;`, we get the following, which shows GAP trying to recover, but finding is has no idea what to do with `x * y` (that's what the `no method returned` is referring to).

{% highlight gap %}
Error, no method returned in
  i := x * y; at test.g:3 called from
mult( a, -1 ) at test.g:10 called from
<function "f">( <arguments> )
 called from read-eval loop at *stdin*:2
{% endhighlight %}
