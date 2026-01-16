class Bank extends Object
	native;

struct Deposit
{
	var int Id;
	var string Name;
	var string Owner;
	var string Friends;
	var int Debt;
	var byte Shared;
};

var string NpcName;
var string BankName;
var int InstallFee;
var int RentFee;
var int UseFee;
var array<Deposit> Stashes;
var bool bClanBank;
var bool bClanOwner;

var StashItems StashItems;

native final function CloseStash();

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
}
