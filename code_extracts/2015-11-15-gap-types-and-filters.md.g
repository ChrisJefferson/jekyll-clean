# Code from blog post at azumanga.org
#
DeclareOperation( "Cheese", [ IsGroup ]);
InstallMethod( Cheese, [ IsGroup ],
	function(x) Print("Group"); end);
InstallMethod( Cheese, [ IsPolycyclicGroup ],
	function(x) Print("Polycyclic"); end);
g := Group((1,2),(3,4));
Cheese(g);
# Group
Size(g);
# 4
Cheese(g);
# Polycyclic
#### --
