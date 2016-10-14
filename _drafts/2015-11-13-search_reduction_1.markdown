---
layout: post
title: Search Reduction 1
tags: Algorithms
---


This is the second in a series of articles exploring backtracking search. Be sure to read the [first article]( {% post_url 2015-11-13-intro_to_backtrack %} ) first!. As a reminder, we are looking at how GAP implements intersection:

{% highlight gap %}
# Define two permutation groups
G := Group((1,2,3), (1,2), (1,4)(2,5)(3,6));
H := Group((1,3,6), (3,6), (1,2)(3,4)(5,6));
R := Intersection(G,H);
# Group([ (4,5), (1,3)(4,5), (1,4,3,5)(2,6) ])
{% endhighlight %}

Last time, we reached the point where we have to answer the question: Given two groups $$G$$ and $$H$$, is there any permutation $$p \in G \cap H$$ where $$1^p = i$$. To help us with this, we need another use of the *Stabilizer Chains*.

RepresentativeAction
====================

Using a *Stabilizer Chain* of a group $$G$$, and two lists of integers $$X = [x_1,\dots,x_n]$$ and $$Y = [y_1,\dots,y_n]$$, we can find a permutation $$p \in G$$ where $$x_i^p = y_i$$ for all $$i$$ (or prove none exist). In GAP, we do this with ```RepresentativeAction```.

{% highlight gap %}
RepresentativeAction(G, [1], [3], OnTuples);
# (1,3,2)
RepresentativeAction(G, [1,2], [2,3], OnTuples);
# (1,2,3)
RepresentativeAction(H, [1,2], [2,3], OnTuples);
# (1,2,3,4,6,5)
RepresentativeAction(G, [1,2], [2,5], OnTuples);
# fail
{% endhighlight %}


If either $$G$$ or $$H$$ does not contain a permutation such that $$1^p = i$$ for some $$i$$, then $$G \cap H$$ certainly can't contain can't. Lets consider a concrete example:

{% highlight gap %}
RepresentativeAction(Group((1,2),(3,4)), [1], [2], OnTuples);
# (1,2)
RepresentativeAction(Group((1,3),(2,4)), [1], [2], OnTuples);
# fail
{% endhighlight %}

From this we can tell the intersection of ```Group((1,2),(3,4))``` and ```Group((1,3),(2,4))``` contains no permutation $$p$$ where $$1^p = 2$$. What about $$G$$ and $$H$$?

{% highlight gap %}
RepresentativeAction(G, [1], [2], OnTuples);
# (1,2)
RepresentativeAction(H, [1], [2], OnTuples);
# (1,2)(3,4)(5,6)
{% endhighlight %}

This hasn't proved our result one way or the other! While we know both $$G$$ and $$H$$ do contain a permutation $$p$$ such that $$1^p = 2$$, that doesn't tell us there are any permutations $$p$$ they _both_ contain where $$1^p = 2$$.

This is always going to be a fundamental limitation of most of our techniques -- we will try our best to prove if a particular part of out problem contains no solutions. The important thing is that while we can report "don't know", we must be *sure* that when we say there are no solutions, there definitely aren't, else we would miss parts of out group!

So, how can be find the elements of $$G \cap H$$ where $$1^p=2$$? More splitting! If $$G \cap H$$ contains a permutation such that $$1^p = 2$$, then we can consider where that permutation maps $$2$$, splitting our search into another $$n-1$$ pieces.

* Find $$p \in G \cap H$$ where $$1^p = 2$$, $$2^p = 1$$.
* Find $$p \in G \cap H$$ where $$1^p = 2$$, $$2^p = 3$$.
* Find $$p \in G \cap H$$ where $$1^p = 2$$, $$2^p = 4$$.
* ...
* Find $$p \in G \cap H$$ where $$1^p = 2$$, $$2^p = n-1$$.

There are $n-1$$ pieces, because there can't be a permutation $$p$$ where $$1^p=2$$ and $$2^p=2$$! Let's try writing a GAP function to encapsulate this. This function is fairly long, but we will work our way through it.

Aside - Info
============

The ```Info``` function lets us optionally print out some information about what our algorithm is doing. The function takes  a name for the type of info (we will always use ```InfoGroup```, which is for group algorithms), the importance of information (lower numbers are more important), and then the information to print.

To see the messages, then run ```SetInfoLevel(InfoGroup, 1);```, which will print all messages of level ```1``` or smaller.

Aside - Functions returning Functions
========================

We are going to do some strange looking programming here. It might look
strange, but it will make our functions more usable later on, and (hopefully)
more compact.

What we want is a function which , given two lists `X` and `Y`, checks if
there is an element of our group which maps `X` to `Y`. For a given group `G`
we could write:

{% highlight gap %}
CheckInG := function(G, X, Y)
  return RepresentativeAction(G, X, Y, OnTuples);
end;
CheckInG(Group((1,2),(3,4)), [1,3], [2,4]);
# (1,2)(3,4)
{% endhighlight %}

But of course we would have to write a different function for every group. We
could pass the group into the function:

{% highlight gap %}
CheckInNamedGroup := function(G, X, Y)
  return RepresentativeAction(G, X, Y, OnTuples);
end;
CheckInNamedGroup(Group((1,2),(3,4)), [1,3], [2,4]);
# (1,2)(3,4)
{% endhighlight %}

But now we have to pass `G` around everywhere. Here is the solution:

{% highlight gap %}
GroupChecker := function(G)
  return function(X,Y)
    return RepresentativeAction(G, X, Y, OnTuples);
  end;
end;
{% endhighlight %}

Here we have a function which _returns another function_. Here is how we can use it:

{% highlight gap %}
check := GroupChecker(Group((1,2),(3,4)));
# function( X, Y ) ... end
check([1,3], [2,4]);
# (1,2)(3,4)
{% endhighlight %}

So, we can use `GroupChecker` to make a separate checker for any group.
Algorithm
=================

{% highlight gap %}
## Find a permutation p in a list of groups
## (represented by a list of checker functions like GroupChecker)
## such that i^p = array[i] for all i in [1..Length(Array)].
## Where each group is a subgroup of SymmetricGroup(maxpnt).
## Returns p, or fail if no such permutation exists
FindExtendingElement := function(checkers, maxpnt, Array)
  local pg, ph, retperm, n, i, newarray;

  n := Length(Array);

  # First we look for permutations which map [1..n] to Array
  # if any return fail, then return fail
  # Remember that groupCheckers[i] is a function!
  for i in [1..Length(checkers)] do
    if checkers[i]([1..n], Array) = fail then
      Info(InfoGroup, 3, "FEE: No permutation for group ", i, " for ", Array);
      return fail;
    fi;
  od;

  # Check if we have assigned all points, in which case we
  # know what the permutation is!
  # PermList will turn a list into a GAP permutation
  if n = maxpnt then
    Info(InfoGroup, 3, "FEE: Found ", PermList(Array));
    return PermList(Array);
  fi;

  # We need to recursively search. Let's try adding a new member
  # to our array.  We don't bother skipping the case where we would
  # build non-permutations, they will fail in the checkers.
  Info(InfoGroup, 3, "FEE: Extending ", Array, " with another point");
  for i in [1..maxpnt] do
    newarray := Concatenation(Array, [i]);
    retperm := FindExtendingElement(checkers, maxpnt, newarray);
    if retperm <> fail then
      return retperm;
    fi;
  od;
  return fail;
end;
{% endhighlight %}

Let's try running our function:

{% highlight gap %}
SetInfoLevel(InfoGroup, 3);
FindExtendingElement([GroupChecker(G), GroupChecker(H)], 6, [3]);
#I  FEE: Extending [ 3 ] with another point
#I  FEE: No permutation for group 2 for [ 3, 1 ]
#I  FEE: Extending [ 3, 2 ] with another point
#I  FEE: Extending [ 3, 2, 1 ] with another point
#I  FEE: No permutation for group 1 for [ 3, 2, 1, 1 ]
#I  FEE: No permutation for group 1 for [ 3, 2, 1, 2 ]
#I  FEE: No permutation for group 1 for [ 3, 2, 1, 3 ]
#I  FEE: Extending [ 3, 2, 1, 4 ] with another point
#I  FEE: No permutation for group 1 for [ 3, 2, 1, 4, 1 ]
#I  FEE: No permutation for group 1 for [ 3, 2, 1, 4, 2 ]
#I  FEE: No permutation for group 1 for [ 3, 2, 1, 4, 3 ]
#I  FEE: No permutation for group 1 for [ 3, 2, 1, 4, 4 ]
#I  FEE: Extending [ 3, 2, 1, 4, 5 ] with another point
#I  FEE: No permutation for group 1 for [ 3, 2, 1, 4, 5, 1 ]
#I  FEE: No permutation for group 1 for [ 3, 2, 1, 4, 5, 2 ]
#I  FEE: No permutation for group 1 for [ 3, 2, 1, 4, 5, 3 ]
#I  FEE: No permutation for group 1 for [ 3, 2, 1, 4, 5, 4 ]
#I  FEE: No permutation for group 1 for [ 3, 2, 1, 4, 5, 5 ]
#I  FEE: Found (1,3)
# (1,3)
{% endhighlight %}

One nice thing about our algorithm -- no part of it requires we intersect
only two groups. Let's now try making a full intersection algorithm!

Aside - LargestMovedPoint
=========================

We assume our permutation groups are acting on a finite set $$\{1\dots n\}$$. But, how do we find $$n$$? GAP does not store this value -- it acts as if all groups act on $$\mathbb{N}$$, the set of all natural numbers. We could pass $$n$$ around in all our functions, but instead we use the function ```LargestMovedPoint(G)```. This function gives us the largest integer $$n$$ such that $$\exists p \in G. n^p \neq n$$. We can ignore any larger points, as they can't be moved.

{% highlight gap %}
# Find the intersection of two permutation groups G and H on [1..n],
# assuming that G and H both fix [1..pnt]
# (pnt might be 0, then G and H may fix nothing)
BasicIntersectionLoop := function(G, H, n, pnt)
  local loopgroup, loopG, loopH, i, cosetreps, rep;

  # Base case: If either G or H is the identity group, the
  # intersection is the identity group! Return list of
  # generators
  if G = Group(()) or H = Group(()) then
    Info(InfoGroup, 1, "Reached intersection base");
    return [()];
  fi;

  # Perform a recursive call for intersection of point
  # stabilizer of pnt + 1
  loopG := Stabilizer(G, pnt + 1);
  loopH := Stabilizer(H, pnt + 1);
  loopgroup := BasicIntersectionLoop(loopG, loopH, n, pnt + 1);

  # Now look for coset representatives
  cosetreps := [];
  for i in [pnt + 2..n] do
    rep := FindExtendingElement([GroupChecker(G), GroupChecker(H)], n,
                                Concatenation([1..pnt], [i]));
    if rep <> fail then
      Add(cosetreps, rep);
    fi;
  od;

  return Concatenation(loopgroup, cosetreps);
end;

# This just sets up our recursive loop, finding the set which G
# and H act on (using LargestMovedPoint)
BasicIntersection := function(G, H)
  local lmp;
  lmp := Maximum(LargestMovedPoint(G), LargestMovedPoint(H));
  return Group(BasicIntersectionLoop(G, H, lmp, 0));
end;
{% endhighlight %}

Now we have a basic intersection algorithm, which produces a set of generators! How can we improve this search? There are several ways. We will begin by heading off in a totally different direction, into _graph isomorphism_.
