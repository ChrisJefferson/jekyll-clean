# Code from blog post at azumanga.org
#
G := Group((1,3,2)(5,11,6,9,7,10)(8,12)(13,15,14),
           (1,9,5)(2,11,6,3,10,7)(4,12,8)(14,15));
#### --
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
#### --
#### calculateorbitslow.g
CalculateOrbitSlow := function(G, point)
    local knownOrbit, p, g, gens;
    gens := GeneratorsOfGroup(G);
    
    knownOrbit := [point];
    for p in knownOrbit do
        for g in gens do
            if not(p^g in knownOrbit) then
                Add(knownOrbit, p^g);
            fi;
        od;
    od;
    return knownOrbit;
end;
#### --
CalculateOrbitSlow(G, 1);
# [ 1, 3, 9, 2, 10, 7, 5, 11, 6 ]
CalculateOrbitSlow(G, 4);
# [ 4, 12, 8 ]
#### --
#### schreiervector.g
CalculateSchreier := function(G, point)
    local knownOrbit, vec, img, p, g, gens;
    gens := GeneratorsOfGroup(G);
    
    vec := [];
    knownOrbit := [point];
    vec[point] := ();

    for p in knownOrbit do
        for g in gens do
            img := p/g; # Note this line!
            if not(IsBound(vec[img])) then
                vec[img] := g;
                Add(knownOrbit, img);
            fi;
        od;
    od;
    
    # Return everything we found
    return rec(generators := gens,
               orbit := knownOrbit,
               transveral := vec);
end;
#### --
#### representativeperm.g
RepresentativePerm := function(schvec, val)
    local ret, gen;
    if not(IsBound(schvec.transveral[val])) then
        return fail;
    fi;

    ret := ();

    while val <> schvec.orbit[1] do
        gen := schvec.transveral[val];
        val := val^gen;
        ret := ret*gen;
    od;

    return ret;
end;

#### --
sch := CalculateSchreier(G, 1);;
RepresentativePerm(sch, 2);
# (1,3,2)(5,11,6,9,7,10)(8,12)(13,15,14)
RepresentativePerm(sch, 6);
# (1,10,5,2,9,6)(3,11,7)(4,12,8)(13,14)
RepresentativePerm(sch, 4);
# fail
#### --
#### maptobase.g
MapToBase := function(schvec, perm)
    local map;
    map := RepresentativePerm(schvec, schvec.orbit[1]^perm);
    if map = fail then return fail; fi;
    return perm * map;
end;
#### --
sch := CalculateSchreier(G, 1);;
MapToBase(sch, (1,2,3,4));
# (3,4)(5,11,6,9,7,10)(8,12)(13,15,14)
MapToBase(sch, (1,4));
# fail
#### --
#### stabilizerchain.g
StabilizerChain := function(G)
    local root, pnt, Gstab;
    pnt := SmallestMovedPoint(G);
    root := CalculateSchreier(G, pnt);
    Gstab := Stabilizer(G, pnt);
    if not IsTrivial(Gstab) then
        root.stabilizer := StabilizerChain(Gstab);
    fi;
    return root;
end;
#### --
#### permingroup.g
PermInGroup := function(chain, perm)
    local basemap;
    basemap := MapToBase(chain, perm);
    if basemap = fail then return false; fi;
    if not IsBound(chain.stabilizer) then
        return basemap = ();
    fi;
    return PermInGroup(chain.stabilizer, basemap);
end;
#### --
chain := StabilizerChain(G);;
PermInGroup(chain, (1,5)(2,6)(3,7)(4,8));
# true
PermInGroup(chain, (1,5)(2,6)(3,7)(4,9));
# false
#### --
GroupSize := function(stabchain)
    if not IsBound(stabchain.stabilizer) then
        return Length(stabchain.orbit);
    fi;
    return Length(stabchain.orbit) *
           GroupSize(stabchain.stabilizer);
end;

GroupSize(chain);
# 36
#### --
