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

