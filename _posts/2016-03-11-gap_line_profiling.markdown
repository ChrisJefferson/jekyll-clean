---
layout: post
title: Line by Line Profiling in GAP
tags: GAP
---

The purpose of this article is to show how to use GAP's new line-by-line profiler / code coverage. Firstly, you need gap version at least 4.8.0, or a [build a development version of gap]({% post_url 2015-11-18-building_git_gap %}).

Do you just care which lines of code are executed? Then you should switch to the [coverage guide]({% post_url 2016-03-12-gap_code_coverage %}) (these two guides are very similar!)

Quickstart Guide
================

We will start with a quick guide to profiling, with some brief comments. We will explain later how to do these things in greater depth!

Let's start with some code we want to profile. Here I am going to profile the function `f` given below, and use a group from `atlas`.

{% highlight gap %}
LoadPackage("atlas");
a := AtlasGroup("U6(2)", NrMovedPoints, 12474);
b := a^(1,2,3);
f := function() Intersection(a,b); end;
{% endhighlight %}


Firstly, we will record a profile of a function `f`:

{% highlight gap %}
# Code between ProfileLineByLine and UnprofileLineByLine is recorded
# to a file output.gz
ProfileLineByLine("output.gz"); f(); UnprofileLineByLine();
{% endhighlight %}

You should write this all on a single line in GAP, as profiling records the real time spent executing code, so time spent typing commands will be counted.

This creates a file called `output.gz`, which stores the result of running `f`. Now we want to turn that into a nice output. This requires loading the `profiling` package, like this:

{% highlight gap %}
LoadPackage("profiling");
OutputAnnotatedCodeCoverageFiles("output.gz", "outdir");
{% endhighlight %}

`OutputAnnotatedCodeCoverageFiles` reads the previously created `output.gz` and produces HTML output into the directory `outdir`.

You must view the result of your profiling in a web-browser outside of GAP. Open `index.html` from the `outdir` directory in the web browser of your choice to see what happened.

At the very top is a link to a _flame graph_. These give a quick overview of this functions took the most time. Functions are stacked, so lower functions call higher functions. 

From this graph we can see that `f` called `Intersection`, which called a function without a name at line `2942` in `stbcbckt.gi`. This function spent most of it's time in `PartitionBacktrack`, and a little time in `Stabilizer`.

<object data="{{ site_url }}/assets/flame.svg" type="image/svg+xml" width="100%">
</object>

Whenever you generate a profile which contains timing information, a flame graph link will be show on the first page of your generated profile!


FAQ / Problems
==============

* `ProfileLineByLine` records wall (also known as clock) time which happens between `ProfileLineByLine` and the next `UnprofileLineByLine`. This is why we put starting profiling, our code, and then stopping profile on a single line.

* If you want to profile how long everything in GAP takes, including the startup, then you can given the command line option `--prof <filename>` when starting GAP. This is equivalent to GAP calling `ProfileLineByLine("<filename>");` before loading any of the standard library (obviously, give your own filename).

* Giving your output file the `gz` extension makes GAP automatically compress the file. This is a great idea, because the files can get very big otherwise! Even then, the files can grow quite large very quickly, keep an eye on them.

* `ProfileLineByLine` takes an optional second argument which is a record, which can set some configuration options. Here are some of the options.

  * `wallTime`:
      Boolean (defaults to true). Sets if time should be measured using wall-clock time (true) or CPU time (false). Measuring CPU-time has a higher overhead, so avoid it if at all possible!

  * `justStat`:
        Boolean (defaults  to  false).  Switches profiling to only consider entire statements,  rather  than  parts of statements.  This has lower overhead and produces smaller output files, but produces a courser profile. 

  * `resolution`:
        Integer (defaults to 0). By default GAP will record a trace of all executed code. When non-zero, GAP instead samples which piece of code is being executed every `resolution` nanoseconds. Setting this to a non-zero value improves performance and produces smaller traces, at the cost of accuracy. GAP will still accurately record which statements are executed at least once. This is mainly useful when you wish to consider very ling running code.



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

