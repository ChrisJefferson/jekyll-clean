---
layout: post
title: Introduction to Permutation Groups
tags: GAP
---


This post provides an introduction to algorithms on permutation groups, building towards _Stabilizer Chains_, the most important data structure for computing with permutation groups.

In this post, we will assume we are working with finite permutation groups in GAP. Before reading this post, please go and install GAP so you can play along! You can download all the code from this post here:

<a class="btn btn-primary" href="/code_extracts/2016-10-18-introduction_to_perm_group_algorithms.markdown.g">
   Download all code
</a>

Introduction
------------

Let's begin with a simple permutation group:

{% highlight gap %}
G := Group((1,3,2)(5,11,6,9,7,10)(8,12)(13,15,14),
           (1,9,5)(2,11,6,3,10,7)(4,12,8)(14,15));
{% endhighlight %}

There are many obvious questions we might want to answer about `G`, some simple examples include:

{% highlight gap %}
# What is the orbit of 1 in G?
Orbit(G, 1);
# [ 1, 2, 5, 6, 3, 7, 9, 10, 11 ]

# What is the orbit of 4 in G?
Orbit(G, 4);
# [ 4, 8, 12 ]

# Does G contain a given permutation?
(5,9)(6,10)(7,11)(8,12) in G;
# true

# What is the size of G?
Size(G);
# 36

# Which subgroup of G fixes 4?
Stabilizer(G, 4);
# Group((2,3)(6,7)(10,11)(14,15),
#       (1,3,2)(5,11,6,9,7,10)(8,12)(13,15,14))
{% endhighlight %}

How does GAP calculate each of these values? If we exhaustively calculated every element of `G` then calculating each of these results will be fairly trivial, but for larger groups that rapidly becomes impractical.

Orbit Calculation
-----------------

We will begin by calculating the orbits. This is the easiest thing to calculate, and a vital building block towards stabilizer chains.

Calculating the orbit of an integer is mathematically simple -- keep applying the generators to the point, it's image, its image's images... until a fixed point is reached. This is easier to understand in GAP! This function is a little inefficient, but will serve our early purposes.

{% include code-link.html lang="gap" file="calculateorbitslow.g" %}

Let's write a couple of simple tests, to convince ourselves our function works.

{% highlight gap %}
CalculateOrbitSlow(G, 1);
# [ 1, 3, 9, 2, 10, 7, 5, 11, 6 ]
CalculateOrbitSlow(G, 4);
# [ 4, 12, 8 ]
{% endhighlight %}

This function has two limitations: Firstly, it is a inefficient because the line `p^g in knownOrbit` is slow -- it has to search through the whole orbit we have seen so far. Secondly, in practice we often want to know the permutation which will get us to each point in the orbit, but we throw that information away!

So, let's do an improved version. Here we will start with a `base` value, and then track whenever we find a new value in the orbit, which permutation got us there. By following the permutations we will be able to get back to the `base`.

Enough chat, I find this data structure is easier to understand once you have it:

{% include code-link.html lang="gap" file="schreiervector.g" %}

Notice that line `img := p/g`. You might not have seen `/`. This returns the value `p` maps to `g`. It's the same as applying `g` to the inverse of `p`, but is more efficient.

Why do we do this? Well, we want to be able to get back to the base. We could instead store the inverse of `p`, but that would require inverting the permutations.

So, what is this vector useful for? It's main use is to let us find a permutation which maps any integer back to our ``base'' point. I would play with this function for a while, to be sure you really understand why it works!

{% include code-link.html lang="gap" file="representativeperm.g" %}

Let's see how this function works in practice. It gives a permutation which maps it's first argument back to the base point, or returns `fail` if no such permutation exists.

{% highlight gap %}
sch := CalculateSchreier(G, 1);;
RepresentativePerm(sch, 2);
# (1,3,2)(5,11,6,9,7,10)(8,12)(13,15,14)
RepresentativePerm(sch, 6);
# (1,10,5,2,9,6)(3,11,7)(4,12,8)(13,14)
RepresentativePerm(sch, 4);
# fail
{% endhighlight %}

Given these two together, we can take a permutation $$p$$ and a group $$G$$ and find another permutation $$q$$, where $$q$$ is in $$G$$ if and only if $$p$$ is, and $$q$$ fixes the base point of our schreier vector. This function looks like this:

{% include code-link.html lang="gap" file="maptobase.g" %}

This function takes a permutation and multiplies it by a permutation in our group, to fix the base point (or returns fail if no such permutation exists).

{% highlight gap %}
sch := CalculateSchreier(G, 1);;
MapToBase(sch, (1,2,3,4));
# (3,4)(5,11,6,9,7,10)(8,12)(13,15,14)
MapToBase(sch, (1,4));
# fail
{% endhighlight %}


So, we have turned the problem of finding if a permutation is in our group to the problem of finding if a different permutation is in the stabilizer of a single point in that group.

So how do we solve this problem? Well, build `Stabilizer(G,1)`, build a schreier vector for that, and recurse until no group is left!

{% include code-link.html lang="gap" file="stabilizerchain.g" %}

Now we have a stabilizer chain, we are (finally) in a position to implement checking if a permutation is in a group. This function is quite long, but follows a basic recursive design:

* Look where the permutation \(p\) maps the base point. Is that outside the orbit of the base point? Then it is not in our group \(G\).
* Calculate a permutation \(q\) in \(G\) such that \(p.q\) maps the base point to itself, then search in the stabilizer.

The final terminating case is to detect when we reach the bottom of the stabilizer chain, in which case we must have the identity permutation left.

{% include code-link.html lang="gap" file="permingroup.g" %}

{% highlight gap %}
chain := StabilizerChain(G);;
PermInGroup(chain, (1,5)(2,6)(3,7)(4,8));
# true
PermInGroup(chain, (1,5)(2,6)(3,7)(4,9));
# false
{% endhighlight %}


So, what else can we do with a stabilizer chain? Lots of things, almost anything which explores a group. Here is one easy thing we can do -- find the size of the group using the orbit - stabilizer theorem.

{% highlight gap %}
GroupSize := function(stabchain)
    if not IsBound(stabchain.stabilizer) then
        return Length(stabchain.orbit);
    fi;
    return Length(stabchain.orbit) *
           GroupSize(stabchain.stabilizer);
end;

GroupSize(chain);
# 36
{% endhighlight %}


We can do much more interesting calculations, like begin to build a group intersection algorithm.
