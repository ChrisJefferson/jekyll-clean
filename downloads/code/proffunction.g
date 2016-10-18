myfunc := function(a,b)
    local order;
    if a < b then
        order := "smaller";
    fi;
    if a > b then
        order := "bigger";
    fi;
    if a = b then
        order := "same";
    fi;
    return order;
end;
