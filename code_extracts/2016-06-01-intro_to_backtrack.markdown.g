# Code from blog post at azumanga.org
#
G := Group((1,2,3), (1,2), (1,4)(2,5)(3,6));
H := Group((1,3,6), (3,6), (1,2)(3,4)(5,6));
R := Intersection(G,H);
# Group([ (4,5), (1,3)(4,5), (1,4,3,5)(2,6) ])
#### --
IntersectionEnumerate := function(G1,G2)
  local result, g;
  result := [];
  for g in G1 do
    if g in G2 then
      Add(result, g);
    fi;
  od;
  return Group(result);
end;

IntersectionEnumerate(G, H);
# Group([ (), (4,5), (1,3), (1,3)(4,5), (1,4)(2,6)(3,5),
#          (1,4,3,5)(2,6), (1,5,3,4)(2,6), (1,5)(2,6)(3,4) ])
#### --
StabPointEnumerate := function(G,x)
  local result, g;
  result := [];
  for g in G do
    if x^g = x then
      Add(result, g);
    fi;
  od;
  return Group(result);
end;

StabPointEnumerate(G, 1);
# Group([ (), (5,6), (4,5,6), (4,5), (4,6,5), (4,6),
#          (2,3), (2,3)(5,6), (2,3)(4,5,6), (2,3)(4,5),
#          (2,3)(4,6,5), (2,3)(4,6) ])
#### --
Stabilizer(G, 1);
# Group([ (4,6,5), (5,6), (2,3) ])
#### --
