class PagePlugin extends COptionPage
	config(Plugin);
//@cs 
const CK_AutoBlood0	= 1;
const CK_AutoBlood1	= 2;
const CK_AutoMagic0	= 3;
const CK_AutoMagic1	= 4;
const RB_PickupSwitch = 5;
const BN_Reflush = 6;


var array<string> EffectOptionList;

const DrugTypeBlood0 = 0;
const DrugTypeBlood1 = 1;
const DrugTypeMagic0 = 2;
const DrugTypeMagic1 = 3;

struct _SlideData
{
	var float fMin;
	var float fMax;
	var float fCur;
};

struct _item
{
	var string strLocaleName;
	var bool bSelected;
};

var CSlide Blood0Slide;
var _SlideData Blood0Data;
var CSlide Blood1Slide;
var _SlideData Blood1Data;
var CSlide Magic0Slide;
var _SlideData Magic0Data;
var CSlide Magic1Slide;
var _SlideData Magic1Data;

var CImeEdit Blood0Edit;
var CImeEdit Blood1Edit;
var CImeEdit Magic0Edit;
var CImeEdit Magic1Edit;

var config bool bAutoBlood0;
var config bool bAutoBlood1;
var config bool bAutoMagic0;
var config bool bAutoMagic1;

var config int nAutoAddBlood0;
var config int nAutoAddBlood1;
var config int nAutoAddMagic0;   
var config int nAutoAddMagic1;

var config bool bAutoPickupSwitch;

var config array<string> Drugs;

const _ListLine = 10;//12;
const _TEXT_H = 14;//16;

var float timeUpdateNearItemsDelay;
var CTextScroll CurrentItems;
var array<_item> arrayCurrentIems;
var int nStartCurrentItem;
var float VLine;

var config array<_item> arrayNoPickupItems;
var int nStartNoPickupItem;
var float VLineNoPickupIem;

var config array<_item> arrayPickupItems;
var int nStartPickupItem;
var float VLinePickupIem;

var CButtonEx ReflushBN;
var CButtonEx PickupBN;
var CButtonEx NopickupBN;
var CButtonEx DeleteNopickupBN;
var CButtonEx DeletePickupBN;

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

	ReflushBN = CButtonEx(AddInterface("SephirothUI.CButtonEx"));
	if (ReflushBN != None) {
		ReflushBN.ShowInterface();
		ReflushBN.SetSize(Components[31].XL, Components[31].YL);
		ReflushBN.OnClick = ButtonClick;
		//ReflushBN.SetImage("UI_2011_btn.btn_yell_s_", true, true, true, true);
		ReflushBN.SetTexture(bn_l_n,bn_l_o,bn_l_c,none);
		ReflushBN.Text = Localize("Setting", "PluginReflush", "Sephiroth");
		//ReflushBN.bVisible = false;
	}
	PickupBN = CButtonEx(AddInterface("SephirothUI.CButtonEx"));
	if (PickupBN != None) {
		PickupBN.ShowInterface();
		PickupBN.SetSize(Components[39].XL, Components[39].YL);
		PickupBN.OnClick = ButtonClick;
		PickupBN.SetTexture(bn_l_n,bn_l_o,bn_l_c,none);
		PickupBN.Text = Localize("Setting", "PluginItermsPickupBN", "Sephiroth");
		//ReflushBN.bVisible = false;
	}
	NopickupBN = CButtonEx(AddInterface("SephirothUI.CButtonEx"));
	if (NopickupBN != None) {
		NopickupBN.ShowInterface();
		NopickupBN.SetSize(Components[40].XL, Components[40].YL);
		NopickupBN.OnClick = ButtonClick;
		NopickupBN.SetTexture(bn_l_n,bn_l_o,bn_l_c,none);
		NopickupBN.Text = Localize("Setting", "PluginItermsNotPickupBN", "Sephiroth");
		//ReflushBN.bVisible = false;
	}
	DeleteNopickupBN= CButtonEx(AddInterface("SephirothUI.CButtonEx"));
	if (DeleteNopickupBN != None) {
		DeleteNopickupBN.ShowInterface();
		DeleteNopickupBN.SetSize(Components[41].XL, Components[41].YL);
		DeleteNopickupBN.OnClick = ButtonClick;
		DeleteNopickupBN.SetTexture(bn_l_n,bn_l_o,bn_l_c,none);
		DeleteNopickupBN.Text = Localize("Setting", "PluginDeleteBN", "Sephiroth");
		//ReflushBN.bVisible = false;
	}
	DeletePickupBN = CButtonEx(AddInterface("SephirothUI.CButtonEx"));
	if (DeletePickupBN != None) {
		DeletePickupBN.ShowInterface();
		DeletePickupBN.SetSize(Components[42].XL, Components[42].YL);
		DeletePickupBN.OnClick = ButtonClick;
		DeletePickupBN.SetTexture(bn_l_n,bn_l_o,bn_l_c,none);
		DeletePickupBN.Text = Localize("Setting", "PluginDeleteBN", "Sephiroth");
		//ReflushBN.bVisible = false;
	}


}


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
	local int i;

	Blood0Slide = CSlide(AddInterface("Interface.CSlide"));
	if(Blood0Slide != None)
	{
		Blood0Slide.ShowInterface();
		Blood0Slide.SetSlide(Components[5].X,-100,115,20, Blood0Data.fMin, nAutoAddBlood0 ,Blood0Data.fMax);
	}
	Blood1Slide = CSlide(AddInterface("Interface.CSlide"));
	if(Blood1Slide != None)
	{
		Blood1Slide.ShowInterface();
		Blood1Slide.SetSlide(Components[10].X,-100,115,20, Blood1Data.fMin, nAutoAddBlood1 ,Blood1Data.fMax);
	}
	Magic0Slide = CSlide(AddInterface("Interface.CSlide"));
	if(Magic0Slide != None)
	{
		Magic0Slide.ShowInterface();
		Magic0Slide.SetSlide(Components[15].X,-100,115,20, Magic0Data.fMin,nAutoAddMagic0 ,Magic0Data.fMax);
	}
	Magic1Slide = CSlide(AddInterface("Interface.CSlide"));
	if(Magic1Slide != None)
	{
		Magic1Slide.ShowInterface();
		Magic1Slide.SetSlide(Components[20].X,-100,115,20, Magic1Data.fMin,nAutoAddMagic1 ,Magic1Data.fMax);
	}


	Blood0Edit = CImeEdit(AddInterface("Interface.CImeEdit"));
	if (Blood0Edit != None)
	{
		Blood0Edit.bNative = True;
		Blood0Edit.SetMaxWidth(2);
		Blood0Edit.SetSize(Components[6].XL, Components[6].YL);
		Blood0Edit.SetFocusEditBox(false);
		Blood0Edit.ShowInterface();
	}
	Blood1Edit = CImeEdit(AddInterface("Interface.CImeEdit"));
	if (Blood1Edit != None)
	{
		Blood1Edit.bNative = True;
		Blood1Edit.SetMaxWidth(2);
		Blood1Edit.SetSize(Components[11].XL, Components[11].YL);
		Blood1Edit.SetFocusEditBox(false);
		Blood1Edit.ShowInterface();
	}
	if (Magic0Edit != None)
	{
		Magic0Edit.bNative = True;
		Magic0Edit.SetMaxWidth(2);
		Magic0Edit.SetSize(Components[16].XL, Components[16].YL);
		Magic0Edit.SetFocusEditBox(false);
		Magic0Edit.ShowInterface();
	}
	if (Magic1Edit != None)
	{
		Magic1Edit.bNative = True;
		Magic1Edit.SetMaxWidth(2);
		Magic1Edit.SetSize(Components[21].XL, Components[21].YL);
		Magic1Edit.SetFocusEditBox(false);
		Magic1Edit.ShowInterface();
	}

	SetButton();

	for(i=0;i<arrayPickupItems.Length;++i){
		arrayPickupItems[i].bSelected = false;
	}

	for(i=0;i<arrayNoPickupItems.Length;++i){
		arrayNoPickupItems[i].bSelected = false;
	}
	/*
	CurrentItems = CTextScroll(AddInterface("Interface.CTextScroll"));
	if (CurrentItems != None) {
		CurrentItems.ShowInterface();
		CurrentItems.TextList.bReadOnly = True;
		CurrentItems.TextList.bWrapText = True;
		CurrentItems.TextList.TextAlign = 0;
		CurrentItems.TextList.ItemHeight = 14;
		CurrentItems.SetSize(Components[30].XL, Components[30].YL);
	}*/

	timeUpdateNearItemsDelay = PlayerOwner.Level.TimeSeconds;

	//auto drink switch
	SetComponentNotify(Components[4],CK_AutoBlood0,Self);
	SetComponentNotify(Components[9],CK_AutoBlood1,Self);
	SetComponentNotify(Components[14],CK_AutoMagic0,Self);
	SetComponentNotify(Components[19],CK_AutoMagic1,Self);

	//pick up switch
	SetComponentNotify(Components[25],RB_PickupSwitch,Self);
	SetComponentNotify(Components[26],RB_PickupSwitch,Self);


	//class'PagePlugin'.default.testConfig = false;
	//class'PagePlugin'.static.StaticSaveConfig();

	//class'CMessageBox'.static.MessageBox(Self,"debug","debuginfo:"@string(class'PagePlugin'.default.testConfig),MB_Ok);

	UpdateComboItemsData();
}

function OnFlush()
{
	/*
	if(BrightnessSlide != None)
		RemoveInterface(BrightnessSlide);

	if(DistanceSlide != None)
		RemoveInterface(DistanceSlide);

	if(FogRatioSlide != None)
		RemoveInterface(FogRatioSlide);

	EmptyComboBox(Components[2]);

	EmptyComboBox(Components[12]);
*/
	if(Blood0Slide != None)
		RemoveInterface(Blood0Slide);	
	if(Blood1Slide != None)
		RemoveInterface(Blood1Slide);	
	if(Magic0Slide != None)
		RemoveInterface(Magic0Slide);	
	if(Magic1Slide != None)
		RemoveInterface(Magic1Slide);

	if (Blood0Edit != None)
	{
		Blood0Edit.SetFocusEditBox(false);
		Blood0Edit.HideInterface();
		RemoveInterface(Blood0Edit);
		Blood0Edit = None;
	}
	if (Blood1Edit != None)
	{
		Blood1Edit.SetFocusEditBox(false);
		Blood1Edit.HideInterface();
		RemoveInterface(Blood1Edit);
		Blood1Edit = None;
	}
	if (Magic0Edit != None)
	{
		Magic0Edit.SetFocusEditBox(false);
		Magic0Edit.HideInterface();
		RemoveInterface(Magic0Edit);
		Magic0Edit = None;
	}
	if (Magic1Edit != None)
	{
		Magic1Edit.SetFocusEditBox(false);
		Magic1Edit.HideInterface();
		RemoveInterface(Magic1Edit);
		Magic1Edit = None;
	}

	if (CurrentItems != None) {
		CurrentItems.HideInterface();
		RemoveInterface(CurrentItems);
		CurrentItems = None;
	}


	if (ReflushBN != None) {
		ReflushBN.HideInterface();
		RemoveInterface(ReflushBN);
		ReflushBN = None;
	}
	if (PickupBN != None) {
		PickupBN.HideInterface();
		RemoveInterface(PickupBN);
		PickupBN = None;
	}
	if (NopickupBN != None) {
		NopickupBN.HideInterface();
		RemoveInterface(NopickupBN);
		NopickupBN = None;
	}
	if (DeletePickupBN != None) {
		DeletePickupBN.HideInterface();
		RemoveInterface(DeletePickupBN);
		DeletePickupBN = None;
	}
	if (DeleteNopickupBN != None) {
		DeleteNopickupBN.HideInterface();
		RemoveInterface(DeleteNopickupBN);
		DeleteNopickupBN = None;
	}

}


function Layout(Canvas C)
{
	Super.Layout(C);
}

function UpdateNearItemsData(){
	local array<Attachment> AroundItems;
	local Attachment AroundItem;
	local _item NewItem;
	local int i,j;
	
	if((PlayerOwner.Level.TimeSeconds - timeUpdateNearItemsDelay) < 0.5){ //update per 0.5s
		return;
	}
	timeUpdateNearItemsDelay = PlayerOwner.Level.TimeSeconds;
	AroundItems = SephirothPlayer(PlayerOwner).CollectNearItemsInfo();
	
	arrayCurrentIems.Length = 0;
	for(i=0;i<AroundItems.Length;++i){
		AroundItem = AroundItems[i];
		for(j=0;j<arrayCurrentIems.Length;++j){
			if(arrayCurrentIems[j].strLocaleName == AroundItem.Info.LocalizedDescription)
				break;
		}
		if(j == arrayCurrentIems.Length){
			NewItem.strLocaleName = AroundItem.Info.LocalizedDescription;
			NewItem.bSelected = false;
			arrayCurrentIems[arrayCurrentIems.Length] = NewItem;
		}
	}
}

function ReflushPickupItemList(){
	local int i;
	SephirothController(Controller).PickupItems.Length = 0; //clear
	SephirothController(Controller).NotPickupItems.Length = 0; //clear
	for(i=0;i<arrayPickupItems.Length;++i){
		SephirothController(Controller).PickupItems[i] = arrayPickupItems[i].strLocaleName;
	}
	for(i=0;i<class'PagePlugin'.default.arrayNoPickupItems.Length;++i){
		SephirothController(Controller).NotPickupItems[i] = arrayNoPickupItems[i].strLocaleName;
	}
}

function AddNoPickupItem(){
	local int i,j;
	local _item Item,NewItem;

	for(i=0;i<arrayCurrentIems.Length;++i){
		Item = arrayCurrentIems[i];
		if(Item.bSelected){
			for(j=0;j<arrayNoPickupItems.Length;++j){
				if(arrayNoPickupItems[j].strLocaleName == Item.strLocaleName)
					break;
			}
			if(j == arrayNoPickupItems.Length){
				NewItem.strLocaleName = Item.strLocaleName;
				NewItem.bSelected = false;
				arrayNoPickupItems[arrayNoPickupItems.Length] = NewItem;
				SaveConfig();
				ReflushPickupItemList();
			}
		}
	}
}

function AddPickupItem(){
	local int i,j;
	local _item Item,NewItem;

	for(i=0;i<arrayCurrentIems.Length;++i){
		Item = arrayCurrentIems[i];
		if(Item.bSelected){
			for(j=0;j<arrayPickupItems.Length;++j){
				if(arrayPickupItems[j].strLocaleName == Item.strLocaleName)
					break;
			}
			if(j == arrayPickupItems.Length){
				NewItem.strLocaleName = Item.strLocaleName;
				NewItem.bSelected = false;
				arrayPickupItems[arrayPickupItems.Length] = NewItem;
				SaveConfig();
				ReflushPickupItemList();
			}
		}
	}
}

function DeleteNoPickupItem(){
	local int i;
	local _item Item;

	for(i=0;i<arrayNoPickupItems.Length;++i){
		Item = arrayNoPickupItems[i];
		if(Item.bSelected){
			//PlayerOwner.myHud.AddMessage(1,"DeleteNoPickupItem"@string(i)@arrayNoPickupItems[i].strLocaleName,class'Canvas'.static.MakeColor(200,100,200));
			arrayNoPickupItems.Remove(i--,1);		
			SaveConfig();
		}
	}
	if(arrayNoPickupItems.Length == 0){
		default.arrayNoPickupItems.Length = 0;
		class'PagePlugin'.static.StaticSaveConfig();
	}	
	ReflushPickupItemList();
}

function DeletePickupItem(){
	local int i;
	local _item Item;

	for(i=0;i<arrayPickupItems.Length;++i){
		Item = arrayPickupItems[i];
		if(Item.bSelected){
			//PlayerOwner.myHud.AddMessage(1,"DeletePickupItem"@string(i)@arrayPickupItems[i].strLocaleName,class'Canvas'.static.MakeColor(200,100,200));
			arrayPickupItems.Remove(i--,1);
			SaveConfig();
		}
	}
	if(arrayPickupItems.Length == 0){
		default.arrayPickupItems.Length = 0;
		class'PagePlugin'.static.StaticSaveConfig();
	}
	ReflushPickupItemList();
}

function ButtonClick(CInterface Sender)
{
	if (Sender == ReflushBN) {
		UpdateNearItemsData();
	}
	if (Sender == NopickupBN) {
		AddNoPickupItem();
	}
	if (Sender == PickupBN) {
		AddPickupItem();
	}
	if (Sender == DeleteNopickupBN) {
		DeleteNoPickupItem();
	}
	if (Sender == DeletePickupBN) {
		DeletePickupItem();
	}
}

function UpdateComponents()
{
	//Auto drink set up
	Blood0Slide.SetPos(Components[5].X,Components[5].Y);
	Blood1Slide.SetPos(Components[10].X,Components[10].Y);
	Magic0Slide.SetPos(Components[15].X,Components[15].Y);
	Magic1Slide.SetPos(Components[20].X,Components[20].Y);

	if (Blood0Edit != None)
		Blood0Edit.SetPos(Components[6].X, Components[6].Y);
	if (Blood1Edit != None)
		Blood1Edit.SetPos(Components[11].X, Components[11].Y);
	if (Magic0Edit != None)
		Magic0Edit.SetPos(Components[16].X, Components[16].Y);
	if (Magic1Edit != None)
		Magic1Edit.SetPos(Components[21].X, Components[21].Y);

	Components[36].YL = 10 * 14;
	Components[37].YL = 10 * 14;
	Components[38].YL = 10 * 14;

	//Auto pick up switch
	Components[25].bDisabled=false;
	Components[26].bDisabled=false;

}

function bool PushComponentBool(int CmpId)
{
	
	switch(CmpId)
	{
	case 4:
		return bAutoBlood0;   break;
	case 9:
		return bAutoBlood1;   break;
	case 14:
		return bAutoMagic0;   break;
	case 19:
		return bAutoMagic1;   break;
	case 25:	//ON
		return bAutoPickupSwitch;   break;
	case 26:	//Off
		//class'CMessageBox'.static.MessageBox(Self,"Disconnected",string(CmpId),MB_Ok);
		return !bAutoPickupSwitch;  break;	
	default:
		return false;
	}
}

function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{

}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if(NotifyID == RB_PickupSwitch){	//ScreenMode Option
		switch(CmpId){
		case 25: //auto pickup open
			bAutoPickupSwitch = true;
			break;
		case 26: //auto pickup close
			bAutoPickupSwitch = false;
			break;
		}
		SephirothController(Controller).bAutoPickup = bAutoPickupSwitch;
		//class'CMessageBox'.static.MessageBox(Self,"Disconnected",string(CmpId)@string(bAutoPickupSwitch),MB_Ok);
	}else if(NotifyID == CK_AutoBlood0){
		bAutoBlood0 = !bAutoBlood0;
		UpdateDrugItems(DrugTypeBlood0);
	}else if(NotifyID == CK_AutoBlood1){
		bAutoBlood1 = !bAutoBlood1;
		UpdateDrugItems(DrugTypeBlood1);
	}else if(NotifyID == CK_AutoMagic0){
		bAutoMagic0 = !bAutoMagic0;
		UpdateDrugItems(DrugTypeMagic0);
	}else if(NotifyID == CK_AutoMagic1){
		bAutoMagic1 = !bAutoMagic1;
		UpdateDrugItems(DrugTypeMagic1);
	}else if(NotifyID == BN_Reflush){
		UpdateNearItemsData();
	}

	SaveConfig();
}

function EnableAutoPickup(bool enable){
	if(enable)
		NotifyComponent(25,RB_PickupSwitch);
	else
		NotifyComponent(26,RB_PickupSwitch);
}


function OnComboUpdate(int CmpId)
{

	//class'CMessageBox'.static.MessageBox(Self,"Disconnected",strTest,MB_Ok);
	switch(CmpId)
	{
	case 8:
		Drugs[DrugTypeBlood0] = Components[8].Caption;
		break;
	case 13:
		Drugs[DrugTypeBlood1] = Components[13].Caption;
		break;
	case 18:
		Drugs[DrugTypeMagic0] = Components[18].Caption;
		break;
	case 23:
		Drugs[DrugTypeMagic1] = Components[23].Caption;
		break;
	default:
		break;
	}
	SaveConfig();
}



function bool UpdateDrugItems(int DrugType){

	
	local int i;
	local int ItemId;
	local int SubInvId;
	local int ComboComponentId;
	local SephirothInventory SepInventory;
	local array<SubInventory> SubInventories;
	local array<SephirothItem> Items;
	local bool isHpDrug;

	switch(DrugType){
	case DrugTypeBlood0:
		ComboComponentId = 8;
		EmptyDropDownMenu(Components[ComboComponentId]);
		if(!bAutoBlood0) return false;
		isHpDrug = true;
		break;
	case DrugTypeBlood1:
		ComboComponentId = 13;
		EmptyDropDownMenu(Components[ComboComponentId]);
		if(!bAutoBlood1) return false;		
		isHpDrug = true;
		break;
	case DrugTypeMagic0:
		ComboComponentId = 18;
		EmptyDropDownMenu(Components[ComboComponentId]);
		if(!bAutoMagic0) return false;		
		isHpDrug = false;
		break;
	case DrugTypeMagic1:
		ComboComponentId = 23;
		EmptyDropDownMenu(Components[ComboComponentId]);
		if(!bAutoMagic1) return false;		
		isHpDrug = false;
		break;
	default:
		return false;
	}

	//Inventory
	SepInventory = SephirothPlayer(PlayerOwner).PSI.SepInventory;
	Items = SepInventory.Items;		
	for(ItemId = 0;ItemId<Items.Length;++ItemId){
		if(isHpDrug&&Items[ItemId].IsHPotion()){					
			AddDropDownMenu(Components[ComboComponentId],Items[ItemId].LocalizedDescription);
			continue;
		}				
		if((!isHpDrug)&&Items[ItemId].IsMPotion()){
			AddDropDownMenu(Components[ComboComponentId],Items[ItemId].LocalizedDescription);
			continue;
		}
	}

	//SubInventories
	SubInventories = SephirothPlayer(PlayerOwner).PSI.SubInventories;
	for(SubInvId=0;SubInvId<SubInventories.Length;++SubInvId){
		Items = SubInventories[SubInvId].Items;			
		for(ItemId = 0;ItemId<Items.Length;++ItemId){
			if(isHpDrug&&Items[ItemId].IsHPotion()){					
				AddDropDownMenu(Components[ComboComponentId],Items[ItemId].LocalizedDescription);
				continue;
			}				
			if((!isHpDrug)&&Items[ItemId].IsMPotion()){
				AddDropDownMenu(Components[ComboComponentId],Items[ItemId].LocalizedDescription);
				continue;
			}
		}			
	}

	for(i=0;i<Components[ComboComponentId].ListBoxItems.Length;++i){
		if(Components[ComboComponentId].ListBoxItems[i] == Drugs[DrugType]){
			//EffectDetail = GetComboBoxIndex(Components[12]);
			//Components[12].Caption = EffectOptionList[EffectDetail];
			SetComboBoxCurrent(Components[ComboComponentId], i);
		}
	}
	Drugs[DrugType]=Components[ComboComponentId].Caption;
	SaveConfig();
}

function bool UpdateComboItemsData(){
	UpdateDrugItems(DrugTypeBlood0);
	UpdateDrugItems(DrugTypeBlood1);
	UpdateDrugItems(DrugTypeMagic0);
	UpdateDrugItems(DrugTypeMagic1);
	return true;
}

function NotifyScrollUp(int CmpId,int Amount)
{
	switch(CmpId){
	case 36:
		nStartCurrentItem--;	
		if(nStartCurrentItem < 0)
			nStartCurrentItem = 0;	
		//PlayerOwner.myHud.AddMessage(1,string(CmpId)@"NotifyScrollUp"@string(nStartCurrentItem),class'Canvas'.static.MakeColor(200,100,200));
		break;
	case 37:
		nStartNoPickupItem--;	
		if(nStartNoPickupItem < 0)
			nStartNoPickupItem = 0;	
		//PlayerOwner.myHud.AddMessage(1,string(CmpId)@"NotifyScrollUp"@string(nStartNoPickupItem),class'Canvas'.static.MakeColor(200,100,200));
		break;
	case 38:
		nStartPickupItem--;	
		if(nStartPickupItem < 0)
			nStartPickupItem = 0;	
		//PlayerOwner.myHud.AddMessage(1,string(CmpId)@"NotifyScrollUp"@string(nStartPickupItem),class'Canvas'.static.MakeColor(200,100,200));
		break;

	default:
		break;
	}
}

function NotifyScrollDown(int CmpId,int Amount)
	{
	switch(CmpId){
	case 36:
		nStartCurrentItem++;			
		if(nStartCurrentItem + _ListLine > arrayCurrentIems.Length)
			nStartCurrentItem = arrayCurrentIems.Length - _ListLine;			
		if(nStartCurrentItem < 0)
				nStartCurrentItem = 0;	
		//PlayerOwner.myHud.AddMessage(1,string(CmpId)@"NotifyScrollDown"@string(nStartCurrentItem),class'Canvas'.static.MakeColor(200,100,200));
		break;
	case 37:
		nStartNoPickupItem++;			
		if(nStartNoPickupItem + _ListLine > arrayNoPickupItems.Length)
			nStartNoPickupItem = arrayNoPickupItems.Length - _ListLine;			
		if(nStartNoPickupItem < 0)
				nStartNoPickupItem = 0;	
		//PlayerOwner.myHud.AddMessage(1,string(CmpId)@"NotifyScrollDown"@string(nStartNoPickupItem),class'Canvas'.static.MakeColor(200,100,200));
		break;
	case 38:
		nStartPickupItem++;			
		if(nStartPickupItem + _ListLine > arrayPickupItems.Length)
			nStartPickupItem = arrayPickupItems.Length - _ListLine;			
		if(nStartPickupItem < 0)
				nStartPickupItem = 0;	
		//PlayerOwner.myHud.AddMessage(1,string(CmpId)@"NotifyScrollDown"@string(nStartPickupItem),class'Canvas'.static.MakeColor(200,100,200));
		break;
	default:
		break;
	}
}

function Plane PushComponentPlane(int CmpId)
{
	local Plane P;
	P.X = arrayCurrentIems.Length*_TEXT_H;
	P.Y = 208;
	P.Z = _TEXT_H;
	P.W = VLine;
	return P;
}

function OnSelectItemEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta,int CmpId,out array<_item> Items,int StartPos)
{

	local int i,CL;
	CL = 0;
	if ( Key == IK_LeftMouse && Action == IST_Press ){
		if ( IsCursorInsideAt(Components[CmpId].X, Components[CmpId].Y, Components[CmpId].XL, Components[CmpId].YL) )
		{
			for ( i=StartPos ; i < Items.Length ; i++ )
			{
				if ( IsCursorInsideAt(Components[CmpId].X, Components[CmpId].Y + CL * 14, Components[CmpId].XL, 13) )
				{
					/*
					if(IsCursorInsideAt(Components[3].X, Components[3].Y + CL * 14, 13, 13))	//
					{
						ShowQuestHUD(CL + m_nStartLiveQuest);
						return false;
					}*/
					/*if(Items[i].bSelected)
						Items[i].bSelected = false;
					else
						Items[i].bSelected = true;*/
					Items[i].bSelected = !Items[i].bSelected;
					//PlayerOwner.myHud.AddMessage(1,string(CmpId)@Items[i].strLocaleName@string(Items[i].bSelected),class'Canvas'.static.MakeColor(200,100,200));
					return;
				}				
				CL++;
			}
		}
	}
}

function bool OnScrollEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta,int CmpId)
{
	//PlayerOwner.myHud.AddMessage(1,"OnKeyEvent"@string(Key)@string(Action)@string(CmpId),class'Canvas'.static.MakeColor(200,100,200));

	if(Key == IK_MouseWheelUp && IsCursorInsideComponent(Components[CmpId]) && Action == IST_Press)
	{
		NotifyScrollUp(CmpId,1);
		return true;
	}
	else if(Key == IK_MouseWheelDown && IsCursorInsideComponent(Components[CmpId]) && Action == IST_Press)
	{
		NotifyScrollDown(CmpId,1);
		return true;
	}	
	return false;
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	//scroll
	if(OnScrollEvent(Key,Action,Delta,36)) return true;
	if(OnScrollEvent(Key,Action,Delta,37)) return true;
	if(OnScrollEvent(Key,Action,Delta,38)) return true;
	//OnScrollEvent(Key,Action,Delta,36);
	//OnScrollEvent(Key,Action,Delta,37);
	//OnScrollEvent(Key,Action,Delta,38);

	OnSelectItemEvent(Key,Action,Delta,36,arrayCurrentIems,nStartCurrentItem);
	OnSelectItemEvent(Key,Action,Delta,37,arrayNoPickupItems,nStartNoPickupItem);
	OnSelectItemEvent(Key,Action,Delta,38,arrayPickupItems,nStartPickupItem);

	//combo get wrong for moving window
	if (Key == IK_LeftMouse){
		if(
			IsCursorInsideComponent(Components[8])||
			IsCursorInsideComponent(Components[13])||
			IsCursorInsideComponent(Components[18])||
			IsCursorInsideComponent(Components[23])
		)
		{
			return true;	
		}
	}
	super.OnKeyEvent(Key,Action,Delta);
}

function DrawComboBack(int CmpId,Canvas C,Texture txBack)
{
	C.SetPos(Components[CmpId].X-5, Components[CmpId].Y-5);
//	C.DrawTile(Texture(DynamicLoadObject("UI_2011.input_bg",class'Texture')),
//		Components[21].XL,Components[21].YL,0,0,Components[21].XL,Components[21].YL);
	C.DrawTile(txBack,Components[CmpId].XL,Components[CmpId].YL,0,0,Components[CmpId].XL,Components[CmpId].YL);
}

function OnPreRender(Canvas C)
{
//	local float X,Y,W,H;
//	local float fTemp;
	local int nTemp;
	local Texture txInputBack;

	C.SetRenderStyleAlpha();
	Super.OnPreRender(C);
	//UpdateComponents();

	nTemp = Blood0Slide.GetCalcedSlideValue(Blood0Data.fMax, Blood0Data.fMin);
	if(nAutoAddBlood0 != nTemp)
	{
		nAutoAddBlood0 = nTemp;
		SaveConfig();
		//ConsoleCommand("SETOPTIONF FilterDistance"@Distance);		
	}

	nTemp = Blood1Slide.GetCalcedSlideValue(Blood1Data.fMax, Blood1Data.fMin);
	if(nAutoAddBlood1 != nTemp)
	{
		nAutoAddBlood1 = nTemp;
		SaveConfig();
		//ConsoleCommand("SETOPTIONF FilterDistance"@Distance);
	}

	nTemp = Magic0Slide.GetCalcedSlideValue(Magic0Data.fMax, Magic0Data.fMin);
	if(nAutoAddMagic0 != nTemp)
	{
		nAutoAddMagic0 = nTemp;
		SaveConfig();
		//ConsoleCommand("SETOPTIONF FilterDistance"@Distance);
	}

	nTemp = Magic1Slide.GetCalcedSlideValue(Magic1Data.fMax, Magic1Data.fMin);
	if(nAutoAddMagic1 != nTemp)
	{
		nAutoAddMagic1 = nTemp;
		SaveConfig();
		//ConsoleCommand("SETOPTIONF FilterDistance"@Distance);
	}

	txInputBack = Texture(DynamicLoadObject("UI_2011.input_op_bg",class'Texture'));
	DrawComboBack(8,C,txInputBack);
	DrawComboBack(13,C,txInputBack);
	DrawComboBack(18,C,txInputBack);
	DrawComboBack(23,C,txInputBack);

	if (ReflushBN != None){
		ReflushBN.SetPos(Components[31].X,Components[31].Y-6);
		//ReflushBN.bVisible = true;
	}
	if (PickupBN != None){
		PickupBN.SetPos(Components[39].X,Components[39].Y);
		//PickupBN.bVisible = true;
	}
	if (NopickupBN != None){
		NopickupBN.SetPos(Components[40].X-10,Components[40].Y);
		//NopickupBN.bVisible = true;
	}
	if (DeleteNopickupBN != None){
		DeleteNopickupBN.SetPos(Components[41].X+40,Components[41].Y);
		//DeletePickupBN.bVisible = true;
	}
	if (DeletePickupBN != None){
		DeletePickupBN.SetPos(Components[42].X+40,Components[42].Y);
		//DeleteNopickupBN.bVisible = true;
	}
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y;
	local int i;
		

	if(!Blood0Edit.HasFocus())
	{
		//if(m_sPotalName == "")
		//{
			C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
			C.SetDrawColor(126,126,126);
			//C.DrawKoreanText(Localize("PotalUI","Plz","SephirothUI"),Components[6].X,Components[6].Y-2,Components[6].XL,Components[6].YL);
			C.DrawKoreanText(string(nAutoAddBlood0),Components[6].X,Components[6].Y,Components[6].XL,Components[6].YL);
		//}
	}

	if(!Blood1Edit.HasFocus())
	{
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
		C.SetDrawColor(126,126,126);
		C.DrawKoreanText(string(nAutoAddBlood1),Components[11].X,Components[11].Y,Components[11].XL,Components[11].YL);
	}

	if(!Magic0Edit.HasFocus())
	{
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
		C.SetDrawColor(126,126,126);
		C.DrawKoreanText(string(nAutoAddMagic0),Components[16].X,Components[16].Y,Components[16].XL,Components[16].YL);
	}

	if(!Magic1Edit.HasFocus())
	{
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
		C.SetDrawColor(126,126,126);
		C.DrawKoreanText(string(nAutoAddMagic1),Components[21].X,Components[21].Y,Components[21].XL,Components[21].YL);
	}



	C.SetDrawColor(255,255,255);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	X = Components[36].X;
	Y = Components[36].Y;
	//Y2 = Components[0].Y+67;
	//CL = 0;
	for (i=nStartCurrentItem;i<arrayCurrentIems.Length;++i)
	{
		/*
		if(IsCursorInsideAt(X, Y+(CL*14), Components[3].XL, 13) )	// 마우스 오버 백판 그리기용
		{
			if(SephirothPlayer(PlayerOwner).LiveQuests[i].Name != "")
			{
				C.SetPos(X+15,Y+CL*14);
				C.SetDrawColor(188,63,63);
				C.DrawTile(Texture'Engine.WhiteSquareTexture',Components[3].XL,14,0,0,0,0);
			}
		}*/

		if (Y+(i-nStartCurrentItem)*_TEXT_H < Y+_ListLine*_TEXT_H)
		{
			//if (CL == SelectedLiveQuest)
			//	C.SetDrawColor(255,242,0);
			C.DrawKoreanText(arrayCurrentIems[i].strLocaleName,X+15,Y+(i-nStartCurrentItem)*_TEXT_H,Components[36].XL,13);

			// 메인화면에 보여질 것인가 체크 표시
			C.SetDrawColor(255,255,255);
			C.SetPos(X,Y+(i-nStartCurrentItem)*_TEXT_H);
			if(arrayCurrentIems[i].bSelected)
				C.DrawTile(Texture(DynamicLoadObject("UI_2011_btn.check_box_c",class'Texture')),14,14,0,0,28,28);
			else
				C.DrawTile(Texture(DynamicLoadObject("UI_2011_btn.check_box_n",class'Texture')),14,14,0,0,28,28);
		}
	}

	X = Components[37].X;
	Y = Components[37].Y;
	for (i=nStartNoPickupItem;i<arrayNoPickupItems.Length;++i)
	{
		/*
		if(IsCursorInsideAt(X, Y+(CL*14), Components[3].XL, 13) )	// 마우스 오버 백판 그리기용
		{
			if(SephirothPlayer(PlayerOwner).LiveQuests[i].Name != "")
			{
				C.SetPos(X+15,Y+CL*14);
				C.SetDrawColor(188,63,63);
				C.DrawTile(Texture'Engine.WhiteSquareTexture',Components[3].XL,14,0,0,0,0);
			}
		}*/

		if (Y+(i-nStartNoPickupItem)*_TEXT_H < Y+_ListLine*_TEXT_H)
		{
			//if (CL == SelectedLiveQuest)
			//	C.SetDrawColor(255,242,0);
			C.DrawKoreanText(arrayNoPickupItems[i].strLocaleName,X+15,Y+(i-nStartNoPickupItem)*_TEXT_H,Components[37].XL,13);

			// 메인화면에 보여질 것인가 체크 표시
			C.SetDrawColor(255,255,255);
			C.SetPos(X,Y+(i-nStartNoPickupItem)*_TEXT_H);
			if(arrayNoPickupItems[i].bSelected)
				C.DrawTile(Texture(DynamicLoadObject("UI_2011_btn.check_box_c",class'Texture')),14,14,0,0,28,28);
			else
				C.DrawTile(Texture(DynamicLoadObject("UI_2011_btn.check_box_n",class'Texture')),14,14,0,0,28,28);
		}
	}

	X = Components[38].X;
	Y = Components[38].Y;
	for (i=nStartPickupItem;i<arrayPickupItems.Length;++i)
	{
		/*
		if(IsCursorInsideAt(X, Y+(CL*14), Components[3].XL, 13) )	// 마우스 오버 백판 그리기용
		{
			if(SephirothPlayer(PlayerOwner).LiveQuests[i].Name != "")
			{
				C.SetPos(X+15,Y+CL*14);
				C.SetDrawColor(188,63,63);
				C.DrawTile(Texture'Engine.WhiteSquareTexture',Components[3].XL,14,0,0,0,0);
			}
		}*/

		if (Y+(i-nStartPickupItem)*_TEXT_H < Y+_ListLine*_TEXT_H)
		{
			//if (CL == SelectedLiveQuest)
			//	C.SetDrawColor(255,242,0);
			C.DrawKoreanText(arrayPickupItems[i].strLocaleName,X+15,Y+(i-nStartPickupItem)*_TEXT_H,Components[38].XL,13);

			C.SetDrawColor(255,255,255);
			C.SetPos(X,Y+(i-nStartPickupItem)*_TEXT_H);
			if(arrayPickupItems[i].bSelected)
				C.DrawTile(Texture(DynamicLoadObject("UI_2011_btn.check_box_c",class'Texture')),14,14,0,0,28,28);
			else
				C.DrawTile(Texture(DynamicLoadObject("UI_2011_btn.check_box_n",class'Texture')),14,14,0,0,28,28);
		}
	}
}

function RePosition()
{
	SephirothInterface(SephirothPlayer(PlayerOwner).myHUD).SetDefaultUIPosition();
}

defaultproperties
{
     Blood0Data=(FMin=1.000000,FMax=99.000000)
     Blood1Data=(FMin=1.000000,FMax=99.000000)
     Magic0Data=(FMin=1.000000,FMax=99.000000)
     Magic1Data=(FMin=1.000000,FMax=99.000000)
     nAutoAddBlood0=50
     nAutoAddBlood1=50
     nAutoAddMagic0=50
     nAutoAddMagic1=50
     PageWidth=391.000000
     PageHeight=423.000000
     Components(0)=(XL=391.000000,YL=423.000000)
     Components(1)=(Id=1,Caption="PluginAutoDrink",Type=RES_Text,XL=60.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=15.000000,OffsetYL=68.000000,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(2)=(Id=2,Caption="PluginLess",Type=RES_Text,XL=155.000000,YL=20.000000,PivotId=1,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(3)=(Id=3,Caption="PluginUse",Type=RES_Text,XL=100.000000,YL=20.000000,PivotId=2,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(4)=(Id=4,Caption="PluginAutoBlood",Type=RES_CheckButton,XL=20.000000,YL=20.000000,PivotId=1,PivotDir=PVT_Down,OffsetYL=2.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
     Components(5)=(Id=5,XL=115.000000,YL=20.000000,PivotId=2,PivotDir=PVT_Down)
     Components(6)=(Id=6,XL=20.000000,YL=20.000000,PivotId=5,PivotDir=PVT_Right)
     Components(7)=(Id=7,Caption="PluginPercent",Type=RES_Text,XL=20.000000,YL=20.000000,PivotId=6,PivotDir=PVT_Right,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(8)=(Id=8,Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=3,PivotDir=PVT_Down,OffsetYL=2.000000)
     Components(9)=(Id=9,Caption="PluginAutoBlood",Type=RES_CheckButton,XL=20.000000,YL=20.000000,PivotId=4,PivotDir=PVT_Down,OffsetYL=4.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
     Components(10)=(Id=10,XL=115.000000,YL=20.000000,PivotId=5,PivotDir=PVT_Down,OffsetYL=4.000000)
     Components(11)=(Id=11,XL=20.000000,YL=20.000000,PivotId=10,PivotDir=PVT_Right)
     Components(12)=(Id=12,Caption="PluginPercent",Type=RES_Text,XL=20.000000,YL=20.000000,PivotId=11,PivotDir=PVT_Right,OffsetYL=2.000000,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(13)=(Id=13,Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=8,PivotDir=PVT_Down)
     Components(14)=(Id=14,Caption="PluginAutoMagic",Type=RES_CheckButton,XL=20.000000,YL=20.000000,PivotId=9,PivotDir=PVT_Down,OffsetYL=4.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
     Components(15)=(Id=15,XL=115.000000,YL=20.000000,PivotId=10,PivotDir=PVT_Down,OffsetYL=4.000000)
     Components(16)=(Id=16,XL=20.000000,YL=20.000000,PivotId=15,PivotDir=PVT_Right)
     Components(17)=(Id=17,Caption="PluginPercent",Type=RES_Text,XL=20.000000,YL=20.000000,PivotId=16,PivotDir=PVT_Right,OffsetYL=2.000000,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(18)=(Id=18,Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=13,PivotDir=PVT_Down)
     Components(19)=(Id=19,Caption="PluginAutoMagic",Type=RES_CheckButton,XL=20.000000,YL=20.000000,PivotId=14,PivotDir=PVT_Down,OffsetYL=4.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
     Components(20)=(Id=20,XL=115.000000,YL=20.000000,PivotId=15,PivotDir=PVT_Down,OffsetYL=4.000000)
     Components(21)=(Id=21,XL=20.000000,YL=20.000000,PivotId=20,PivotDir=PVT_Right)
     Components(22)=(Id=22,Caption="PluginPercent",Type=RES_Text,XL=20.000000,YL=20.000000,PivotId=21,PivotDir=PVT_Right,OffsetYL=2.000000,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(23)=(Id=23,Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=18,PivotDir=PVT_Down)
     Components(24)=(Id=24,Caption="PluginAutoPickup",Type=RES_Text,XL=100.000000,YL=20.000000,PivotId=19,PivotDir=PVT_Copy,OffsetYL=30.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(25)=(Id=25,Caption="On",Type=RES_RadioButton,YL=20.000000,PivotId=24,PivotDir=PVT_Right,OffsetXL=20.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
     Components(26)=(Id=26,Caption="Off",Type=RES_RadioButton,YL=20.000000,PivotId=25,PivotDir=PVT_Right,OffsetXL=20.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
     Components(27)=(Id=27,Caption="PluginItermsAround",Type=RES_Text,XL=120.000000,YL=20.000000,PivotId=24,PivotDir=PVT_Down,OffsetXL=15.000000,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(28)=(Id=28,Caption="PluginItermsNotPickup",Type=RES_Text,XL=120.000000,YL=20.000000,PivotId=27,PivotDir=PVT_Right,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(29)=(Id=29,Caption="PluginItermsPickup",Type=RES_Text,XL=120.000000,YL=20.000000,PivotId=28,PivotDir=PVT_Right,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(31)=(Id=31,XL=120.000000,YL=26.000000,PivotId=26,PivotDir=PVT_Right,OffsetXL=60.000000)
     Components(36)=(Id=36,XL=120.000000,PivotId=27,PivotDir=PVT_Down)
     Components(37)=(Id=37,XL=120.000000,PivotId=28,PivotDir=PVT_Down)
     Components(38)=(Id=38,XL=120.000000,PivotId=29,PivotDir=PVT_Down)
     Components(39)=(Id=39,XL=60.000000,YL=26.000000,PivotId=36,PivotDir=PVT_Down)
     Components(40)=(Id=40,XL=60.000000,YL=26.000000,PivotId=39,PivotDir=PVT_Right)
     Components(41)=(Id=41,XL=60.000000,YL=26.000000,PivotId=37,PivotDir=PVT_Down,OffsetXL=80.000000)
     Components(42)=(Id=42,XL=60.000000,YL=26.000000,PivotId=38,PivotDir=PVT_Down,OffsetXL=80.000000)
     TextureResources(0)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
     bNeedLayoutUpdate=False
}
