---
layout: post
title: GAP Types and Filters
---

How GAP handles types is very unusual compared to most other programming languages. In particular, the type of a variable will change over time. This is because some parts of the type, such as if a group is finite, commutative or polycyclic, can be discovered over time.

This can be most easily seen by a concrete example, so we'll do that first, and then we'll look into how this arises.

Firstly, let's set up a operation. Don't worry too much about all this code, we'll discuss it in a moment!

{% highlight gap %}
DeclareOperation( "Cheese", [ IsGroup ]);
InstallMethod( Cheese, [ IsGroup ],
	function(x) Print("Group"); end);
InstallMethod( Cheese, [ IsPolycyclicGroup ],
	function(x) Print("Polycyclic"); end);
g := Group((1,2),(3,4));
Cheese(g);
# Group
Size(g);
# 4
Cheese(g);
# Polycyclic
{% endhighlight %}
