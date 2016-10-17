---
layout: post
title: Building a development version of GAP
tags: GAP
---

For many years, the development process of GAP was not open to the general public. Now you can see (and contribute to!) the day-to-day development at GAP's [github page](https://www.github.com/gap-system/gap). This page will show you how to install GAP's development version.

*WARNING*: While the development version of GAP is usually in a good state (I use it for most of my day-to-day work), it is occasionally broken and some packages may not work. Use at your own risk!

Over time this page will probably get out of date, or not work on some machines. If these instructions don't work, please give me a buzz at [chris@bubblescope.net](mailto:chris@bubblescope.net). I'm going to assume you are happy with working in a unix terminal and moving around directories.

Requirements
============

Getting and building GAP needs a basic set of development tools. These are:

* `git`: For downloading from github (there are GUIs available, but we will use the command line here).
* `make`: A program used for building large (and small) software projects
* `gcc` or `clang`: A compiler for the C language (some other compilers might work, but in particular Visual Studio on Windows will not)!
  
  
Getting these is different on each operating system. Here is the most popular ones. On windows in particular, make sure you follow these instructions!

* Mac OS X : The easiest method is to install Xcode from the App Store. After installing it, open a terminal and type `clang`. 

* Linux : You will need to install `gcc`, `make` and `git`. First check if these two programs are already on your system (they often are). If not, you will have to install them. You should look at your linux's documentation, but the two most common methods are:
  * Ubuntu / Debian `sudo apt-get install gcc make git`
  * Redhat / CentOS `sudo yum install gcc make git`

* Windows : GAP uses a tool called [Cygwin](http://www.cygwin.com), which provides a unix-like environment on windows. Grab the cygwin installer from the Cygin website, and while installing select the packages make, gcc and git.

Installing
===========

Now pop along to gap's [github page](https://github.com/gap-system/gap). There are many git tutorials out there, but for now let's skip all of that, and just grab the latest git version:

{% highlight bash %}
git clone https://github.com/gap-system/gap.git
{% endhighlight %}

Now, we need to build GAP. Go into GAP's source directory, configure and make GAP.

{% highlight bash %}
cd gap
./configure
make
{% endhighlight %}

While we have now built GAP, without any packages GAP isn't very useful (without at least GAPDoc, GAP doesn't even really work!)

You can get the bare minimal set of packages needed to make GAP work by running

{% highlight bash %}
make bootstrap-pkg-minimal
{% endhighlight %}

And you can get all packages by running

{% highlight bash %}
make bootstrap-pkg-full
{% endhighlight %}

Note that while this downloads all packages, many packages have to be built before they are useful. To build packages, go into the `pkg` directory and then run the `BuildPackages.sh` script:

{% highlight bash %}
cd pkg
../bin/BuildPackages.sh
{% endhighlight %}

If some packages fail to build, don't worry unless you need those packages. Some packages are extremely hard to build, and require extra dependancies. Just ignore the ones which don't work!

Assuming everything went well, try running `bin/gap.sh`, and you should have a working GAP. Well done!

Development Packages
====================

One reason you might be reading this guide is to run development versions of packages. In each case, you need to follow some simple rules:

* If you already have a copy of the package in `pkg`, then move it out (GAP will try to make sure it loads the most recent version of any package, but it is easier to only have one copy of each package).

* `git clone` the development package into the `pkg` directory

* Do any necessary building.

Let's do this with an example -- the profiling package!

{% highlight bash %}
# Assuming we are in the GAP directory
cd pkg
# Clean out old package
rm -rf profiling*
# Grab new copy
git clone https://github.com/ChrisJefferson/profiling
# Build package (this command will build most packages that need compiling)
cd profiling && ./configure && make
{% endhighlight %}

You can check this worked by starting gap and typing ```LoadPackage("profiling");```.
