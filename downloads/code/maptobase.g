MapToBase := function(schvec, perm)
    local map;
    map := RepresentativePerm(schvec, schvec.orbit[1]^perm);
    if map = fail then return fail; fi;
    return perm * map;
end;
