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
