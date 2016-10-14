---
layout: post
title: Introduction to Backtrack Search
tags: Algorithms
---

This is the first in a series of articles which will explore backtracking search in permutation groups. To begin, these articles will concentrate on the theory of backtracking, rather than highly-optimised implementations.

If you have any comments or corrections on these pieces, or just enjoyed reading them and want more, please [e-mail me](mailto:caj21@st-andrews.ac.uk).

I will assume you are familiar at least with [permutations](https://en.wikipedia.org/wiki/Permutation), [permutation groups](https://en.wikipedia.org/wiki/Permutation_group). Also all code examples will be given in the [GAP](http://gap-system.org/) language. I strongly recommend installing GAP and following along!

Introduction
============

Let's dive straight in, and consider the problem of intersecting two permutation groups $$G$$ and $$H$$ on the set $$\Omega = \{1..n\}$$. We will assume we are given $$G$$ and $$H$$ by a set of generators. In GAP, we can give two groups, and find their intersection, as follows: 

{% highlight gap %}
G := Group((1,2,3), (1,2), (1,4)(2,5)(3,6));
H := Group((1,3,6), (3,6), (1,2)(3,4)(5,6));
R := Intersection(G,H);
# Group([ (4,5), (1,3)(4,5), (1,4,3,5)(2,6) ])
{% endhighlight %}

<aside>
We will use `#` to show GAP's output
</aside>

How can we implement the ```Intersection``` function? Your first assumption might be that there is some clever mathematical trick we can apply which instantly produces the intersection, but (as far as we currently know) there isn't! Therefore, let's consider some possible implementations.

The most naive implementation would be to generate all permutations in $$G$$, and check if they are in $$H$$:

{% highlight gap %}
IntersectionEnumerate := function(G1,G2)
  local result, g;
  result := [];
  for g in G1 do
    if g in G2 then
      Add(result, g);
    fi;
  od;
  return Group(result);
end;

IntersectionEnumerate(G, H);
# Group([ (), (4,5), (1,3), (1,3)(4,5), (1,4)(2,6)(3,5),
#          (1,4,3,5)(2,6), (1,5,3,4)(2,6), (1,5)(2,6)(3,4) ])
{% endhighlight %}

One obvious problem here is haven't we just changed one piece of magic (```Intersection```) for two different pieces of magic (```for g in G1``` and ```if g in G2```)?

Iterating over the members of a permutation group, checking if a given permutation is in a group, and a number of other important methods (which we will discuss shortly) can all be efficiently implemented using a _base and strong generating set_, also known as a _stabilizer chain_. In a future post we will see how to make stabilizer chains, and how to implement methods like ```g in G1```.

If your only interest is worst-case complexity over all permutation groups, ```IntersectionEnumerate``` is surprisingly close to the state of the art! None of the algorithms we will discuss will ever beat this algorithm by very much, for all pairs of groups. However, we can (as you might hope) greatly outperform this algorithm for many pairs of permutation groups.

The fundamental idea behind all of our improvements revolve around *backtracking search*, also known as divide-and-conquer. We will take our problem and split it up into sub-problems, which will be (hopefully) easier to solve, and then stitch our answers back together to form the entire group we are looking for.

Basic Backtracking
==================

So, how can we split the search for ```Intersection(G,H)``` up? One natural method of attack if to consider searching for subgroups and cosets contained inside the group we are interested in. Let's try that!

A Brief Aside: Point stabilizer
===============================

The point stabilizer of an integer $$x$$ in a permutation group $$G$$ is the subgroup of $$G$$ which fixes $$x$$. This is often represented as $$G_x$$. How can we find this subgroup in GAP? Firstly, lets write a slow function:

{% highlight gap %}
StabPointEnumerate := function(G,x)
  local result, g;
  result := [];
  for g in G do
    if x^g = x then
      Add(result, g);
    fi;
  od;
  return Group(result);
end;

StabPointEnumerate(G, 1);
# Group([ (), (5,6), (4,5,6), (4,5), (4,6,5), (4,6),
#          (2,3), (2,3)(5,6), (2,3)(4,5,6), (2,3)(4,5),
#          (2,3)(4,6,5), (2,3)(4,6) ])
{% endhighlight %}

However, actually finding the point stabilizer is another thing we can calculate using a Stabilizer Chain. They are great aren't they! In GAP, we do this by:

{% highlight gap %}
Stabilizer(G, 1);
# Group([ (4,6,5), (5,6), (2,3) ])
{% endhighlight %}

Notice how ```Stabilizer``` has printed out a shorter answer than ```StabPointEnumerate```. These represent the same group, but `Stabilizer` has produced a set of generators, rather than every element of the group.

Back to Backtracking
====================

So, we will split the problem of finding $$G \cap H$$ into pieces, by splitting our problem up into $$n$$ pieces:

* Find $$p \in G \cap H$$ where $$1^p = 1$$.
* Find $$p \in G \cap H$$ where $$1^p = 2$$.
* ...
* Find $$p \in G \cap H$$ where $$1^p = n$$.

Let's first consider the first set. A permutation $$p$$ where $$1^p=1$$ is in $$G \cap H$$ where $$1^p=1$$ if and only if it is contained in both ```Stabilizer(G,1)``` and ```Stabilizer(H,1)```. Therefore we just need to find ```Intersection(Stabilizer(G, 1), Stabilizer(H,1))```. While this is another intersection problems, it will be (hopefully) an easier one to solve. Let's call this intersection $$R$$.

Now we are going to apply a little group theory. We know that $$R \subseteq G \cap H$$. This means we can divide $$G \cap H$$ into a list of cosets of $$R$$. Let's pick a single permutation in some coset of $$R$$ -- for example $$q = (1,3)(4,5)$$ (which we know is in $$G \cap H$$, as we found it earlier during our brute force enumeration).

As all $$p \in R$$ satisfy $$1^p=1$$, then all permutations in the coset $$qR$$ will satisify $$1^p=3$$. In general, in each of our subproblems, we will find either:

* A coset of $$R$$
* No permutations

(A full proof of this is left to interested reader..)

Therefore, we don't need to find all solutions to all of our sub-problems after the first -- we only need to find one permutation from each (or prove no permutation exists)! Already a big gain in performance.

How can we find quickly which of these sub-searches contains a permutation from $$G \cap H$$? That problem has been the subject of a huge amount of research. We will discuss some methods of implementing this in coming articles.
