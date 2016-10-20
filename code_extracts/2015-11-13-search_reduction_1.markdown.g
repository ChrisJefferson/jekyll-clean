# Code from blog post at azumanga.org
#
# Define two permutation groups
G := Group((1,2,3), (1,2), (1,4)(2,5)(3,6));
H := Group((1,3,6), (3,6), (1,2)(3,4)(5,6));
R := Intersection(G,H);
# Group([ (4,5), (1,3)(4,5), (1,4,3,5)(2,6) ])
#### --
RepresentativeAction(G, [1], [3], OnTuples);
# (1,3,2)
RepresentativeAction(G, [1,2], [2,3], OnTuples);
# (1,2,3)
RepresentativeAction(H, [1,2], [2,3], OnTuples);
# (1,2,3,4,6,5)
RepresentativeAction(G, [1,2], [2,5], OnTuples);
# fail
#### --
RepresentativeAction(Group((1,2),(3,4)), [1], [2], OnTuples);
# (1,2)
RepresentativeAction(Group((1,3),(2,4)), [1], [2], OnTuples);
# fail
#### --
RepresentativeAction(G, [1], [2], OnTuples);
# (1,2)
RepresentativeAction(H, [1], [2], OnTuples);
# (1,2)(3,4)(5,6)
#### --
CheckInG := function(G, X, Y)
  return RepresentativeAction(G, X, Y, OnTuples);
end;
CheckInG(Group((1,2),(3,4)), [1,3], [2,4]);
# (1,2)(3,4)
#### --
CheckInNamedGroup := function(G, X, Y)
  return RepresentativeAction(G, X, Y, OnTuples);
end;
CheckInNamedGroup(Group((1,2),(3,4)), [1,3], [2,4]);
# (1,2)(3,4)
#### --
GroupChecker := function(G)
  return function(X,Y)
    return RepresentativeAction(G, X, Y, OnTuples);
  end;
end;
#### --
check := GroupChecker(Group((1,2),(3,4)));
# function( X, Y ) ... end
check([1,3], [2,4]);
# (1,2)(3,4)
#### --
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
#### --
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
#### --
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
#### --
