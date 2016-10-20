PermInGroup := function(chain, perm)
    local basemap;
    basemap := MapToBase(chain, perm);
    if basemap = fail then return false; fi;
    if not IsBound(chain.stabilizer) then
        return basemap = ();
    fi;
    return PermInGroup(chain.stabilizer, basemap);
end;
