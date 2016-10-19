CalculateSchreier := function(G, point)
    local knownOrbit, vector, img, p, g, gens;
    gens := GeneratorsOfGroup(G);
    
    vec := [];
    knownOrbit := [point];
    vec[point] := ();

    for p in knownOrbit do
        for g in [1..Length(gens)] do
            img := p^gens[g];
            if not(Bound(vec[img])) then
                vec[img] = g;
                Add(knownOrbit, img);
            fi;
        od;
    od;
    return rec(gens := gens, 
               orbit := knownOrbit,
               schreier := vector);
end;
