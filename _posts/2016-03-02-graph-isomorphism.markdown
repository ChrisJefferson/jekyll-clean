---
layout: post
title: Implementing Graph Isomorphism
tags: Algorithms
---

This post is part of a series of articles about backtrack search in groups. You should really read [intro to backtrack]( {% post_url 2015-11-13-intro_to_backtrack %} ) and [search reduction 1]( {% post_url 2015-11-13-search_reduction_1 %} ) first. This page will discuss implementing a modern graph isomorphism tester. 

Before reading this post, you should go and read [about ordered partitions]( {% post_url 2016-02-19-partition-design %} ), or at least be aware of that post. It introduces some important data structures we are going to use here. 

Graph representation
====================

Before we begin, we need to represent a graph! There are many papers, which discuss how to efficiently represent graphs. There are also excellent packages in GAP which can efficiently represent graphs. For this post we are going to use the _digraphs_ package. This already includes [bliss](http://www.tcs.hut.fi/Software/bliss/), a high quality graph isomorphism detector, but we are going to write our own anyway!

Firstly, we need to load the digraphs package (if you don't have it, you might need a more recent GAP)

{% highlight gap %}
LoadPackage("digraphs");
{% endhighlight %}

There are several ways to build a directed graph. We will use the method of giving the adjacency list -- this is a list `L`, where `L[i]` is the vertices which `i` is connected to.

{% highlight gap %}
d1 := Digraph([ [2], [3], [4], [1], [1,2,3,4] ]);
# <digraph with 5 vertices, 8 edges>
Print(d1);
# Digraph( [ [ 2 ], [ 3 ], [ 4 ], [ 1 ], [ 1, 2, 3, 4 ] ] )
d2 := Digraph([ [2], [3], [4,5], [1,5], [] ]);
# <digraph with 5 vertices, 6 edges>
Print(d2);
# Digraph( [ [ 2 ], [ 3 ], [ 4, 5 ], [ 1, 5 ], [ ] ] )
{% endhighlight %}


So, what do we want to find? We want to find the *automorphisms* of a digraph -- the group of permutations on the vertices of a digraph which map the digraph to itself. In GAP this is easy to calculate. The function to find the image of a digraph under a permutation is `OnDigraphs`, and we can use `Filtered` to look through the `SymmetricGroup` for all permutations which map a graph to itself, like this!
{% highlight gap %}
Filtered(SymmetricGroup(5), g -> (OnDigraphs(d1, g) = d1));
# [ (), (1,2,3,4), (1,3)(2,4), (1,4,3,2) ]
Filtered(SymmetricGroup(5), g -> (OnDigraphs(d2, g) = d2));
# [ () ]
{% endhighlight %}

So, the automorphism group of `d1` is the cyclic group on 4 points, and for `d2` it is the Trivial group. So, we are done, article finished!

Except, this is a very inefficient way of calculating the automorphism group of a digraph. Surely we can be more efficient? Actually, we can't do much better than this _in the worst case_. There are graphs where the best algorithms known don't perform (much) better than this. However, for many many graphs we can do much, much better. Let's look at how.

colour color

Partition Filtering
===================

This first part reduces the amount of search we have to do by looking at the graph. Let's look at one of our graphs:

<div id="graph1"></div>
<script>
loadGraph("#graph1","/assets/graphs/Example-d1.json");
</script>

(Don't like how the graph is laid out? You can drag vertices around, or use the drop-down menu to pick another graph!)

How can we make finding automorphisms easier? Let's begin with a super-simple theorem (so simple, it barely feels like it qualifies!)

*It is a truth universally acknowledged, that a vertex in possession of $$n$$ neighbours, must be mapped by any automorphism to another vertex with $$n$$ neighbours.*

So, the one vertex in the graph above with 4 neighbours must be mapped to itself. Click the _filter_ button, which will colour vertices so only vertices with the same number of in, and out, edges are the same colour.

With some graphs, we can do much better. Let's look at our other example graph:

<div id="graph2"></div>
<script>
loadGraph("#graph2","/assets/graphs/Example-d2.json");
</script>

Press _filter_ once, and you will see we split our vertices into three classes:

1) One edge in, one edge out
2) Two edges in, one edge out
3) Two edges out

So we have already reduced our search from the original $$5!$$ permutations in $$S_5$$ to $$4$$ permutations (we can choose if we swap the two vertices in class _1_, and independently choose if we swap the two vertices in class _2_).

However, we can go further! We can extend our mini-theorem. Not only must a vertex map to a vertex with the same number of in-edges and out-edges, but if a vertex has (for example) one edge which connects to a class _1_ vertex, it's image must also have an edge connected to a class _1_ vertex.

Press _filter_ again to see what difference this makes. All vertices are now different colours, and we have proved this graph has only one automorphism -- the trivial one. For completeness, here are the classes we have deduced:

A) Vertex from class _1_: One edge going to class _1_, one from class _2_
B) Vertex from class _1_: One edge going to class _2_, one from class _1_
C) Vertex from class _2_: One edge going to class _2_, one edge from classes _1_ and _3_.
D) Vertex from class _2_: One edge going to class _1_, one edge from classes _2_ and _3_.
E) Vertex from class _2_: Two edges going to class _2_.

Now, this process doesn't always work -- there are graphs with only the trivial isomorphism, but where this process is unable to split the vertices into classes -- for example, the Frucht graph:

<div id="graph3"></div>
<script>
loadGraph("#graph3","/assets/graphs/Frucht.json");
</script>

There are methods of filtering the Frucht graph. For example, some vertices have two connected neighbours, while other vertices have three disconnected neighbours. For now, let's consider how we can implement the most simple kind of filtering.

G-invariant functions
=====================

{% highlight gap %}
filterGraph := function(cells, digraph)
    local celllist, filter, f, edge;
    celllist := CellsToList(cells);
    # Start making a lists of lists, whose
    # first member is the original cell number
    filter := List(celllist, x -> [x]);
    # Add each edge
    for edge in DigraphEdges(digraph) do
        Add(filter[edge[1]], [ 1, celllist[edge[2]] ]);
        Add(filter[edge[2]], [-1, celllist[edge[1]] ]);
    od;
    for f in filter do
        Sort(f);
    od;
    return ListToCells(filter);
end;
{% endhighlight %}


{% highlight gap %}
fullyPropagateConstraints := function(cells, conlist)
    local cellcount, con;

    # Make -1 to force at least one loop to occur
    cellcount := -1;
    while cellcount <> Length(cells) do
        cellcount := Length(cells);
        for con in conlist do
            cells := con(cells);
        od;
    od;
    return cells;
end;
{% endhighlight %}

{% highlight gap %}
conList := [ x -> filterGraph(x, d1), x -> filterGraph(x, d2) ];;
fullyPropagateConstraints([[1..5]], conList);
{% endhighlight %}


{% highlight gap %}
branchFirstCell := cells -> First([1..Length(cells)], x -> Size(cells[x]) > 1);
branchSmallCell := function(cells)
    local bestindex, bestsize, i;
    bestindex := fail;
    bestsize := infinity;
    for i in [1..Length(cells)] do
        if Size(cells[i]) > 1 and Size(cells[i]) < bestsize then
            bestindex := i;
            bestsize := Size(cells[i]);
        fi;
    od;
    return bestindex;
end;
{% endhighlight %}


{% highlight gap %}
# rBase := rec( refinedCells := , branchCell := , branchValue := , nextLevel := )

buildrBase := function(cells, constraintList, branchOrder)
    local rBaseRoot, rBase, branchCell;
    rBaseRoot := rec();
    rBase := rBaseRoot;
    while true do
        cells := fullyPropagateConstraints(cells, constraintList);
        branchCell := branchOrder(cells);
        rBase.cells := StructuralCopy(cells);
        if branchCell = fail then
            return rBaseRoot;
        fi;
        rBase.branchCell := branchCell;
        rBase.branchValue := Minimum(cells[branchCell]);
        cells := FixPoint(cells, rBase.branchValue);
        rBase.nextLevel := rec();
        rBase := rBase.nextLevel;
    od;
end;
{% endhighlight %}
