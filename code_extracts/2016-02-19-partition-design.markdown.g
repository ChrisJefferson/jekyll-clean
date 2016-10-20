# Code from blog post at azumanga.org
#
part := [ Set([2,3,6]), Set([1]), Set([4,5]) ];
#### --
part := [ [2,3,6], [1], [4,5] ];
#### --
Union(part);
# [1 .. 6 ]
#### --
CellsToList := function(cells)
    local cellpos, i, j;
    cellpos := [];
  # Iterate over all the cells
    for i in [1..Length(cells)] do
    # Iterate over the members of each cell
        for j in cells[i] do
            cellpos[j] := i;
        od;
    od;
    return cellpos;
end;

CellsToList([ [2,3,6], [1], [4,5] ]);
# [ 2, 1, 1, 3, 3, 1 ]
#### --
ListToCells := function(cellpos)
    local cells, labels, i;
    # Find all unique cell labels
    labels := Set(cellpos);
    # make an empty list of cells
    cells := List([1..Length(labels)], x -> []);
    # Fill the cells
    for i in [1..Length(cellpos)] do
        AddSet(cells[Position(labels, cellpos[i])], i);
    od;
    return cells;
end;

ListToCells( [ 2, 1, 1, 3, 3, 1 ] );
# [ [ 2, 3, 6 ], [ 1 ], [ 4, 5 ] ]

#### --
FixPoint := function(cells, point)
  local indic;
    indic := CellsToList(cells);
    indic[point] := infinity;
    return ListToCells(indic);
end;

FixPoint( [ [2,3,6], [1], [4,5] ], 3);
# [ [ 3 ], [ 2, 6 ], [ 1 ], [ 4, 5 ] ]
#### --
PartitionsMeet := function(P, Q)
  local indicP, indicQ, indicJoin;
    indicP := CellsToList(P);
    indicQ := CellsToList(Q);
    indicJoin := List([1..Length(indicP)], i -> [indicP[i], indicQ[i]]);
    return ListToCells(indicJoin);
end;

PartitionsMeet([ [1,2,3], [4,5] ], [ [1,2], [3,4,5] ]);
# [ [ 1, 2 ], [ 3 ], [ 4, 5 ] ]
#### --
OnTuplesSets([ [2,3,6], [1], [4,5] ], (1,2,3,4,5,6));
# [ [ 1, 3, 4 ], [ 2 ], [ 5, 6 ] ]
#### --
Stabilizer(SymmetricGroup(5), [ [1,3], [2,4,5] ], OnTuplesSets);
# Group([ (2,4), (2,4,5), (1,3) ])
#### --
Agreeable := function(P,Q)
    if Size(P) <> Size(Q) then
        return false;
    fi;

    return ForAll([1..Size(P)], i -> Size(P[i]) = Size(Q[i]));
end;

Agreeable([ [1,2,3], [4,5] ], [[1,2], [3,4,5] ]);
# false
Agreeable([ [1,2,3], [4,5] ], [[1,2,3], [3,4,5] ]);
# false
Agreeable([ [1,2,3], [4,5],[5] ], [[1,2,3], [4,5] ]);
# false
Agreeable([ [1,2,3], [4,5] ], [[1,2,3], [4,5],[5] ]);
# false
Agreeable([ [1,2,3], [4,5] ], [[1,2,3], [4,5] ]);
# true
#### --
