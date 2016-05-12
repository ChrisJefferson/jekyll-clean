---
layout: post
title: Common mistakes with GAP's memory manager
---

The following post will only be of interest to people who:

* Care about GAP's internals
* Already know C

I'm also going to not explain much about GAP kernel programming in general -- if you would like me to, then [tell me](mailto:caj21@st-andrews.ac.uk) and I might write something up! This post is divided into two parts. A brief overview of gasman, GAP's memory manager, and then some practical examples of errors I have found.

Overview
========

The most important feature of GAP's memory manager for this post is that it *moves memory* on garbage collection. This causes problems, because in C it is natural to have pointers, and these pointers can become invalidated.

So, how does GAP represent memory, and do this garbage collection? How, when we move an object, can we ensure that everyone pointer to that object is updated to it's new location?

The answer is (as with many things in computing), another layer of indirection. The `NewBag` is the function that returns a newly allocated block of memory. This function does NOT return a pointer directly to the new block of memory. Instead, it returns a `Bag`, which points to the new block of memory. We can see this from the definition of bag:

{% highlight C %}
typedef UInt * * Bag;
{% endhighlight %}

To get to the actual allocated memory, we must dereference our `Bag` twice. So, what does this complexity buy us? It gives us only one place to update when we move the underlying memory! When we want to move the memory of this `Bag`, we need only update the intermediate pointer. 

Here is some pseudo-code showing the idea (don't do this in practice, GAP has other bookkeeping to do!).

{% highlight C %}
void moveBag(Bag b, void* newLocation, size_t len) {
	// First, move the Bag's contents
	memcpy(newLocation, *b, len);
	// Then, move the master pointer
	*b = newLocation;
}
{% endhighlight %}

So, how does this effect us in use? There are two conflicting issues this causes:

* It is (slightly) slower to access memory than with a simple C pointer, as we have to keep derefencing pointers twice. Therefore it is tempting to calculate `*bag`, and then cache it's value.
* We must NEVER remember `*bag`, or any explicit C pointer inside a bag over a call to `NewBag`, as a garbage collection can occur, and the pointer be moved!

The second point is the most important. The bugs this creates are *very* hard to find. They only occur very occasionally, because most allocations don't cause a garbage collection, and so don't cause an issue. Also, if you write through a stale pointer, you corrupt a random other object which has moved into the memory your `Bag` used to use!

Examples
========

These are all genuine examples of this kind of bug, from the GAP 4.8 beta release. Many of them had been around for years, but I made a deep effort to dig them out (how? That's for a later post!). I will group them into categories.



Bad Strings
-----------

It is often tempting to take a raw C pointer to a string in GAP -- these will often interact better with the C standard library, and are generally easier to work with. However, one cannot hold these raw C pointers over a call to `NewBag`!

The standard function to get a raw C pointer from a GAP string `CSTR_STRING` (this actually only works for certain GAP strings, but we won't go into that here).

These first three set off immediate alarm bells. We are passing a C string (from `CSTR_STRING`) into functions which sound like they might allocate a new bag at some point (and they all do). Therefore we have to rewrite them to avoid that.

Note there is nothing wrong with passing the C string `"object, value"` into a function -- it is just C strings which we stored inside GAP `Bag`s we have to worry about.

{% highlight C %}
// src/opers.c : FuncSETTER_FUNCTION
func = NewFunctionCT( T_FUNCTION, SIZE_FUNC, CSTR_STRING(fname), 2,
                      "object, value", DoSetterFunction );
{% endhighlight %}

{% highlight C %}
// src/opers.c : FuncGETTER_FUNCTION
func = NewFunctionCT( T_FUNCTION, SIZE_FUNC, CSTR_STRING(fname), 1,
                      "object, value", DoGetterFunction );
{% endhighlight %}

{% highlight C %}
// src/streams.c : FuncREAD_GAP_ROOT
return READ_GAP_ROOT(CSTR_STRING(filename)) ? True : False;
{% endhighlight %}

Sometimes, we just call `CSTR_STRING` too early. In this function we just calculated `init_key` too early, and moved it's construction later in the function.

This one took too early
{% highlight C %}
// src/intfuncs.c : FuncInitRandomMT
init_key = CHARS_STRING(initstr);
{% endhighlight %} 

We need to explain some functions here. `NameGVar` gives us a raw `char*` to a string, and `C_NEW_STRING_DYN` makes a new GAP string by copying a C string. Therefore we are, in a round-about way, copying a GAP string. However, this copy must make a new GAP bag, which will invalidate `name`! The answer is to use a string copy function which directly copies a bag.

{% highlight C %}
// src/gvars.c : AssGVar
Char* name;
name = NameGVar(gvar);
C_NEW_STRING_DYN(onam, name);
{% endhighlight %}


Holding pointers
----------------

This class  of bugs is just holding a generic C pointer too long. In this code snippet (repeated similarly in many functions in the same file), we calculate `cache` before we start looping, then use it each time around the loop. The loop makes new bags, so we must recalculate `cache` before each use.


{% highlight C %}
// src/opers.c : DoOperation0Args (and many others)
     /* try to find an applicable method in the cache                       */
    cache = 1+ADDR_OBJ( CacheOper( oper, 2 ) );
...
    do {
...
            if (  cache[i] != 0  && cache[i+1] == prec) {
              method = cache[i];
...
		} while (res == TRY_NEXT_METHOD );
{% endhighlight %}



Bad Assignments
---------------

This is the most complicated type of error, and most common. It is caused partly by the strangeness of the C programming language.

Let's pick one, and pull it apart (I've unfolded some macros for you).

{% highlight C %}
// src/opers.c : NewOperationArgs
#define NAME_FUNC(func) (*( *(func) + 8))
NAME_FUNC(func) = CopyObj( name, 0 );
{% endhighlight %}

At first this seems fine. We calculate `CopyObj` (which might do a garbage collection), then we do the derefencing within `NAME_FUNC` to find where we are assigning to, then do the assignment. Except, *that's not how C works!*.

The compiler is allows (and does) mix up the left and right hand sides of an `=`, and if it calculates the left first and gets the memory location we are writing to, then calculates the right (causing a garbage collection), then assigning, bad things happen! Fixing this is easy (if boring), just put an explicit extra assignment in.

{% highlight C %}
// src/opers.c : NewOperationArgs
#define NAME_FUNC(func) (*( *(func) + 8))
Bag temp = CopyObj( name, 0 );
NAME_FUNC(func) = temp;
{% endhighlight %}

The same problem occurs in these other examples.

{% highlight C %}
// src/opers.c : SetterAndFilter
FLAG1_FILT(setter)  = SetterFilter( FLAG1_FILT(getter) );
FLAG2_FILT(setter)  = SetterFilter( FLAG2_FILT(getter) );
{% endhighlight %}

{% highlight C %}
// src/opers.c : FuncGETTER_FUNCTION
ENVI_FUNC(func) = INTOBJ_INT( RNamObj(name) );
{% endhighlight %}
