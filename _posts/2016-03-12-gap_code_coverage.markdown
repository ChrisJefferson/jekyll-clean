---
layout: post
title: Line by Line Code Coverage in GAP
tags: GAP
---

The purpose of this article is to show how to use GAP's new line-by-line code coverage. Firstly, you need gap version at least 4.8.0, or a [build a development version of gap]({% post_url 2015-11-18-building_git_gap %}).

This guide will just cover how to record the executed lines of code. Do you want to know how long is being spent on each line? Then switch to the [profiling guide]({% post_url 2016-03-11-gap_line_profiling %}) (these two guides are very similar!)

Quickstart Guide
===============

We will start with a quick guide to code coverage, with some brief comments. We will explain later how to do these things in greater depth!

Let's start with some code we want to profile. Here I am going to calculate cover coverage for the function `f` given below, and use a group from `atlas`.

{% highlight gap %}
LoadPackage("atlas");
a := AtlasGroup("U6(2)", NrMovedPoints, 12474);
b := a^(1,2,3);
f := function() Intersection(a,b); end;
{% endhighlight %}

There are two methods of calculating coverage, each with different trade-offs. Which one you should choose depends on the following rule: Profiling only marks lines which were *not* executed if they were read while profiling was running.

What does this mean in practice? If you want to know which lines from the standard library were not executed, you need to do _profiling a full GAP session_. If you want to only know about your own files and packages, then you must load those files and packages after running `CoverageLineByLine`.

Profiling a partial GAP session
-----------------------------

Firstly, let's make a simple function. You can download this file to save having to re-type it into GAP.

{% include code-link.html lang="gap" file="proffunction.g" %}

Firstly, we will record a coverage profile for the function `f`:

{% highlight gap %}
# Code between ProfileLineByLine and UnprofileLineByLine is recorded
# to a file output.gz
CoverageLineByLine("output.gz");
Read("proffunction.g");
myfunc(1,1);
myfunc(1,2);
UncoverageLineByLine();
{% endhighlight %}


This creates a file called `output.gz`, which stores all lines which were executed while running `f`. Now we want to turn that into a nice output. This requires loading the `profiling` package, like this:

{% highlight gap %}
LoadPackage("profiling");
OutputAnnotatedCodeCoverageFiles("output.gz", "outdir");
# Warning: Some lines marked executed but not read. If you
# want to see which lines are NOT executed,
# use the --prof/--cover command line options
{% endhighlight %}

Ignore the scary warning for now, but open the file `index.html`, in the `outdir` directory that was created. This gives an overview of all the profiled files, with `proffunction.g` somewhere in the list (probably at the bottom). Click on that, and you should see a table, like the one below (this is a screenshot, the real version is interactive):

<img src="{{ site_url }}/assets/coverage.png" class="img-thumbnail" alt="Overview of profile" width="300">

This tells us that every line of our function was exected except line 7, which was missed.

Profiling a full GAP session
---------------------------

One major limitation of our previous profiling is that it doesn't show missed lines from the standard library, only executed lines. This is because we need to start profiling before reading lines. The easiest way to accomplish this (and the only way for files in the standard library) is to start coverage when GAP starts, by giving the `--cover output.gz` flag to GAP when starting. You can still call `UncoverageLineByLine` when finished as normal.


Important Limitations
=====================

* As already discussed, you will only get missed lines from files read after profiling starts.

* You can only profile once per run of GAP -- if you want to profile another function you have to quit and restart GAP (sorry). (If you want to know why, this is because a global list of lines executed is stored, which can not be cleared).

* Giving your output file the `gz` extension makes GAP automatically compress the file. This is a great idea, because the files can get very big otherwise! Even then, the files can grow quite large very quickly, keep an eye on them.


