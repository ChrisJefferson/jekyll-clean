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
