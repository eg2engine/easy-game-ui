class CDeadMenu extends CInterface;

const BN_Resurrect = 1;
const BN_Lobby = 2;
const BN_Quit = 3;

var bool bVanished;

function OnInit()
{
	SetComponentTextureId(Components[1],0,-1,2,1);
	SetComponentTextureId(Components[2],0,-1,2,1);
	SetComponentTextureId(Components[3],0,-1,2,1);
	SetComponentNotify(Components[1],BN_Resurrect,Self);
	SetComponentNotify(Components[2],BN_Lobby,Self);
	SetComponentNotify(Components[3],BN_Quit,Self);

	if (bVanished) {
		Components[1].bVisible = false;
		Components[2].bVisible = true;
		Components[3].PivotId = 2;
	}
	else {
		Components[1].bVisible = true;
		Components[2].bVisible = false;
		Components[3].PivotId = 1;
	}
}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0,true,(C.ClipX-Components[0].XL)/2,C.ClipY-235);
	for(i=1;i<Components.Length;i++)
		MoveComponentId(i);
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	Parent.NotifyInterface(Self, INT_Close);
	switch (NotifyId) {
	case BN_Resurrect:
	case -1*BN_Resurrect:
		SephirothPlayer(PlayerOwner).Net.NotiResurrectAt(1, 1);
		break;
	case BN_Lobby:
	case -1*BN_Lobby:
		Parent.NotifyInterface(Self, INT_Close);
		Parent.NotifyInterface(Self, INT_Command, "GotoLobbyForce");
		break;
	case BN_Quit:
	case -1*BN_Quit:
		PlayerOwner.ConsoleCommand("Quit");
		break;
	}
}

defaultproperties
{
     Components(0)=(XL=314.000000,YL=44.000000)
     Components(1)=(Id=1,Caption="Resurrect",Type=RES_PushButton,XL=157.000000,YL=44.000000,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="GameMenu")
     Components(2)=(Id=2,Caption="GotoLobby",Type=RES_PushButton,XL=157.000000,YL=44.000000,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="GameMenu")
     Components(3)=(Id=2,Caption="QuitGame",Type=RES_PushButton,XL=157.000000,YL=44.000000,PivotId=1,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="GameMenu")
     TextureResources(0)=(Package="UI_2011_btn",Path="btn_blue_n",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_blue_o",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_blue_c",Style=STY_Alpha)
}
