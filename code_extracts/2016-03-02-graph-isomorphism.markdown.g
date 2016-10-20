# Code from blog post at azumanga.org
#
LoadPackage("digraphs");
#### --
d1 := Digraph([ [2], [3], [4], [1], [1,2,3,4] ]);
# <digraph with 5 vertices, 8 edges>
Print(d1);
# Digraph( [ [ 2 ], [ 3 ], [ 4 ], [ 1 ], [ 1, 2, 3, 4 ] ] )
d2 := Digraph([ [2], [3], [4,5], [1,5], [] ]);
# <digraph with 5 vertices, 6 edges>
Print(d2);
# Digraph( [ [ 2 ], [ 3 ], [ 4, 5 ], [ 1, 5 ], [ ] ] )
#### --
Filtered(SymmetricGroup(5), g -> (OnDigraphs(d1, g) = d1));
# [ (), (1,2,3,4), (1,3)(2,4), (1,4,3,2) ]
Filtered(SymmetricGroup(5), g -> (OnDigraphs(d2, g) = d2));
# [ () ]
#### --
filterGraph := function(cells, digraph)
    local celllist, filter, f, edge;
    celllist := CellsToList(cells);
    # Start making a lists of lists, whose
    # first member is the original cell number
    filter := List(celllist, x -> [x]);
    # Add each edge
    for edge in DigraphEdges(digraph) do
        Add(filter[edge[1]], [ 1, celllist[edge[2]] ]);
        Add(filter[edge[2]], [-1, celllist[edge[1]] ]);
    od;
    for f in filter do
        Sort(f);
    od;
    return ListToCells(filter);
end;
#### --
fullyPropagateConstraints := function(cells, conlist)
    local cellcount, con;

    # Make -1 to force at least one loop to occur
    cellcount := -1;
    while cellcount <> Length(cells) do
        cellcount := Length(cells);
        for con in conlist do
            cells := con(cells);
        od;
    od;
    return cells;
end;
#### --
conList := [ x -> filterGraph(x, d1), x -> filterGraph(x, d2) ];;
fullyPropagateConstraints([[1..5]], conList);
#### --
branchFirstCell := cells -> First([1..Length(cells)], x -> Size(cells[x]) > 1);
branchSmallCell := function(cells)
    local bestindex, bestsize, i;
    bestindex := fail;
    bestsize := infinity;
    for i in [1..Length(cells)] do
        if Size(cells[i]) > 1 and Size(cells[i]) < bestsize then
            bestindex := i;
            bestsize := Size(cells[i]);
        fi;
    od;
    return bestindex;
end;
#### --
# rBase := rec( refinedCells := , branchCell := , branchValue := , nextLevel := )

buildrBase := function(cells, constraintList, branchOrder)
    local rBaseRoot, rBase, branchCell;
    rBaseRoot := rec();
    rBase := rBaseRoot;
    while true do
        cells := fullyPropagateConstraints(cells, constraintList);
        branchCell := branchOrder(cells);
        rBase.cells := StructuralCopy(cells);
        if branchCell = fail then
            return rBaseRoot;
        fi;
        rBase.branchCell := branchCell;
        rBase.branchValue := Minimum(cells[branchCell]);
        cells := FixPoint(cells, rBase.branchValue);
        rBase.nextLevel := rec();
        rBase := rBase.nextLevel;
    od;
end;
#### --
