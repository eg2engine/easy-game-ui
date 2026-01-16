class ChatMode extends CPage;

const BN_Tell = 1;
const BN_Shout = 2;
const BN_Whisper = 3;
const BN_Party = 4;
const BN_Shell1 = 5;
const BN_Shell2 = 6;
const BN_Team = 7;
const BN_Clan = 8;

var WornItems WornItems;

function OnInit()
{
	WornItems = SephirothPlayer(PlayerOwner).PSI.WornItems;
	SetComponentNotify(Components[1],BN_Tell,Self);
	SetComponentNotify(Components[2],BN_Shout,Self);
	SetComponentNotify(Components[3],BN_Whisper,Self);
	SetComponentNotify(Components[4],BN_Party,Self);
	SetComponentNotify(Components[5],BN_Shell1,Self);
	SetComponentNotify(Components[6],BN_Shell2,Self);
	SetComponentNotify(components[7],BN_Team,Self);
	SetComponentNotify(Components[8],BN_Clan,Self);
}

function Layout(Canvas C)
{
	local SephirothItem Shell1,Shell2;
	local bool left, right, match;
	local int i;

	Components[1].bDisabled = (SephirothPlayer(PlayerOwner).PSI.TeamName != "")&&(SephirothPlayer(PlayerOwner).PSI.TeamName != "NONE"); //팀배틀에서는 NONE을 사용
	Components[2].bDisabled = (SephirothPlayer(PlayerOwner).PSI.TeamName != "")&&(SephirothPlayer(PlayerOwner).PSI.TeamName != "NONE"); //팀배틀에서는 NONE을 사용
	Shell1 = WornItems.FindItem(WornItems.IP_REar);
	Shell2 = WornItems.FindItem(WornItems.IP_LEar);
	Components[5].bVisible = Shell1 != None && Shell1.IsShell() && Shell1.Channel != "";
	Components[6].bVisible = Shell2 != None && Shell2.IsShell() && Shell2.Channel != "";
	Components[7].bVisible = (SephirothPlayer(PlayerOwner).PSI.TeamName != "")&&(SephirothPlayer(PlayerOwner).PSI.TeamName != "NONE");	//팀배틀에서는 NONE을 사용한다.
	Components[8].bVisible = SephirothPlayer(PlayerOwner).PSI.ClanName != "";

	left = Components[5].bVisible;
	right = Components[6].bVisible;
	match = Components[7].bVisible;

	if (left && right && match) {
		Components[5].PivotId = 4;
		Components[6].PivotId = 5;
		Components[7].PivotId = 6;
		Components[8].PivotId = 7;
	}
	else if (left && right && !match) {
		Components[5].PivotId = 4;
		Components[6].PivotId = 5;
		Components[8].PivotId = 6;
	}
	else if (left && !right && match) {
		Components[5].PivotId = 4;
		Components[7].PivotId = 5;
		Components[8].PivotId = 7;
	}
	else if (left && !right && !match) {
		Components[5].PivotId = 4;
		Components[8].PivotId = 5;
	}
	else if (!left && right && match) {
		Components[6].PivotId = 4;
		Components[7].PivotId = 6;
		Components[8].PivotId = 7;
	}
	else if (!left && right && !match) {
		Components[6].PivotId = 4;
		Components[8].PivotId = 6;
	}
	else if (!left && !right && match) {
		Components[7].PivotId = 4;
		Components[8].PivotId = 7;
	}
	else if (!left && !right && !match) {
		Components[8].PivotId = 4;
	}

	if (Components.Length < 1)
		return;

	MoveComponent(Components[0],true,PageX,PageY,PageWidth,PageHeight);		//좀 더 수정하고 싶은데....
	for (i=0;i<Components.Length;i++)
		MoveComponent(Components[i]);
	
//	Super.Layout(C);
}

function OnPreRender(Canvas C)
{
	local SephirothItem Shell1,Shell2;

	Shell1 = WornItems.FindItem(WornItems.IP_REar);
	if (Shell1 != None && Shell1.IsShell() && Shell1.Channel != "")
		Components[5].Caption = Shell1.Channel;
	Shell2 = WornItems.FindItem(WornItems.IP_LEar);
	if (Shell2 != None && Shell2.IsShell() && Shell2.Channel != "")
		Components[6].Caption = Shell2.Channel;
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	Parent.NotifyInterface(Self,INT_Command,NotifyId-BN_Tell);
	Parent.NotifyInterface(Self,INT_Close);
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
     Components(1)=(Id=1,Caption="Tell",Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(2)=(Id=2,Caption="Shout",Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=16.000000,PivotId=1,PivotDir=PVT_Right,OffsetXL=4.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(3)=(Id=3,Caption="Whisper",Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=16.000000,PivotId=2,PivotDir=PVT_Right,OffsetXL=4.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(4)=(Id=4,Caption="Party",Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=16.000000,PivotId=3,PivotDir=PVT_Right,OffsetXL=4.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(5)=(Id=5,Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=16.000000,PivotId=4,PivotDir=PVT_Right,OffsetXL=4.000000,TextAlign=TA_MiddleCenter)
     Components(6)=(Id=6,Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=16.000000,PivotId=5,PivotDir=PVT_Right,OffsetXL=4.000000,TextAlign=TA_MiddleCenter)
     Components(7)=(Id=7,Caption="Team",Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=16.000000,PivotId=6,PivotDir=PVT_Right,OffsetXL=4.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(8)=(Id=8,Caption="Clan",Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=16.000000,PivotId=7,PivotDir=PVT_Right,OffsetXL=4.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
}
