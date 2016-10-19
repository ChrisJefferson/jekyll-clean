CalculateSchreier := function(G, point)
    local knownOrbit, vector, gens, p, g;
    gens := GeneratorsOfGroup(G);
    invgens := List(gens, x -> x^-1);
    vec := [];

    knownOrbit := [point];
    vec[point] := -1;

    for p in knownOrbit do
        for g in [1..Length(gens)] do
            if not(Bound(vec[p^gens[g]])) then
                vec[p^gens[g]] = invgens[g];
                Add(knownOrbit, p^gens[g]);
            fi;
        od;
    od;
    return rec(orbit := knownOrbit, schreier := vector);
end;
