---
layout: post
title: Adding new GAP Tests
tags: GAP Profiling Testing
---

The purpose of this article is to show how to write tests in GAP. We will look at how to use GAP's new line-by-line profiler / code coverage to find untested code, and add a test.


Installing
==========

I will begin by assuming you have installed GAP, either the latest release, or a [development version]({% post_url 2015-11-18-building_git_gap %})


Quickstart Guide
===============

We will start with a quick guide to code coverage, with some brief comments. We will explain later how to do these things in greater depth!

    :::bash
    mkdir outdir # Somewhere to put our output
    gap.sh --cover testcover.gz # Replace gap.sh with however you run gap
    ...
    gap> Read(Filename( DirectoriesLibrary( "tst" ), "testinstall.g" ) ); $ Run GAP's quick test suite, put your own code here
    gap> UnprofileLineByLine(); $ End profiling. At this point we could quit GAP, if we wanted.
    gap> LoadPackage("profiling"); $ We only need the package for reading profiles
    gap> x := ReadLineByLineProfile("testcover.gz");; $ Read profile data back in
    gap> OutputAnnotatedCodeCoverageFiles(x, "outdir"); $ lots of files are put in outdir!


After running this, open ```index.html``` from ```outdir```. Alternatively, you can see a copy of the coverage for all of GAP's tests [here](//gap-test-coverage/latest).

Extended Guide
==============

There is a GAP function,
