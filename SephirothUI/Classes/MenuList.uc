class MenuList extends CSelectable	//modified by yj
	config(SephirothUI);

var config float PageX,PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

var int Icon;

var const int Info;
var const int WorldMap;
var const int PetUI;
var const int InventoryBag;
var const int Party;
var const int PetBag;
var const int Portal;
var const int ClanInterface;
var const int Booth;
var const int SkillTree;
var const int Friend;
var const int Animation;
var const int Quest;
var const int MenuListMessage;
var const int BattleInfo;
var const int Option;
var const int Help;
var const int GM;

const BN_Exit = 1;

function OnInit()
{
	if(PageX==-1)
		ResetDefaultPosition();		//2009.10.27.Sinhyub
	bMovingUI = true;	//Layout()에서 창밖을 벗어난 UI를 체크해줄수있도록합니다. 2009.10.29.Sinhyub
	SetComponentTextureId(Components[2],1,-1,57,2);
	SetComponentNotify(Components[2],BN_Exit,Self);
	GotoState('Nothing');
}

function OnFlush()
{	
	Controller.ResetDragAndDropAll();
	SaveConfig();
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch (NotifyId) {
	case BN_Exit:
		Controller.ResetDragAndDropAll();
		Parent.NotifyInterface(Self,INT_Close);
		break;
	}
}

function bool DoubleClick()
{	

	if (IsCursorInsideComponent(Components[5])) {
		Parent.NotifyInterface(Self,INT_Command,"Info");
		return true;
	}

	else if (IsCursorInsideComponent(Components[6])) {
		if (SephirothInterface(parent).WorldMap != None)
			SephirothInterface(parent).HideWorldMap();
		else
			SephirothInterface(parent).ShowWorldMap();
		return true;
	}

	else if (IsCursorInsideComponent(Components[7])) {
		if (SephirothInterface(parent).m_PetInfo != None)
			SephirothInterface(parent).HidePetInterface();
		else 
			SephirothInterface(parent).ShowPetInterface();		
		return true;
	}

	else if (IsCursorInsideComponent(Components[8])) {			//가방
		Parent.NotifyInterface(Self,INT_Command,"InventoryBag");
		return true;
	}
	else if (IsCursorInsideComponent(Components[9])) {			//파티
		Parent.NotifyInterface(Self,INT_Command,"Party");
		return true;
	}
	else if (IsCursorInsideComponent(Components[10])) {		//펫인벤
		if(SephirothPlayer(PlayerOwner).SPet == None || SephirothPlayer(PlayerOwner).PetSI.PetLevel < 16)
			return true;
		if(SephirothInterface(parent).PetBag != None)
			SephirothInterface(parent).HidePetBag();
		else
			SephirothInterface(parent).ShowPetBag();
		return true;
	}

	else if (IsCursorInsideComponent(Components[11])) {			//위치저장
		Parent.NotifyInterface(Self,INT_Command,"Portal");
		return true;
	}
	else if (IsCursorInsideComponent(Components[12])) {			//클랜
		if(SephirothInterface(parent).ClanInterface == None){				
			if(SephirothPlayer(PlayerOwner).PSI.ClanName != "")
				SephirothPlayer(PlayerOwner).Net.NotiClanMemberInfo();
			else
				SephirothPlayer(PlayerOwner).Net.NotiClanApplying();
		}
		else
			SephirothInterface(parent).HideClanInterface();
		return true;
	}
	else if (IsCursorInsideComponent(Components[13])) {		//노점
		if( SephirothPlayer(PlayerOwner).ZSI.bNoBoothOpen )
			AddMessage(1, Localize("Booth","NoBoothOpenZone","Sephiroth"), class'Canvas'.static.MakeColor(255,255,0));
		else
			SephirothPlayer(PlayerOwner).Net.NotiBoothFee();
		return true;
	}

	else if (IsCursorInsideComponent(Components[14])) {		//스킬
		Parent.NotifyInterface(Self,INT_Command,"SkillTree");
		return true;
	}

	else if (IsCursorInsideComponent(Components[15])) {		//친구
		if (SephirothInterface(parent).Messenger != None)
			SephirothInterface(parent).HideMessenger();
		else
			SephirothInterface(parent).ShowMessenger();
		return true;
	}

	else if (IsCursorInsideComponent(Components[16])) {		//생활동작
		Parent.NotifyInterface(Self,INT_Command,"AnimationMenu");	
	}

	else if (IsCursorInsideComponent(Components[17])) {			//퀘스트
		Parent.NotifyInterface(Self,INT_Command,"Quest");
		return true;
	}
	else if (IsCursorInsideComponent(Components[18])) {			//쪽지
		Parent.NotifyInterface(Self,INT_Command,"Message");
		return true;
	}
	else if (IsCursorInsideComponent(Components[22])) {		//전투정보
		Parent.NotifyInterface(Self,INT_Command,"BattleInfo");
		return true;
		
	}
	else if (IsCursorInsideComponent(Components[19])) {		// GM (신고기능)
		SephirothInterface(parent).ChannelMgr.ProcessSlashCommand("REPORT");
		return true;
	}
	else if (IsCursorInsideComponent(Components[20])) {			//옵션
		if (SephirothInterface(parent).Option != None)
			SephirothInterface(parent).HideOption();
		else
			SephirothInterface(parent).ShowOption();
		return true;
	}
	else if (IsCursorInsideComponent(Components[21])) {			//도움말
		if (SephirothInterface(parent).Help != None)
			SephirothInterface(parent).HideHelp();
		else
			SephirothInterface(parent).ShowHelp();
		return true;		
	}	
	return false;
}

function Layout(Canvas C)
{
	local int DX,DY;
	local int i;

	if (bIsDragging) {
		DX = Controller.MouseX - DragOffsetX;
		DY = Controller.MouseY - DragOffsetY;
		PageX = DX;
		PageY = DY;
	}
	else {
		if (PageX < 0)
			PageX = 0;
		else if (PageX + WinWidth > C.ClipX)
			PageX = C.ClipX - WinWidth;
		if (PageY < 0)
			PageY = 0;
		else if (PageY + WinHeight > C.ClipY)
			PageY = C.ClipY - WinHeight;
	}

	MoveComponent(Components[0],true,PageX,PageY,WinWidth,WinHeight);

	for (i=1;i<Components.Length;i++)
		MoveComponentId(i);
	Super.Layout(C);
}



function DrawObject(Canvas C)
{	
	local float X,Y;

	X = Components[0].X;
	Y = Components[0].Y;

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(Localize("MenuUI","MenuUI","SephirothUI"),X,Y+7,270,20);

	C.DrawKoreanText(Localize("MenuUI","Info","SephirothUI"),Components[5].X,Components[5].Y+32,32,15);	
	C.DrawKoreanText(Localize("MenuUI","WorldMap","SephirothUI"),Components[6].X,Components[6].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","PetUI","SephirothUI"),Components[7].X,Components[7].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","InventoryBag","SephirothUI"),Components[8].X,Components[8].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","Party","SephirothUI"),Components[9].X,Components[9].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","PetBag","SephirothUI"),Components[10].X,Components[10].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","Portal","SephirothUI"),Components[11].X,Components[11].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","ClanInterface","SephirothUI"),Components[12].X,Components[12].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","Booth","SephirothUI"),Components[13].X,Components[13].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","SkillTree","SephirothUI"),Components[14].X,Components[14].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","Friend","SephirothUI"),Components[15].X,Components[15].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","Animation","SephirothUI"),Components[16].X,Components[16].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","Quest","SephirothUI"),Components[17].X,Components[17].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","message","SephirothUI"),Components[18].X,Components[18].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","GM","SephirothUI"),Components[19].X,Components[19].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","Option","SephirothUI"),Components[20].X,Components[20].Y+32,32,15);
	C.DrawKoreanText(Localize("MenuUI","Help","SephirothUI"),Components[21].X,Components[21].Y+32,32,15);
//	C.SetDrawColor(123,123,123);
	C.DrawKoreanText(Localize("MenuUI","BattleInfo","SephirothUI"),Components[22].X,Components[22].Y+32,32,15);
	
}



function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Key == IK_LeftMouse) {
		if ((Action == IST_Press) && IsCursorInsideComponent(Components[0])) 
		{
			bIsDragging = true;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
			return true;
		}
		if ( (Action == IST_Release) && bIsDragging) {
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			return true;
		}
	}
}



function bool ObjectSelecting()
{	

	if (IsCursorInsideComponent(Components[5])) {
		Icon = Info;
		Controller.MergeSelectCandidate(Self);
		return true;			
	}

	else if (IsCursorInsideComponent(Components[6])) {
		Icon = WorldMap;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[7])) {	//펫
		Icon = PetUI;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[8])) {	//인벤
		Icon = InventoryBag;
		Controller.MergeSelectCandidate(Self);
		return true;
	}


	else if (IsCursorInsideComponent(Components[9])) {	//파티
		Icon = Party;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[10])) {	//펫인벤
		Icon = PetBag;
		Controller.MergeSelectCandidate(Self);
		return true;		
	}

	else if (IsCursorInsideComponent(Components[11])) {	//위치저장
		Icon = Portal;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[12])) {	//클랜
		Icon = ClanInterface;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[13])) {	//노점
		Icon = Booth;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[14])) {		//스킬
		Icon = SkillTree;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[15])) {	//친구
		Icon = Friend;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[16])) {	//생활동작
		Icon = Animation;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[17])) {		//퀘스트
		Icon = Quest;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[18])) {	//쪽지
		Icon = MenuListMessage;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[19])) {	//GM
		Icon = GM;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[20])) {		//옵션
		Icon = Option;
		Controller.MergeSelectCandidate(Self);
		return true;
	}

	else if (IsCursorInsideComponent(Components[21])) {	//도움말
		Icon = Help;
		Controller.MergeSelectCandidate(Self);
		return true;
	}
	else if (IsCursorInsideComponent(Components[22])) {		//전투정보
		
		Icon = BattleInfo;
		Controller.MergeSelectCandidate(Self);		
		return true;
	}

	return false;

}


function bool Drop()
{
	if (IsCursorInsideComponent(Components[0]))
		return true;
}

function RenderDragging(Canvas C)
{
	local Texture Sprite;

	if (Controller.DragSource != None &&Controller.DragSource.IsA('MenuList') ) {
	switch(Icon){
		case Info:
			Sprite = TextureResources[39].Resource;
			break;
		case WorldMap:
			Sprite = TextureResources[40].Resource;
			break;
		case PetUI:
			Sprite = TextureResources[41].Resource;
			break;
		case InventoryBag:
			Sprite = TextureResources[42].Resource;
			break;
		case Party:
			Sprite = TextureResources[43].Resource;
			break;
		case PetBag:
			Sprite = TextureResources[44].Resource;
			break;
		case Portal:
			Sprite = TextureResources[45].Resource;
			break;
		case ClanInterface:
			Sprite = TextureResources[46].Resource;
			break;
		case Booth:
			Sprite = TextureResources[47].Resource;
			break;
		case SkillTree:
			Sprite = TextureResources[48].Resource;
			break;
		case Friend:
			Sprite = TextureResources[49].Resource;
			break;
		case Animation:
			Sprite = TextureResources[50].Resource;
			break;
		case Quest:
			Sprite = TextureResources[51].Resource;
			break;
		case MenuListMessage:
			Sprite =TextureResources[52].Resource;
			break;
		case BattleInfo:
			Sprite = TextureResources[53].Resource;
			break;
		case Option:
			Sprite = TextureResources[54].Resource;
			break;
		case Help:
			Sprite = TextureResources[55].Resource;
			break;
		case GM:
			Sprite = TextureResources[56].Resource;
			break;			
	}

	
	if (Sprite != None) {
		C.Style = ERenderStyle.STY_Alpha;
		C.SetPos(Controller.MouseX-16,Controller.MouseY-16);
		C.DrawTile(Sprite,24,24,0,0,24,24);
	}

	}

}

function bool CanDrag()
{
	if(!IsCursorInsideInterface())
		return false;

	return Controller.IsSomethingSelected();
}

function ResetDefaultPosition()		//2009.10.27.Sinhyub
{
	local string Resolution;
	local int pos;
	local int ClipX,ClipY;

	Resolution = PlayerOwner.ConsoleCommand("GETCURRENTRES");
	pos = InStr(Resolution, "x");

	ClipX=int(Left(Resolution, pos));		
	ClipY=int(Mid(Resolution,pos+1));

	PageX = (ClipX-WinWidth)/2+200;
	PageY = (ClipY-WinHeight)/2;

	SaveConfig();
}

defaultproperties
{
     PageX=-1.000000
     PageY=-1.000000
     WorldMap=1
     PetUI=2
     InventoryBag=3
     Party=4
     PetBag=5
     Portal=6
     ClanInterface=7
     Booth=8
     SkillTree=9
     Friend=10
     Animation=11
     Quest=12
     MenuListMessage=13
     BattleInfo=17
     Option=15
     Help=16
     GM=14
     Components(0)=(XL=264.000000,YL=406.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=264.000000,YL=406.000000,PivotDir=PVT_Copy)
     Components(2)=(Id=2,Type=RES_PushButton,XL=23.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=241.000000,OffsetYL=3.000000,HotKey=IK_Escape)
     Components(5)=(Id=5,ResId=4,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=1,PivotDir=PVT_Copy,OffsetXL=40.000000,OffsetYL=60.000000)
     Components(6)=(Id=6,ResId=16,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=5,PivotDir=PVT_Right,OffsetXL=40.000000)
     Components(7)=(Id=7,ResId=28,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=6,PivotDir=PVT_Right,OffsetXL=40.000000)
     Components(8)=(Id=8,ResId=6,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=5,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(9)=(Id=9,ResId=18,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=6,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(10)=(Id=10,ResId=30,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=7,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(11)=(Id=11,ResId=8,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=8,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(12)=(Id=12,ResId=20,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=9,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(13)=(Id=13,ResId=32,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=10,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(14)=(Id=14,ResId=10,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=11,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(15)=(Id=15,ResId=22,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=12,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(16)=(Id=16,ResId=34,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=13,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(17)=(Id=17,ResId=12,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=14,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(18)=(Id=18,ResId=24,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=15,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(19)=(Id=19,ResId=38,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=16,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(20)=(Id=20,ResId=14,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=17,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(21)=(Id=21,ResId=26,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=18,PivotDir=PVT_Down,OffsetYL=25.000000)
     Components(22)=(Id=22,ResId=36,Type=RES_Image,XL=32.000000,YL=32.000000,PivotId=19,PivotDir=PVT_Down,OffsetYL=25.000000)
     TextureResources(0)=(Package="UI_2009",Path="Win01_01",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2009",Path="BTN01_01_N",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2009",Path="BTN01_01_O",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2009",Path="Icon_Win01D",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2009",Path="Icon_Win01L",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2009",Path="Icon_Win02D",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2009",Path="Icon_Win02L",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2009",Path="Icon_Win03D",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2009",Path="Icon_Win03L",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2009",Path="Icon_Win04D",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2009",Path="Icon_Win04L",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2009",Path="Icon_Win05D",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2009",Path="Icon_Win05L",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2009",Path="Icon_Win06D",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2009",Path="Icon_Win06L",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2009",Path="Icon_Win07D",Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2009",Path="Icon_Win07L",Style=STY_Alpha)
     TextureResources(17)=(Package="UI_2009",Path="Icon_Win08D",Style=STY_Alpha)
     TextureResources(18)=(Package="UI_2009",Path="Icon_Win08L",Style=STY_Alpha)
     TextureResources(19)=(Package="UI_2009",Path="Icon_Win09D",Style=STY_Alpha)
     TextureResources(20)=(Package="UI_2009",Path="Icon_Win09L",Style=STY_Alpha)
     TextureResources(21)=(Package="UI_2009",Path="Icon_Win10D",Style=STY_Alpha)
     TextureResources(22)=(Package="UI_2009",Path="Icon_Win10L",Style=STY_Alpha)
     TextureResources(23)=(Package="UI_2009",Path="Icon_Win11D",Style=STY_Alpha)
     TextureResources(24)=(Package="UI_2009",Path="Icon_Win11L",Style=STY_Alpha)
     TextureResources(25)=(Package="UI_2009",Path="Icon_Win12D",Style=STY_Alpha)
     TextureResources(26)=(Package="UI_2009",Path="Icon_Win12L",Style=STY_Alpha)
     TextureResources(27)=(Package="UI_2009",Path="Icon_Win13D",Style=STY_Alpha)
     TextureResources(28)=(Package="UI_2009",Path="Icon_Win13L",Style=STY_Alpha)
     TextureResources(29)=(Package="UI_2009",Path="Icon_Win14D",Style=STY_Alpha)
     TextureResources(30)=(Package="UI_2009",Path="Icon_Win14L",Style=STY_Alpha)
     TextureResources(31)=(Package="UI_2009",Path="Icon_Win15D",Style=STY_Alpha)
     TextureResources(32)=(Package="UI_2009",Path="Icon_Win15L",Style=STY_Alpha)
     TextureResources(33)=(Package="UI_2009",Path="Icon_Win16D",Style=STY_Alpha)
     TextureResources(34)=(Package="UI_2009",Path="Icon_Win16L",Style=STY_Alpha)
     TextureResources(35)=(Package="UI_2009",Path="Icon_Win17D",Style=STY_Alpha)
     TextureResources(36)=(Package="UI_2009",Path="Icon_Win17L",Style=STY_Alpha)
     TextureResources(37)=(Package="UI_2009",Path="Icon_Win18D",Style=STY_Alpha)
     TextureResources(38)=(Package="UI_2009",Path="Icon_Win18L",Style=STY_Alpha)
     TextureResources(39)=(Package="UI_2009",Path="Icon_Win01S",Style=STY_Alpha)
     TextureResources(40)=(Package="UI_2009",Path="Icon_Win07S",Style=STY_Alpha)
     TextureResources(41)=(Package="UI_2009",Path="Icon_Win13S",Style=STY_Alpha)
     TextureResources(42)=(Package="UI_2009",Path="Icon_Win02S",Style=STY_Alpha)
     TextureResources(43)=(Package="UI_2009",Path="Icon_Win08S",Style=STY_Alpha)
     TextureResources(44)=(Package="UI_2009",Path="Icon_Win14S",Style=STY_Alpha)
     TextureResources(45)=(Package="UI_2009",Path="Icon_Win03S",Style=STY_Alpha)
     TextureResources(46)=(Package="UI_2009",Path="Icon_Win09S",Style=STY_Alpha)
     TextureResources(47)=(Package="UI_2009",Path="Icon_Win15S",Style=STY_Alpha)
     TextureResources(48)=(Package="UI_2009",Path="Icon_Win04S",Style=STY_Alpha)
     TextureResources(49)=(Package="UI_2009",Path="Icon_Win10S",Style=STY_Alpha)
     TextureResources(50)=(Package="UI_2009",Path="Icon_Win16S",Style=STY_Alpha)
     TextureResources(51)=(Package="UI_2009",Path="Icon_Win05S",Style=STY_Alpha)
     TextureResources(52)=(Package="UI_2009",Path="Icon_Win11S",Style=STY_Alpha)
     TextureResources(53)=(Package="UI_2009",Path="Icon_Win17S",Style=STY_Alpha)
     TextureResources(54)=(Package="UI_2009",Path="Icon_Win06S",Style=STY_Alpha)
     TextureResources(55)=(Package="UI_2009",Path="Icon_Win12S",Style=STY_Alpha)
     TextureResources(56)=(Package="UI_2009",Path="Icon_Win18S",Style=STY_Alpha)
     TextureResources(57)=(Package="UI_2009",Path="BTN01_01_P",Style=STY_Alpha)
     WinWidth=264.000000
     WinHeight=406.000000
     bAcceptDoubleClick=True
}
