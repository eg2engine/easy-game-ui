class ClanManager	extends Object
	native;

var string ClanName;
var string MasterName;
// tf clan
var array<string> SubMasterNames;

//ClanMemberInfo
struct ClanMembers{
	var string	Title;	// ȣĪ
	var string	Name;
	var bool	bConnected;
	var bool	bRing;
	var int		BackNumber;
};

var array<ClanMembers> Members;

//ClanApplicantInfo
var array<string>	Applicants;
var array<string>	Blocks;

// tf clan
struct ClanBattleInfo{
	var string	ClanName;
	var string	UntilTime;
	var int     BattlePoint;
};
var array<ClanBattleInfo> ClanBattleInfos;


//@by wj(040401)------
var int	MaxMemberNums;
var int OnlineMemberNums;
var int RestRingNums;
var bool bLordClan;
//--------------------

defaultproperties
{
}
