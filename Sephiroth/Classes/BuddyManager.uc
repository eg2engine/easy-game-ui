class BuddyManager extends Object
	native;

struct Buddy{
	var bool bOnline;
	var string BuddyName;	
};


struct BuddyGroup{
	var bool bNoDelete;
	var bool bExpanded;
	var string GroupName;
	var array<Buddy> Buddys;
};

var array<BuddyGroup>	BuddyGroups;
var array<string>		Fanlist;

defaultproperties
{
}
