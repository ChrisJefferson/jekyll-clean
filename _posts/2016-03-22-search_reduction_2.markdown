---
layout: post
title: Search Reduction 2
tags: Algorithms
---


Making use of partial knowledge of $$G \cap H$$
=============================================

We can prove some parts of our search don't have to be performed. Early in search we find the permutation $$(4,5) \in G \cap H$$. Later, we try finding a permutation where $$1^p = 4$$. There is no need after this to search for a permutation where $$1^p = 5$$. Why? There are two cases:

** There is a permutation where $$1^p = 4$$ (in this problem there is, $$(1,4)(2,6)(3,5) \in G \cap H$$). We can find a permutation where $$1^p = 5$$ by multiplying these two permutations together, to get $$(1,5,3,4)(2,6)$$.

** If we had found no permutation where $$1^p = 4$$ in $$G \cap H$$, there is no point searching for one where $$1^p=5$$, as if we found such a permutation, we could again multiply it by $$(4,5)$$ and get a permutation where $$1^p = 4$$, which can't exist!

How can we formalise this idea? As we find members of $$G \cap H$$, we keep track of the orbits of $$G \cap H$$ and only check one value in each orbit. An exact discussion of this algorithm will appear in a future post!

Proving parts of search contain no element of $$G \cap H$$.
=========================================================

This is where the majority of the research into improving backtrack search in permutation groups (and backtrack searches in general) is performed.

Looking at the output of ```FindExtendingElement```, there are a number of easy ways it can be improved. We certainly shouldn't test mappings like ``[ 3, 2, 1, 1 ]``, as permutations are invertible!

More generally, let us consider the second stage of our search, when we are looking for $$G_1 \cap H_1$$. We can ask GAP to give us the orbits of $$G_1$$ and $$H_1$$:

{% highlight gap %}
Orbits(Stabilizer(G, 1));
# [ [ 2, 3 ], [ 4, 5, 6 ] ]
Orbits(Stabilizer(H, 1));
# [ [ 2, 4, 5 ], [ 3, 6 ] ]
{% endhighlight %}

From this, we can deduce the orbit of $$2$$ in $$G_1 \cap H_1$$ must be contained in $$\{2,3\} \cap \{2,4,5\}$$, which means that actually the orbit of $$2$$ is just $$\{2\}$$!

By the same reasoning, both $$3$$ and $$6$$ are fixed, leaving the only non-trivial orbit as $$\{4,5\}$$. Of course, this does _not_ mean that $$G_1 \cap H_1$$ contains a permutation $$p$$ where $$4^p = 5$$, this orbit may still split. However, this is the only case which we need to consider. We have reduced our search for $$G_1 \cap H_1$$ to having to consider a single permutation: $$(4,5)$$!
