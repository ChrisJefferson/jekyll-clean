# Code from blog post at azumanga.org
#
#### gapsimpletest.tst
gap> 1 + 2;
3
gap> 1 + (-1);
0
gap> 1 + 0;
6
gap> [1,2] + 10;
[ 11, 12 ]
gap> [1,2] + [20,30];
[ 21, 32 ]
gap> [] + [];
[  ]
gap> [1] + [2];
[3]
#### --
gap> Test("gapsimpletest.tst");
########> Diff in gap.tst:5
# Input is:
1 + 0;
# Expected output:
6
# But found:
1
########
########> Diff in gap.tst:13
# Input is:
[1] + [2];
# Expected output:
[3]
# But found:
[ 3 ]
########
false
#### --
# Checking +
gap> 1 + 1 +
> 1;
2

# Checking -
# This first line produces no output
# The second prints out 'x'
gap> x := 1 - 1;;
gap> x;
0
#### --
gap> g := SymmetricGroup(50);
Sym( [ 1 .. 50 ] )
gap> h := Group([ (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
> 21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,
> 41,42,43,44,45,46,47,48,49,50), (1,2) ]);
<permutation group with 2 generators>
gap> g = h;
true
gap> Size(h);
30414093201713378043612608166064768844377641568960512000000000000
gap> h;
<permutation group of size 30414093201713378043612608166064768844377641568960512000000000000 with 2 generators>
#### --
gap> Intersection(SymmetricGroup(40), AlternatingGroup(20)) = AlternatingGroup(20);
true
#### --
#### testintersect.g
slowInt := function(g1,g2)
    local perms;
    perms := Filtered(g1, p -> p in g2);
    return Group(perms);
end;;


testIntersect := function()
    local g1, g2, slowint;
    for g1 in AllPrimitiveGroups(NrMovedPoints, [1..8]) do
        for g2 in AllPrimitiveGroups(NrMovedPoints, [1..8]) do
            if Intersection(g1,g2) <> slowInt(g1,g2) then
                Print(g1, " and ", g2, "\n");
            fi;
        od;
    od;
end;
#### --
gap> Read("testintersect.g");;
gap> testIntersect();
#### --
Stabilizer(SymmetricGroup(5), [1,2,1,2], OnTuples);
# Should be:  Group([(3,5),(4,5)])
# Used to be: Group(())
#### --
