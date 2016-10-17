---
layout: post
title: Writing tests in GAP
tags: GAP Profiling Testing
---

The purpose of this article is to show how to write tests in GAP. Either for your own code, or code in the GAP standard library. 


Installing
==========

I will begin by assuming you have installed GAP, either the latest release, or a [development version]({% post_url 2015-11-18-building_git_gap %})


Quickstart Guide
===============

GAP's test file format looks like the result of running gap. This is intensional. Here is an example test file which tests the `+` operator. We have purposefully added two tests which are incorrect, `1 + 0` (which isn't `6`) and the final test (which is formatted incorrectly).

{% highlight gap %}
gap> 1 + 2;
3
gap> 1 + (-1);
0
gap> 1 + 0;
6
gap> [1,2] + 10;
[ 11, 12 ]
gap> [1,2] + [20,30];
[ 21, 32 ]
gap> [] + [];
[  ]
gap> [1] + [2];
[3]
{% endhighlight %}

If you save this to a file called `gap.tst`, you can run it as follows, and see the failing tests.

{% highlight gap %}
gap> Test("gap.tst");
########> Diff in gap.tst:5
# Input is:
1 + 0;
# Expected output:
6
# But found:
1
########
########> Diff in gap.tst:13
# Input is:
[1] + [2];
# Expected output:
[3]
# But found:
[ 3 ]
########
false
{% endhighlight %}

The first failing test isn't surprising, `1+0` isn't `6` after all. The second test shows an important fact -- GAP tests for exact string matching, not object equivalence.


Sometimes we want to write tests which can't really be written all on one line. In this case, we can use '> ' to start each new line. If a line should produce no output (for example if we end it with `;;`), then we move straight on to the next `gap>` statement. We can also start lines with a `#` to give comments, but only at the beginning of the file, or after a blank line. Let's put all of these things together:

{% highlight gap %}
# Checking +
gap> 1 + 1 +
> 1;
2

# Checking -
# This first line produces no output
# The second prints out 'x'
gap> x := 1 - 1;;
gap> x;
0
{% endhighlight %}


Writing stable tests
------------------

Earlier we mentioned that GAP's test checks the output string, not that the actual objects produced are equivalent. In some cases, this is exactly what we want -- when we are checking how GAP prints for instance. In other cases, it can lead to fragile tests.

A good way to see this is by looking at three ways we can get GAP to print out the symmetric group on 50 points:

{% highlight gap %}
gap> g := SymmetricGroup(50);
Sym( [ 1 .. 50 ] )
gap> h := Group([ (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
> 21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,
> 41,42,43,44,45,46,47,48,49,50), (1,2) ]);
<permutation group with 2 generators>
gap> g = h;
true
gap> Size(h);
30414093201713378043612608166064768844377641568960512000000000000
gap> h;
<permutation group of size 30414093201713378043612608166064768844377641568960512000000000000 with 2 generators>
{% endhighlight %}

If we construct the symmetric group with `SymmetricGroup`, then we can see the group is output as `Sym( [1 .. 50 ] )`. However, if we just give the generators GAP just remembers it has a `<permutation group with 2 generators>`. Finally, if we take that group and ask for it's size, GAP remembers that size and starts printing that out as well.

This causes a problem for writing tests -- you have to know exactly which one GAP is going to output, and also hope no internal change to GAP causes it to learn the size (for example), which doesn't change the result of your test, but does change the output.

The other possibility is that a test could break, without changing the text output. For example imagine that we recorded some function should return `<permutation group with 2 generators>`. That function's return value could change to any group with two generators, without ever noticing the error.

The solution? The easiest option is to write tests which explictly check the correct object is returned, and just print `true`, for example, to check `Intersection`

{% highlight gap %}
gap> Intersection(SymmetricGroup(40), AlternatingGroup(20)) = AlternatingGroup(20);
true
{% endhighlight %}

It is perfectly legal to use `Read` to read other code while testing. One technique I often use is to write functions which should output nothing if the tests succeed. This combines well with the next section.


Testing projects
----------------

There are two useful features which we haven't covered yet. The first is the function `TestDirectory`. This function just runs all tests in a directory (including tests in all sub-directories, recursively). This is useful for testing a whole project.

The second feature is uses tests for timing, using GAPstones. You will often notice tests start with a line like `START_TEST("file.tst");` and end with `END_TEST("file.tst", 10000);`. These lines are used to record how long the file takes to run. My advice, ignore these lines for now, GAPstones don't actually turn out to be very useful for measuring the performance of GAP code.
