class ListenList extends CPage
	config(SephirothUI);

const Listen_All = 1;
const Listen_Clan = 2;
const Listen_Whisper = 3;
const Listen_Party = 4;
const Listen_Channel1 = 5;
const Listen_Channel2 = 6;
const Listen_Team = 7;
const Listen_System = 8;
const Listen_Booth = 9;
const BN_EXIT = 10;

var bool bListen_All;
var bool bListen_Clan;
var bool bListen_Whisper;
var bool bListen_Party ;
var bool bListen_Channel1;
var bool bListen_Channel2;
var bool bListen_Team;
var	bool bListen_System;
var bool bListen_Booth;

function OnInit()
{
	SetComponentNotify(Components[1],Listen_All,Self);
	SetComponentNotify(Components[2],Listen_Clan,Self);
	SetComponentNotify(Components[3],Listen_Whisper,Self);
	SetComponentNotify(Components[4],Listen_Party,Self);
	SetComponentNotify(Components[5],Listen_Channel1,Self);
	SetComponentNotify(Components[6],Listen_Channel2,Self);
	SetComponentNotify(Components[7],Listen_Team,Self);
	SetComponentNotify(Components[8],Listen_System,Self);
	SetComponentNotify(Components[9],Listen_Booth,Self);
	SetComponentNotify(Components[10],BN_EXIT,Self);

}

function OnFlush()
{
	SaveConfig();
}
function SetShellChannelDisabled(bool bRight, bool bLeft)
{
	Components[Listen_Channel1].bDisabled = bRight;
	Components[Listen_Channel2].bDisabled = bLeft;
}

function SetBools_ShellChannel(bool b1, bool b2)
{
	bListen_Channel1 = b1;
	bListen_Channel2 = b2;
}

function SetBools(bool b1, bool b2, bool b3, bool b4, bool b5, bool b6, bool b7, bool b8, bool b9)
{
	bListen_All = b1;
	bListen_Clan = b2;
	bListen_Whisper = b3;
	bListen_Party = b4;
	bListen_Channel1 = b5;
	bListen_Channel2 = b6;
	bListen_Team = b7;
	bListen_System = b8;
	bListen_Booth = b9;
}


function SetShellChannelName()
{
	if(SephirothPlayer(PlayerOwner).PSI.GetRightChannel() != "")
		Components[Listen_Channel1].Caption=SephirothPlayer(PlayerOwner).PSI.GetRightChannel();
	else
		Components[Listen_Channel1].Caption=Localize("Terms","ListenChannel1","Sephiroth");


	if(SephirothPlayer(PlayerOwner).PSI.GetLeftChannel() != "")
		Components[Listen_Channel2].Caption=SephirothPlayer(PlayerOwner).PSI.GetLeftChannel();
	else
		Components[Listen_Channel2].Caption = Localize("Terms","ListenChannel2","Sephiroth");

}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch(NotifyId) {
		case Listen_All:		
			if (Command == "Checked")
				bListen_All = true;
			else if (Command == "UnChecked")
				bListen_All = false;
			Parent.NotifyInterface(Self,INT_Command,Listen_All);
			break;
		case Listen_Clan:		
			if (Command == "Checked")
				bListen_Clan = true;
			else if (Command == "UnChecked")
				bListen_Clan = false;
			Parent.NotifyInterface(Self,INT_Command,Listen_Clan);
			break;

		case Listen_Whisper:		
			if (Command == "Checked")
				bListen_Whisper = true;
			else if (Command == "UnChecked")
				bListen_Whisper = false;
			Parent.NotifyInterface(Self,INT_Command,Listen_Whisper);
			break;

		case Listen_Party:		
			if (Command == "Checked")
				bListen_Party = true;
			else if (Command == "UnChecked")
				bListen_Party = false;
			Parent.NotifyInterface(Self,INT_Command,Listen_Party);
			break;

		case Listen_Channel1:		
			if (Command == "Checked")
				bListen_Channel1 = true;
			else if (Command == "UnChecked")
				bListen_Channel1 = false;
			Parent.NotifyInterface(Self,INT_Command,Listen_Channel1);
			break;
		case Listen_Channel2:		
			if (Command == "Checked")
				bListen_Channel2 = true;
			else if (Command == "UnChecked")
				bListen_Channel2 = false;
			Parent.NotifyInterface(Self,INT_Command,Listen_Channel2);
			break;

		case Listen_Team:		
			if (Command == "Checked")
				bListen_Team = true;
			else if (Command == "UnChecked")
				bListen_Team = false;
			Parent.NotifyInterface(Self,INT_Command,Listen_Team);
			break;

		case Listen_System:		
			if (Command == "Checked")
				bListen_System = true;
			else if (Command == "UnChecked")
				bListen_System = false;
			Parent.NotifyInterface(Self,INT_Command,Listen_System);
			break;

		case Listen_Booth:		
			if (Command == "Checked")
				bListen_Booth = true;
			else if (Command == "UnChecked")
				bListen_Booth = false;
			Parent.NotifyInterface(Self,INT_Command,Listen_Booth);
			break;
		case BN_EXIT:
			Parent.NotifyInterface(Self,INT_Close);
			break;
	}
}

function bool PushComponentBool(int CmpId)
{
	if (CmpId == 1)
		return bListen_All;
	if (CmpId == 2)
		return bListen_Clan;
	if (CmpId == 3)
		return bListen_Whisper;
	if (CmpId == 4)
		return bListen_Party;	
	if (CmpId == 5)
		return bListen_Channel1;
	if (CmpId == 6)
		return bListen_Channel2;
	if (CmpId == 7)
		return bListen_Team;
	if (CmpId == 8)
		return bListen_System;	
	if (CmpId == 9)
		return bListen_Booth;	
}


function bool PointCheck()
{
	local int i;
	for (i=0;i<Components.Length;i++) {
		if (Components[i].bVisible && IsCursorInsideComponent(Components[i]))
			return true;
	}
}

defaultproperties
{
     Components(0)=(Type=RES_Image,XL=100.000000,YL=150.000000)
     Components(1)=(Id=1,Caption="ListenAll",Type=RES_CheckButton,XL=50.000000,YL=18.000000,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(2)=(Id=2,Caption="ListenClan",Type=RES_CheckButton,XL=50.000000,YL=18.000000,PivotId=1,PivotDir=PVT_Down,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(3)=(Id=3,Caption="ListenWhisper",Type=RES_CheckButton,XL=50.000000,YL=18.000000,PivotId=2,PivotDir=PVT_Down,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(4)=(Id=4,Caption="ListenParty",Type=RES_CheckButton,XL=50.000000,YL=18.000000,PivotId=3,PivotDir=PVT_Down,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(5)=(Id=5,Caption="ListenChannel1",Type=RES_CheckButton,XL=50.000000,YL=18.000000,PivotId=4,PivotDir=PVT_Down,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(6)=(Id=6,Caption="ListenChannel2",Type=RES_CheckButton,XL=50.000000,YL=18.000000,PivotId=5,PivotDir=PVT_Down,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(7)=(Id=7,Caption="ListenTeam",Type=RES_CheckButton,XL=50.000000,YL=18.000000,PivotId=6,PivotDir=PVT_Down,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(8)=(Id=8,Caption="ListenSystem",Type=RES_CheckButton,XL=50.000000,YL=18.000000,PivotId=7,PivotDir=PVT_Down,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(9)=(Id=9,Caption="ListenBooth",Type=RES_CheckButton,XL=50.000000,YL=18.000000,PivotId=8,PivotDir=PVT_Down,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(10)=(Id=18,Type=RES_PushButton,PivotDir=PVT_Copy,HotKey=IK_Escape)
}
