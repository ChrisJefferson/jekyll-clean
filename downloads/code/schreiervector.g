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
