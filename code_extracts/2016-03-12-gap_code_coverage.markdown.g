# Code from blog post at azumanga.org
#
LoadPackage("atlas");
a := AtlasGroup("U6(2)", NrMovedPoints, 12474);
b := a^(1,2,3);
f := function() Intersection(a,b); end;
#### --
#### proffunction.g
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
#### --
# Code between ProfileLineByLine and UnprofileLineByLine is recorded
# to a file output.gz
CoverageLineByLine("output.gz");
Read("proffunction.g");
myfunc(1,1);
myfunc(1,2);
UncoverageLineByLine();
#### --
LoadPackage("profiling");
OutputAnnotatedCodeCoverageFiles("output.gz", "outdir");
# Warning: Some lines marked executed but not read. If you
# want to see which lines are NOT executed,
# use the --prof/--cover command line options
#### --
