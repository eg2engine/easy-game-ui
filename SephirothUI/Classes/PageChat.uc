class PageChat extends COptionPage
	config(Plugin);
//cs 
const CK_AutoChat	    = 1;

var bool bPluginAutoChat;
var config int nPluginAutoChatInterval;
var config string CurrentChannel;

var config string CurrentContent;
struct _SlideData
{
	var float fMin;
	var float fMax;
	var float fCur;
};


var SephirothPlayer Player;

var CSlide ChatIntervalSlide;
var _SlideData ChatIntervalData;

var CImeEdit ChatIntervalEdit;

//var CImeRichEditEx ChatEdit;
var CImeRichEdit ChatEdit;

var WornItems WornItems;
var SephirothItem Shell1,Shell2;

var CButtonEx EditBN;
var CButtonEx ClearBN;
var CButtonEx OKBN;
var CButtonEx CancelBN;

function LoadOption()
{

}

function ApplyEffect()
{

}

function SaveOption()
{
}



function OnInit()
{
	bPluginAutoChat = false;

	ChatIntervalSlide = CSlide(AddInterface("Interface.CSlide"));
	if(ChatIntervalSlide != None)
	{
		ChatIntervalSlide.ShowInterface();
		ChatIntervalSlide.SetSlide(Components[5].X,-100,115,20, ChatIntervalData.fMin, nPluginAutoChatInterval ,ChatIntervalData.fMax);
	}

	ChatIntervalEdit = CImeEdit(AddInterface("Interface.CImeEdit"));
	if (ChatIntervalEdit != None)
	{
		ChatIntervalEdit.bNative = True;
		ChatIntervalEdit.SetMaxWidth(2);
		ChatIntervalEdit.SetSize(Components[6].XL, Components[6].YL);
		ChatIntervalEdit.SetFocusEditBox(false);
		ChatIntervalEdit.ShowInterface();
	}

	ChatEdit = CImeRichEdit(AddInterface("Interface.CImeRichEdit"));
	if (ChatEdit != None) {
		//if (TextCache != "")
			ChatEdit.SetText("");
		ChatEdit.ShowInterface();
		ChatEdit.SetSize(Components[10].XL, Components[10].YL);
		ChatEdit.MaxLines = 16;
		ChatEdit.LineSpace = 18;
		//ChatEdit.SetFocusEditBox(true);   //@cs 会影响IK_MouseWheelUp及IK_MouseWheelDown的接受处理
		ChatEdit.SetFocusEditBox(false);
		ChatEdit.SetTextColorEx(255,195,109);
	}

	Player = SephirothPlayer(PlayerOwner);
	SetComponentNotify(Components[4],CK_AutoChat,Self);

	WornItems = SephirothPlayer(PlayerOwner).PSI.WornItems;
	Shell1 = WornItems.FindItem(WornItems.IP_REar);
	Shell2 = WornItems.FindItem(WornItems.IP_LEar);


	SetButton();

	UpdateComboChanalsData();	

	bPluginAutoChat = SephirothController(Controller).bPluginAutoChatEnabled;
	ChatEdit.SetText(CurrentContent);

}

function OnFlush()
{
	if(ChatIntervalSlide != None)
		RemoveInterface(ChatIntervalSlide);	

	if (ChatIntervalEdit != None)
	{
		ChatIntervalEdit.SetFocusEditBox(false);
		ChatIntervalEdit.HideInterface();
		RemoveInterface(ChatIntervalEdit);
		ChatIntervalEdit = None;
	}

	if(ChatEdit != None)
	{
		ChatEdit.HideInterface();
		RemoveInterface(ChatEdit);
		ChatEdit = None;
	}

	if (EditBN != None) {
		EditBN.HideInterface();
		RemoveInterface(EditBN);
		EditBN = None;
	}

	if (ClearBN != None) {
		ClearBN.HideInterface();
		RemoveInterface(ClearBN);
		ClearBN = None;
	}

	if (OKBN != None) {
		OKBN.HideInterface();
		RemoveInterface(OKBN);
		OKBN = None;
	}

	if (CancelBN != None) {
		CancelBN.HideInterface();
		RemoveInterface(CancelBN);
		CancelBN = None;
	}

}


function Layout(Canvas C)
{
	Super.Layout(C);
}

function UpdateComponents()
{
	ChatIntervalSlide.SetPos(Components[5].X,Components[5].Y);

	if (ChatIntervalEdit != None)
		ChatIntervalEdit.SetPos(Components[6].X, Components[6].Y);

	ChatEdit.SetPos(Components[10].X, Components[10].Y);

}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	//combo get wrong for moving window
	if (Key == IK_LeftMouse){
		if(IsCursorInsideComponent(Components[8]))
		{
			return true;	
		}
	}
	super.OnKeyEvent(Key,Action,Delta);
}

function bool PushComponentBool(int CmpId)
{
	
	switch(CmpId)
	{
	case 4:
		return bPluginAutoChat;   break;

	default:
		return false;
	}
}

function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{

}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	local string content;
	if(NotifyID == CK_AutoChat){
		content = ChatEdit.GetText();
		if(content == ""){
			bPluginAutoChat = false;
			SephirothController(Controller).bPluginAutoChatEnabled = false;
			CurrentContent = "";
			SaveConfig();
			return;
		}

		bPluginAutoChat = !bPluginAutoChat;
		if(bPluginAutoChat && content != ""){
			//PlayerOwner.myHud.AddMessage(1,"Debug info:Len(content)"@string(Len(content)),class'Canvas'.static.MakeColor(200,100,200));
			if(Len(content) > 190){				
				content = Left(content,190);
				ChatEdit.SetText(content);
			}
			CurrentContent = content;
		}
		SephirothController(Controller).bPluginAutoChatEnabled = bPluginAutoChat;
		//UpdateCurrentChanals();		
	}

	SaveConfig();
}

function OnComboUpdate(int CmpId)
{
	switch(CmpId)
	{
	case 8:
		CurrentChannel = Components[8].Caption;
		break;

	default:
		break;
	}
	SaveConfig();
}



function bool UpdateCurrentChanals()
{
	local int ComboComponentId;
	local int i;

	ComboComponentId = 8;
	EmptyDropDownMenu(Components[ComboComponentId]);
	//if(!bPluginAutoChat) return false;

	AddDropDownMenu(Components[ComboComponentId],Localize("Terms", "Tell", "Sephiroth"));
	AddDropDownMenu(Components[ComboComponentId],Localize("Terms", "Shout", "Sephiroth"));
	//AddDropDownMenu(Components[ComboComponentId],Localize("Terms", "Whisper", "Sephiroth"));
	AddDropDownMenu(Components[ComboComponentId],Localize("Terms", "Party", "Sephiroth"));
	if (Shell1 != None && Shell1.IsShell() && Shell1.Channel != "")
		AddDropDownMenu(Components[ComboComponentId],Shell1.Channel);
	if (Shell1 != None && Shell2.IsShell() && Shell2.Channel != "")
		AddDropDownMenu(Components[ComboComponentId],Shell2.Channel);
	AddDropDownMenu(Components[ComboComponentId],Localize("Terms", "Team", "Sephiroth"));
	AddDropDownMenu(Components[ComboComponentId],Localize("Terms", "Clan", "Sephiroth"));

	for(i=0;i<Components[ComboComponentId].ListBoxItems.Length;++i){
		if(Components[ComboComponentId].ListBoxItems[i] == CurrentChannel){
			SetComboBoxCurrent(Components[ComboComponentId], i);
		}
	}
	CurrentChannel=Components[ComboComponentId].Caption;
	SaveConfig();

	return true;

}

function bool UpdateComboChanalsData(){
	UpdateCurrentChanals();
	return true;
}


function DrawComboBack(int CmpId,Canvas C,Texture txBack)
{
	C.SetPos(Components[CmpId].X-5, Components[CmpId].Y-5);
	C.DrawTile(txBack,Components[CmpId].XL,Components[CmpId].YL,0,0,150,24);
}

function OnPreRender(Canvas C)
{
	local int nTemp;
	local Texture txInputBack;

	C.SetRenderStyleAlpha();
	Super.OnPreRender(C);

	txInputBack = Texture(DynamicLoadObject("UI_2011.input_op_bg",class'Texture'));
	DrawComboBack(8,C,txInputBack);


	C.SetRenderStyleAlpha();
	Super.OnPreRender(C);
	//UpdateComponents();

	
	nTemp = ChatIntervalSlide.GetCalcedSlideValue(ChatIntervalData.fMax, ChatIntervalData.fMin);
	if(nPluginAutoChatInterval != nTemp)
	{
		nPluginAutoChatInterval = nTemp;
		SaveConfig();	
	}

	if (EditBN != None){
		EditBN.SetPos(Components[39].X-10,Components[39].Y);
	}

	if (ClearBN != None){
		ClearBN.SetPos(Components[40].X-10,Components[40].Y);
	}

	if (OKBN != None){
		OKBN.SetPos(Components[41].X-10,Components[41].Y);
	}

	if (CancelBN != None){
		CancelBN.SetPos(Components[42].X-10,Components[42].Y);
	}
	
}

function OnPostRender(HUD H, Canvas C)
{
	local string content;
	if(!ChatIntervalEdit.HasFocus())
	{
		//if(m_sPotalName == "")
		//{
			C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
			C.SetDrawColor(126,126,126);
			//C.DrawKoreanText(Localize("PotalUI","Plz","SephirothUI"),Components[6].X,Components[6].Y-2,Components[6].XL,Components[6].YL);
			C.DrawKoreanText(string(nPluginAutoChatInterval),Components[6].X,Components[6].Y,Components[6].XL,Components[6].YL);
		//}
	}

	//limit length	
	content = ChatEdit.GetText();
	if(content != ""){
		if(Len(content) > 190){
			content = Left(content,190);
			ChatEdit.SetText(content);
		}
	}
}

function RePosition()
{
	SephirothInterface(SephirothPlayer(PlayerOwner).myHUD).SetDefaultUIPosition();
}

/*
function ChangeEditFocus(bool bTurned)
{
	local int Index;
	local int i;

	if(!bTurned) {
		Index = -1;
		for(i = 0 ; i < 4 ; i++) 
		{
			if(OwnerWord[i].IsInBounds())
				Index = i;
			else if(OwnerWord[i].HasFocus())
				OwnerWord[i].SetFocusEditBox(false);
		}
		if(Index == -1 && PetComment.IsInBounds() && !PetComment.HasFocus())
			PetComment.SetFocusEditBox(true);
		else if(Index != -1 && !OwnerWord[Index].HasFocus())
			OwnerWord[Index].SetFocusEditBox(true);
	}
	else if(OwnerWord[0].HasFocus()) {
		OwnerWord[0].SetFocusEditBox(false);
		OwnerWord[1].SetFocusEditBox(true);
	}
	else if(OwnerWord[1].HasFocus()) {
		OwnerWord[1].SetFocusEditBox(false);
		OwnerWord[2].SetFocusEditBox(true);
	}
	else if(OwnerWord[2].HasFocus()) {
		OwnerWord[2].SetFocusEditBox(false);
		OwnerWord[3].SetFocusEditBox(true);
	}
	else if(OwnerWord[3].HasFocus()) {
		OwnerWord[3].SetFocusEditBox(false);
		PetComment.SetFocusEditBox(true);
	}
	else if(PetComment.HasFocus()) {
		PetComment.SetFocusEditBox(false);
		OwnerWord[0].SetFocusEditBox(true);
	}
}
*/

function SetButton()
{
	
	local texture bn_l_n;
	local texture bn_l_o;
	local texture bn_l_c;
	bn_l_n = Texture(DynamicLoadObject("UI_2011_btn.btn_brw_l_n",class'Texture'));
	bn_l_o = Texture(DynamicLoadObject("UI_2011_btn.btn_brw_l_o",class'Texture'));
	bn_l_c = Texture(DynamicLoadObject("UI_2011_btn.btn_brw_l_c",class'Texture'));

	//class'CMessageBox'.static.MessageBox(Self,"Disconnected",string(bn_l_n)@string(bn_l_o)@string(bn_l_c),MB_Ok);
	//PlayerOwner.myHud.AddMessage(1,string(none)@string(bn_l_n)@string(bn_l_o)@string(bn_l_c),class'Canvas'.static.MakeColor(200,100,200));
	EditBN = CButtonEx(AddInterface("SephirothUI.CButtonEx"));
	if (EditBN != None) {
		EditBN.ShowInterface();
		EditBN.SetSize(Components[39].XL, Components[39].YL);
		EditBN.OnClick = ButtonClick;
		EditBN.SetTexture(bn_l_n,bn_l_o,bn_l_c,none);
		EditBN.Text = Localize("Setting", "PluginChatEdit", "Sephiroth");
		//ReflushBN.bVisible = false;
	}

	ClearBN = CButtonEx(AddInterface("SephirothUI.CButtonEx"));
	if (ClearBN != None) {
		ClearBN.ShowInterface();
		ClearBN.SetSize(Components[40].XL, Components[40].YL);
		ClearBN.OnClick = ButtonClick;
		ClearBN.SetTexture(bn_l_n,bn_l_o,bn_l_c,none);
		ClearBN.Text = Localize("Setting", "PluginChatClear", "Sephiroth");
		//ReflushBN.bVisible = false;
	}
	OKBN= CButtonEx(AddInterface("SephirothUI.CButtonEx"));
	if (OKBN != None) {
		OKBN.ShowInterface();
		OKBN.SetSize(Components[41].XL, Components[41].YL);
		OKBN.OnClick = ButtonClick;
		OKBN.SetTexture(bn_l_n,bn_l_o,bn_l_c,none);
		OKBN.Text = Localize("Setting", "PluginChatOK", "Sephiroth");
		//ReflushBN.bVisible = false;
	}
	CancelBN = CButtonEx(AddInterface("SephirothUI.CButtonEx"));
	if (CancelBN != None) {
		CancelBN.ShowInterface();
		CancelBN.SetSize(Components[42].XL, Components[42].YL);
		CancelBN.OnClick = ButtonClick;
		CancelBN.SetTexture(bn_l_n,bn_l_o,bn_l_c,none);
		CancelBN.Text = Localize("Setting", "PluginChatCancel", "Sephiroth");
		//ReflushBN.bVisible = false;
	}
}

function ButtonClick(CInterface Sender)
{
	if (Sender == EditBN) {
		ChatEdit.SetFocusEditBox(true);
	}else if (Sender == ClearBN) {
		CurrentContent = "";
		ChatEdit.SetText(CurrentContent);
		bPluginAutoChat = false;
		SephirothController(Controller).bPluginAutoChatEnabled = false;
		SaveConfig();
	}
	else if (Sender == OKBN) {	
		ChatEdit.SetFocusEditBox(false);
		bPluginAutoChat = false;
		NotifyComponent(41,CK_AutoChat);
	}
	else if (Sender == CancelBN) {
		ChatEdit.SetFocusEditBox(false);
		bPluginAutoChat = true;
		NotifyComponent(42,CK_AutoChat);
	}
}

defaultproperties
{
     ChatIntervalData=(FMin=600.000000,FMax=1800.000000)
     PageWidth=391.000000
     PageHeight=423.000000
     Components(0)=(XL=391.000000,YL=423.000000)
     Components(1)=(Id=1,Caption="PluginAutoChat",Type=RES_Text,XL=60.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=15.000000,OffsetYL=68.000000,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(2)=(Id=2,Caption="PluginAutoChatInterval",Type=RES_Text,XL=155.000000,YL=20.000000,PivotId=1,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(3)=(Id=3,Caption="PluginAutoChatChanal",Type=RES_Text,XL=100.000000,YL=20.000000,PivotId=2,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(4)=(Id=4,Caption="PluginAutoChatSwitch",Type=RES_CheckButton,XL=20.000000,YL=20.000000,PivotId=1,PivotDir=PVT_Down,OffsetYL=2.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
     Components(5)=(Id=5,XL=110.000000,YL=20.000000,PivotId=4,PivotDir=PVT_Right,OffsetXL=10.000000)
     Components(6)=(Id=6,XL=33.000000,YL=20.000000,PivotId=5,PivotDir=PVT_Right,OffsetXL=14.000000)
     Components(7)=(Id=7,Caption="PluginSecent",Type=RES_Text,XL=20.000000,YL=20.000000,PivotId=6,PivotDir=PVT_Right,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(8)=(Id=8,Type=RES_TextButton,XL=120.000000,YL=24.000000,PivotId=7,PivotDir=PVT_Right,OffsetYL=2.000000)
     Components(9)=(Id=9,Caption="PluginAutoChatEdit",Type=RES_Text,XL=60.000000,YL=20.000000,PivotId=4,PivotDir=PVT_Down,OffsetXL=15.000000,OffsetYL=10.000000,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(10)=(Id=10,Type=RES_Text,XL=218.000000,YL=244.000000,PivotId=9,PivotDir=PVT_Down)
     Components(39)=(Id=39,XL=60.000000,YL=26.000000,PivotId=8,PivotDir=PVT_Down,OffsetYL=160.000000)
     Components(40)=(Id=40,XL=60.000000,YL=26.000000,PivotId=39,PivotDir=PVT_Down)
     Components(41)=(Id=41,XL=60.000000,YL=26.000000,PivotId=40,PivotDir=PVT_Down)
     Components(42)=(Id=42,XL=60.000000,YL=26.000000,PivotId=41,PivotDir=PVT_Down)
     TextureResources(0)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
     bNeedLayoutUpdate=False
}
