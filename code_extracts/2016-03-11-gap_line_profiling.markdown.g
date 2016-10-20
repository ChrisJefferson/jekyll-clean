# Code from blog post at azumanga.org
#
LoadPackage("atlas");
a := AtlasGroup("U6(2)", NrMovedPoints, 12474);
b := a^(1,2,3);
f := function() Intersection(a,b); end;
#### --
# Code between ProfileLineByLine and UnprofileLineByLine is recorded
# to a file output.gz
ProfileLineByLine("output.gz"); f(); UnprofileLineByLine();
#### --
LoadPackage("profiling");
OutputAnnotatedCodeCoverageFiles("output.gz", "outdir");
#### --
ProfileGlobalFunctions(true);
ProfileOperationsAndMethods(true);
f();
ProfileGlobalFunctions(false);
ProfileOperationsAndMethods(false);
DisplayProfile();
#### --
