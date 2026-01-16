class CClanBattleInfo extends CInterface;

const BN_Option = 1;
const BN_Lobby = 2;
const BN_Quit = 3;

//test
var int bt;
var bool r;
var string ClanName;
var string UntilTime;
var int BattlePoint;

function OnInit()
{
}

function Layout(Canvas C)
{
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{

}

function UpdateClanBattleInfo()
{
	local int Index;

	local ClientController CC;
	CC = ClientController(PlayerOwner);

	for(Index = 0; Index < 10; Index++)
	{		
		ClanName = CC.ClanManager.ClanBattleInfos[Index].ClanName;
 		UntilTime = CC.ClanManager.ClanBattleInfos[Index].UntilTime;
 		BattlePoint = CC.ClanManager.ClanBattleInfos[Index].BattlePoint;
	}
}


function OnPreRender(Canvas C)
{

    local string Str;
	local int x;
	local int y;
	local int i;
	local ClientController CC;

	x = 5;
	y = 150;

	//Log("CClanBattleInfo.uc OnPreRender 1--->");

	CC = ClientController(PlayerOwner);

	// Ŭ���� �������� ǥ�� ---------------------------------------------------
	for(i = 0; i < 10; i++)
	{
		Str = "";

		ClanName = ClientController(PlayerOwner).ClanManager.ClanBattleInfos[i].ClanName;
 		UntilTime = ClientController(PlayerOwner).ClanManager.ClanBattleInfos[i].UntilTime;
 		BattlePoint = ClientController(PlayerOwner).ClanManager.ClanBattleInfos[i].BattlePoint;

		y += 12;
		Str = ClanName@UntilTime@BattlePoint;		
		if(ClanName != "")
		{
			C.SetPos(x, y);
			C.SetDrawColor(0, 0, 0, 150);
			C.DrawTextClipped("�ƢƢƢƢƢƢƢƢ�");
			C.SetDrawColor(255, 255, 0, 255);
			C.DrawTextClipped(Str);
		}
	}
	//-------------------------------------------------------------------------
}

defaultproperties
{
}
