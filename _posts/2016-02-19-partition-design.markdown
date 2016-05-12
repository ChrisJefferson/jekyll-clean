---
layout: post
title: Introduction to Partitions
category: Algorithms
---


This post introduces *ordered partitions*, which are used in both graph isomorphism and partition backtracking, and some simple (and inefficient!) implementations of ordered partitions in GAP.

This post is only of interest if you plan on going on to learn about graph isomorphism or partition backtracking.


Cell representation
===================

An ordered partition of a set $$\Omega$$ is a partition of $$\Omega$$ where the cells of the partition are ordered. Let's give an example!

Given the set $$\{1\dots 6\}$$, one ordered partition is $$[\{2,3,6\}, \{1\}, \{4,5\}]$$. Here the first *cell* of the partition is the set $$\{2,3,6\}$$, the second is $$\{1\}$$ and the last is $$\{4,5\}$$. No value occurs in more than one cell, and the unions of the cells is $$\{1\dots 6\}$$.

How can we represent this in GAP? The easiest option is as a list of lists. We call this the *explicit* representation.

{% highlight gap %}
part := [ Set([2,3,6]), Set([1]), Set([4,5]) ];
{% endhighlight %}


In GAP, a ```set``` is just an list of increasing members, so this is the same as writing:

{% highlight gap %}
part := [ [2,3,6], [1], [4,5] ];
{% endhighlight %}


We can sanity check we have all our values by using ```Union``` to merge our list of sets:

{% highlight gap %}
Union(part);
# [1 .. 6 ]
{% endhighlight %}

Simple Indicator Representation
===============================

There is one bad feature of this representation -- it is very expensive to find which cell a particular value is contained in. Therefore let's consider a second representation, known as the *simple indicator* representation. This maps each value to the number of the cell it is contained in. For example, ```part``` from the previous example is represented by the list ```l := [2,1,1,3,3,1]```. The *simple indicator* and *explicit* representations are linked by the condition $$l[i] = j \iff j \in part[i]$$.


Indicator Representation
========================

The *indicator* representation is like the *simple indicator* representation, except we allow the array to contain any values, not just the integers in a range `[1..k]`. For example, `lx := [2, -6, -6, "Q", "Q", -6]`. Two values $$i$$ and $$j$$ are in the same cell of the partition if and only if $$lx[i] = lx[j]$$.

But wait, we want ordered partitions! What ordering is there on `2`, `-6` and `"Q"`? We will order these however GAP orders them, and say this is the ordering of the cells! (in this case,`-6 < 2 < "Q"`, so this is the same example we've been using throughout). By design, a *simple indicator* representation is also a *indicator* representation.

Here are a couple of GAP functions, which provide mappings between the *explicit*  and *indicator* representations. Firstly, we will map *explicit* to *indicator* (actually, we always make a *simple indicator*:

{% highlight gap %}
CellsToList := function(cells)
	local cellpos, i, j;
	cellpos := [];
  # Iterate over all the cells
	for i in [1..Length(cells)] do
    # Iterate over the members of each cell
		for j in cells[i] do
			cellpos[j] := i;
		od;
	od;
	return cellpos;
end;

CellsToList([ [2,3,6], [1], [4,5] ]);
# [ 2, 1, 1, 3, 3, 1 ]
{% endhighlight %}

And now, let's go back the other way! The first this we do is gather all the values in the array into a GAP `Set`. We can then use `Position` to find the index of a value in that set.

{% highlight gap %}
ListToCells := function(cellpos)
	local cells, labels, i;
	# Find all unique cell labels
	labels := Set(cellpos);
	# make an empty list of cells
	cells := List([1..Length(labels)], x -> []);
	# Fill the cells
	for i in [1..Length(cellpos)] do
		AddSet(cells[Position(labels, cellpos[i])], i);
	od;
	return cells;
end;

ListToCells( [ 2, 1, 1, 3, 3, 1 ] );
# [ [ 2, 3, 6 ], [ 1 ], [ 4, 5 ] ]

{% endhighlight %}


Refining Partitions
===================

An obvious question is, why have this horrible *indicator* representation at all? The reason is it makes it easy for us to express one of the most important operations we will perform on partitions, _refinement_.

Given two (possibly ordered) partitions $$P$$ and $$Q$$, which both partition the same set $$\{1\dots n\}$$, $$Q$$ is a refinement of $$P$$ if every cell of $$Q$$ is contained in a cell of $$P$$. Alternatively, $$Q$$ can be created by splitting cells of $$P$$.

*Important Aside:* There is another definition of refinement which is stricter and imposes an order on the cells of $$Q$$ -- this requires, if $$P$$ has $$j$$ cells, that $$\forall i in {1..j}. Q[i] \subseteq P[i]$$. 

Let's consider a couple of ways of taking a partition, and generating a refinement of it. These will both be used over and over again in both partition backtrack, and graph automorphism detection.

Fixing a single point
---------------------

Consider a partition in *Cell* format, let's consider our long-running example `part := [ [2,3,6], [1], [4,5] ];`. We want to take this and generate a new partition, where a single value has been extracted an placed in a cell by itself. For example, if we fixed `3`, we might get `[ [2,6], [1], [4,5], [3] ]`. Alternatively, we might get `[ [1], [3], [2,6],  [4,5] ]`, because refining a partition does not make use of the order of the cells.

The easiest way to fix a single point is to switch to *indicator* representation, and change the value. Here is a function which accepts a *cell* input:

{% highlight gap %}
FixPoint := function(cells, point)
  local indic;
	indic := CellsToList(cells);
	indic[point] := infinity;
	return ListToCells(indic);
end;

FixPoint( [ [2,3,6], [1], [4,5] ], 3);
# [ [ 3 ], [ 2, 6 ], [ 1 ], [ 4, 5 ] ]
{% endhighlight %}

The meet of two partitions
--------------------------

Given two ordered partitions `P` and `Q`, we can define their *meet* as a new partition `R`, where two points are in the same cell of `R` if and only if they are in the same cells of both `P` and `Q`. Implementing this is easy (we will assume `P` and `Q` partition the same set). We will *meet* partitions frequently, while implementing partition backtracking.

{% highlight gap %}
PartitionsMeet := function(P, Q)
  local indicP, indicQ, indicJoin;
	indicP := CellsToList(P);
	indicQ := CellsToList(Q);
	indicJoin := List([1..Length(indicP)], i -> [indicP[i], indicQ[i]]);
	return ListToCells(indicJoin);
end;

PartitionsMeet([ [1,2,3], [4,5] ], [ [1,2], [3,4,5] ]);
# [ [ 1, 2 ], [ 3 ], [ 4, 5 ] ]
{% endhighlight %}

Applying permutations to partitions
--------------------------

Given an ordered partition `Q` and a permutation `p`, we define the action of `p` on `Q` as mapping each point in each cell of `Q` by `p`. GAP already has a function to do this, `OnTuplesSets`:

{% highlight gap %}
OnTuplesSets([ [2,3,6], [1], [4,5] ], (1,2,3,4,5,6));
# [ [ 1, 3, 4 ], [ 2 ], [ 5, 6 ] ]
{% endhighlight %}

In out searches, we will often want to look at all the permutations which map an ordered partition to itself, or one ordered partition to another. We will now give some quick results in this area, without proof.

* Given an ordered partition $$P$$, the set of permutations $$p$$ such that $$P^p = P$$ is generated by the symmetric group of each cell of $$P$$.

GAP already uses this result internally.

{% highlight gap %}
Stabilizer(SymmetricGroup(5), [ [1,3], [2,4,5] ], OnTuplesSets);
# Group([ (2,4), (2,4,5), (1,3) ])
{% endhighlight %}

*Definition:* Two ordered partitions `P` and `Q` are _agreeable_ if the number of cells in `P` is equal to the number of cells in `Q`, and for all `i`, the size of `P[i]` is equal to the size of `Q[i]`. This is, I think, easier to read as a function!

{% highlight gap %}
Agreeable := function(P,Q)
	if Size(P) <> Size(Q) then
		return false;
	fi;

	return ForAll([1..Size(P)], i -> Size(P[i]) = Size(Q[i]));
end;

Agreeable([ [1,2,3], [4,5] ], [[1,2], [3,4,5] ]);
# false
Agreeable([ [1,2,3], [4,5] ], [[1,2,3], [3,4,5] ]);
# false
Agreeable([ [1,2,3], [4,5],[5] ], [[1,2,3], [4,5] ]);
# false
Agreeable([ [1,2,3], [4,5] ], [[1,2,3], [4,5],[5] ]);
# false
Agreeable([ [1,2,3], [4,5] ], [[1,2,3], [4,5] ]);
# true
{% endhighlight %}

So, why is agreeable useful? For the following mini-lemma!

* Given two ordered partitions `P` and `Q`, there exists a permutation `p` which maps `P` to `Q` if and only if `P` and `Q` are agreeable.

One direction of this lemma is trivial -- if `P` and `Q` aren't agreeable, then there can't be any mapping from `P` to `Q`, as any image of `P` will be agreeable with `P`. If `P` and `Q` are agreeable, then we can easily construct a mapping from `P` to `Q` by imposing any ordering on the cells of `P` and `Q`, and mapping them pointwise. As every integer occurs exactly once in `P` and `Q`, this will define a permutation.

We can use this to construct all the mappings of `P` to `Q`. We can also construct them more easily using the fact that they form a coset of the mappings of `P` to itself.

Now we have a giant pile of partition-related results, we can start using them to do interesting things!
