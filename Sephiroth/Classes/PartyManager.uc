class PartyManager extends Object
	native;

struct PartyPlayer {
	var bool bLeader;
	var bool bInside;
	var int PlayLevel;
	var string PlayName;
	var int Health, MaxHealth;
	var int job; //add neive : ��Ƽâ�� Ŭ���� ǥ��
	var vector Location;
};

var ClientController PlayerOwner;
var bool bLeader;
var array<PartyPlayer> Members;

native final function int GetNumberOfPlayers();

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function Init()
{
	if (PlayerOwner!=None && PlayerOwner.PSI!=None) {
		Members[0].bLeader = false;
		Members[0].bInside = true;
		Members[0].PlayLevel = PlayerOwner.PSI.PlayLevel;
		Members[0].PlayName = string(PlayerOwner.PSI.PlayName);
		Members[0].Health = PlayerOwner.PSI.Health;
		Members[0].MaxHealth = PlayerOwner.PSI.MaxHealth;
		Members[0].Location = PlayerOwner.Pawn.Location;
		PlayerOwner.PSI.bParty = false;
//		//Log(Self@Members[0].PlayName);
	}
}

function SortMembers(out array<PartyPlayer> Sorted)
{
	local int i,j;
	for (i=0;i<Members.Length;i++)
		if (Members[i].bLeader) {
			Sorted[j++] = Members[i];
			break;
		}
	for (i=0;i<Members.Length;i++)
		if (!Members[i].bLeader)
			Sorted[j++] = Members[i];
}

function bool IsInParty(string PlayName)
{
	local int i;
	for (i=0;i<Members.Length;i++)
		if (Members[i].PlayName == PlayName)
			return true;
}

defaultproperties
{
}
