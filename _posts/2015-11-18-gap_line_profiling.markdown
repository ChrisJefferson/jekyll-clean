---
layout: post
title: Line by Line Profiling in GAP
tags: GAP
---

The purpose of this article is to show how to use GAP's new line-by-line profiler / code coverage. Firstly, you need gap version at least 4.8.0. As this isn't out at time of writing (but it might be by the time you read this!) you will need to [build a development version of gap]({% post_url 2015-11-18-building_git_gap %}). Go and do that first. Done? Great!

Quickstart Guide
===============

We will start with a quick guide to code coverage, with some brief comments. We will explain later how to do these things in greater depth!

Let's assume we've started GAP, and we have a function f() we want to profile, where we grab an intersting group.

{% highlight gap %}
LoadPackage("atlas");
a := AtlasGroup("U6(2)", NrMovedPoints, 12474);
b := a^(1,2,3);
f := function() Intersection(a,b); end;
{% endhighlight %}



Now, here's how to profile the code with the new line-based profiler!

{% highlight gap %}
# Code between ProfileLineByLine and UnprofileLineByLine is recorded
# to a file output.gz
ProfileLineByLine("output.gz"); f(); UnprofileLineByLine();
LoadPackage("profiling");
OutputAnnotatedCodeCoverageFiles("output.gz", "outdir");
{% endhighlight %}

This will create a file `output.gz` containing a trace of how `f` was performed. `OutputAnnotatedCodeCoverageFiles` reads this and produces HTML output into the directory `outdir`. After this, open `outdir/index.html` in the web browser of your choice to see what happened.

FAQ / Problems
==============

* `ProfileLineByLine` records wall (also known as clock) time which happens between `ProfileLineByLine` and the next `UnprofileLineByLine`. This is why we put starting profiling, our code, and then stopping profile on a single line.

* Giving your output file the `gz` extension makes GAP compress the file. This is a great idea, because the files can get very big otherwise! Even then, the files can grow quite large very quickly, keep an eye on them.

* `ProfileLineByLine` takes an optional second argument which is a record, which can set some configuration options. Here are some of the options.

** `wallTime`:
      Boolean (defaults to true). Sets if time should be measured using wall-clock time (true) or CPU time (false). Measuring CPU-time has a higher overhead, so avoid it if at all possible!

** `justStat`:
        Boolean (defaults  to  false).  Switches profiling to only consider entire statements,  rather  than  parts of statements.  This has lower overhead and produces smaller output files, but produces a courser profile. 

** `resolution`:
        Integer (defaults to 0). By default GAP will record a trace of all executed code. When non-zero, GAP instead samples which piece of code is being executed every `resolution` nanoseconds. Setting this to a non-zero value improves performance and produces smaller traces, at the cost of accuracy. GAP will still accurately record which statements are executed at least once. This is mainly useful when you wish to consider very ling running code.


Interpreting the Profiler Output
================================

Flame Graphs
============

Flame graphs are a cool and trendy way of displaying profiles. Here is one generated from some GAP code (you can click on this to zoom in on some functions, have a go!)

<object data="{{ site_url }}/assets/flame.svg" type="image/svg+xml" width="100%">
</object>

Whenever you generate a profile which contains timing information, a flame graph link will be show on the first page of your generated profile!

Function-Based Profiling
========================

Sometimes you will have code that just runs too long to easily profile line by line. You can profile this in GAP older function-based profiler. You can read more about this profiler in GAP's documentation, but here is a quick example to get you going!

{% highlight gap %}
ProfileGlobalFunctions(true);
ProfileOperationsAndMethods(true);
f();
ProfileGlobalFunctions(false);
ProfileOperationsAndMethods(false);
DisplayProfile();
{% endhighlight %}


Gory Details
============
