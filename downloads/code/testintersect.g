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
