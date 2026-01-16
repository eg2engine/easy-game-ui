class ListenMode extends CPage;		//modified by yj

const Listen_All = 1;
const Listen_Clan = 2;
const Listen_Whisper = 3;
const Listen_Party = 4;
const Listen_Channel1 = 5;
const Listen_Channel2 = 6;
const Listen_Team = 7;
const Listen_System = 8;
const Listen_Booth = 9;

//*********예외처리************
//채팅창의 사이즈를 조절할 때, ListenMode의 영역으로 넘어오면 
//CChannelManager에서 OnKeyEvent를 인식하지 못한다. 
//그래서 bIsParentSizing 변수를 두어, 강제로 KeyEvent를 전달한다.
//좋은 방법은 아니라고 생각...

var bool bIsParentSizing;		//modified by yj   

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
}

function SetListenType(int ListenType) {
	
	SetTabTexture(ListenType);
}

function SetVisibleComponents(bool b1, bool b2, bool b3, bool b4, bool b5, bool b6, bool b7, bool b8, bool b9)
{
	Components[Listen_All].bVisible = b1;
	Components[Listen_Clan].bVisible = b2;
	Components[Listen_Whisper].bVisible = b3;
	Components[Listen_Party].bVisible = b4;
	Components[Listen_Channel1].bVisible = b5;
	Components[Listen_Channel2].bVisible = b6;
	Components[Listen_Team].bVisible = b7;
	Components[Listen_System].bVisible = b8;
	Components[Listen_Booth].bVisible = b9;

	SetComponentsPivotId();
}

function SetVisibleComponents_ShellChannel(bool b1, bool b2)
{
	Components[Listen_Channel1].bVisible = b1;
	Components[Listen_Channel2].bVisible = b2;

	SetComponentsPivotId();
}

function SetComponentsPivotId()
{
	local int i,j;
	j=0;
	for(i=Listen_All;i<=Listen_All+8;i++) {		
		if(Components[i].bVisible) {
			Components[i].PivotId=j;
			j=i;
		}
	}
	bNeedLayoutUpdate = true;
}	


function SetShellChannelName()
{
	if(Components[Listen_Channel1].bVisible) {
		if(SephirothPlayer(PlayerOwner).PSI.GetRightChannel() != "")
			Components[Listen_Channel1].Caption=SephirothPlayer(PlayerOwner).PSI.GetRightChannel();
		else
			Components[Listen_Channel1].Caption=Localize("Terms","NotUsing","Sephiroth");
	}
	
	if(Components[Listen_Channel2].bVisible) {
		if(SephirothPlayer(PlayerOwner).PSI.GetLeftChannel() != "")
			Components[Listen_Channel2].Caption=SephirothPlayer(PlayerOwner).PSI.GetLeftChannel();
		else
			Components[Listen_Channel2].Caption=Localize("Terms","NotUsing","Sephiroth");
	}
}

function SetTabTexture(int SelectedComponentId)		//선택된 탭과 그렇지 않은 탭의 텍스쳐를 구분한다.
{
	local int i;
	for(i=1;i<=9;i++) {
		if(i == SelectedComponentId)
			SetComponentTextureId(Components[i],1,-1,3,1);
		else
			SetComponentTextureId(Components[i],0,-1,3,2);	
	}
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	Parent.NotifyInterface(Self,INT_Command,NotifyId);	
	SetTabTexture(NotifyID);

}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if(bIsParentSizing)
		if (Key == IK_LeftMouse && Action == IST_Release) 
			Parent.NotifyInterface(self,INT_Command,"FinishSizing");

	return false;		
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
     Components(1)=(Id=1,Caption="ListenAll",Type=RES_PushButton,bPassKeytoOnKeyEvent=True,XL=71.000000,YL=18.000000,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(2)=(Id=2,Caption="ListenClan",Type=RES_PushButton,bPassKeytoOnKeyEvent=True,XL=71.000000,YL=18.000000,PivotId=1,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(3)=(Id=3,Caption="ListenWhisper",Type=RES_PushButton,bPassKeytoOnKeyEvent=True,XL=71.000000,YL=18.000000,PivotId=2,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(4)=(Id=4,Caption="ListenParty",Type=RES_PushButton,bPassKeytoOnKeyEvent=True,XL=71.000000,YL=18.000000,PivotId=3,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(5)=(Id=5,Caption="ListenChannel1",Type=RES_PushButton,bPassKeytoOnKeyEvent=True,XL=71.000000,YL=18.000000,PivotId=4,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(6)=(Id=6,Caption="ListenChannel2",Type=RES_PushButton,bPassKeytoOnKeyEvent=True,XL=71.000000,YL=18.000000,PivotId=5,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(7)=(Id=7,Caption="ListenTeam",Type=RES_PushButton,bPassKeytoOnKeyEvent=True,XL=71.000000,YL=18.000000,PivotId=6,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(8)=(Id=8,Caption="ListenSystem",Type=RES_PushButton,bPassKeytoOnKeyEvent=True,XL=71.000000,YL=18.000000,PivotId=7,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(9)=(Id=9,Caption="ListenBooth",Type=RES_PushButton,bPassKeytoOnKeyEvent=True,XL=71.000000,YL=18.000000,PivotId=8,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     TextureResources(0)=(Package="UI_2009",Path="BTN05_03_N",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2009",Path="BTN05_03_N1",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2009",Path="BTN05_03_O",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2009",Path="BTN05_03_P",Style=STY_Alpha)
}
