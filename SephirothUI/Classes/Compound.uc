class Compound extends CMultiInterface;

const BN_Exit = 1;
const BN_ItemRefine = 2;
const BN_ItemMix = 3;
const BN_ShowRefines = 4;
const CMP_Metal = 8;
const CMP_Herb = 12;
const BN_MixLevelDown = 20;
const BN_MixLevelUp = 21;

var SephirothInventory SepInventory;
var int SelectedRaw;
var int SelectedDetailType;

var ItemRefineTable IRT;

var array<Texture> DynamicTextures;
var array<Texture> IconList;

struct ItemDetailInfo
{
	var string Name;
	var int Type;
};
var ItemDetailInfo DetailTable[24];
var int DetailIndex;

var int MixLevel;
var float VLine;

var int Metal,Wood,Gemstone,Leather,Herb;
var int Plywood,Wedge,Sawdust,Bronze,Steel,AlloyPowder,RLeather,Strap,Patch,WareGemstone,GemPowder,PowerGem,HealthHerb,ManaHerb,HerbRoot;

var array<int> Dealings;

function SetDealings(array<int> InDealings)
{
	local int i;
	for (i=0;i<InDealings.Length;i++) {
		//Log("DealWith=" $ InDealings[i]);
		Dealings[i] = InDealings[i];
	}
}

function OnInit()
{
	SepInventory = SephirothPlayer(PlayerOwner).PSI.SepInventory;
	SepInventory.OnUpdateItem = InternalUpdateItem;
	IRT = spawn(class'ItemRefineTable');
	Components[5].NotifyId = BN_Exit;
	SetComponentTextureId(Components[5],1,0,1,2);
	SetComponentTextureId(Components[6],3,0,5,4);
	SetComponentTextureId(Components[7],3,0,5,4);

	Components[6].NotifyId = BN_ItemRefine;
	Components[7].NotifyId = BN_ItemMix;
	Components[8].NotifyId = BN_ShowRefines;
	Components[9].NotifyId = BN_ShowRefines+1;
	Components[10].NotifyId = BN_ShowRefines+2;
	Components[11].NotifyId = BN_ShowRefines+3;
	Components[12].NotifyId = BN_ShowRefines+4;
	Components[16].NotifyId = BN_MixLevelDown;
	Components[17].NotifyId = BN_MixLevelUp;
	SetComponentTextureId(Components[16],6,-1,8,7);
	SetComponentTextureId(Components[17],9,-1,11,10);

	IconList[0] = LoadDynamicTexture("ItemSprites.Metal");
	IconList[1] = LoadDynamicTexture("ItemSprites.Wood");
	IconList[2] = LoadDynamicTexture("ItemSprites.Gemstone");
	IconList[3] = LoadDynamicTexture("ItemSprites.Leather");
	IconList[4] = LoadDynamicTexture("ItemSprites.Herb");

	IconList[5] = LoadDynamicTexture("ItemSprites.Plywood");
	IconList[6] = LoadDynamicTexture("ItemSprites.Wedge");
	IconList[7] = LoadDynamicTexture("ItemSprites.Sawdust");
	IconList[8] = LoadDynamicTexture("ItemSprites.Bronze");
	IconList[9] = LoadDynamicTexture("ItemSprites.Steel");
	IconList[10] = LoadDynamicTexture("ItemSprites.AlloyPowder");
	IconList[11] = LoadDynamicTexture("ItemSprites.RLeather");
	IconList[12] = LoadDynamicTexture("ItemSprites.Strap");
	IconList[13] = LoadDynamicTexture("ItemSprites.Patch");
	IconList[14] = LoadDynamicTexture("ItemSprites.WareGemstone");
	IconList[15] = LoadDynamicTexture("ItemSprites.GemPowder");
	IconList[16] = LoadDynamicTexture("ItemSprites.PowerGem");
	IconList[17] = LoadDynamicTexture("ItemSprites.HealthHerb");
	IconList[18] = LoadDynamicTexture("ItemSprites.ManaHerb");
	IconList[19] = LoadDynamicTexture("ItemSprites.HerbRoot");

}

function OnFlush()
{
	FlushDynamicTextures();

	if (IRT != None) {
		IRT.Destroy();
		IRT = None;
	}
	DeactivateComponent(Components[13]);
	DeactivateComponent(Components[14]);
	DeactivateComponent(Components[15]);
}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0,true,C.ClipX-266,0);
	for (i=1;i<Components.Length;i++) {
		if (i == 20) {
			MoveComponentId(20,true,Components[19].X,Components[19].Y-VLine);
			Components[20].YL = Dealings.Length * 13;
		}
		else
			MoveComponentId(i);
	}
}


/*
function OnRenderDragObject(Canvas C)
{
	if(Controller.DragSource.IsA('Bag'))
		Bag(Controller.DragSource).OnRenderDragObject(C);

}*/

function int GetRefineMaterialType(string Name)
{
	if (Name == "Plywood") return 0;
	if (Name == "Wedge") return 1;
	if (Name == "Sawdust") return 2;
	if (Name == "Bronze") return 3;
	if (Name == "Steel") return 4;
	if (Name == "AlloyPowder") return 5;
	if (Name == "RLeather") return 6;
	if (Name == "Strap") return 7;
	if (Name == "Patch") return 8;
	if (Name == "WareGemstone") return 9;
	if (Name == "GemPowder") return 10;
	if (Name == "PowerGem") return 11;
	if (Name == "HealthHerb") return 12;
	if (Name == "ManaHerb") return 13;
	if (Name == "HerbRoot") return 14;
}

function ResetRawData()
{
	SelectedRaw = -1;
	Components[13].Caption = "";
	Components[14].Caption = "";
	Components[15].Caption = "";
	DeactivateComponent(Components[13]);
	DeactivateComponent(Components[14]);
	DeactivateComponent(Components[15]);
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	local int Amount;
	if (NotifyId == BN_Exit)
		Parent.NotifyInterface(Self,INT_Close);
	else if (NotifyId == BN_ItemRefine) {
		if (SelectedRaw >= 0) {
			Amount = int(Components[13].Caption);
			if (Amount > 0)
				SephirothPlayer(PlayerOwner).Net.NotiMixRaw(GetRefineMaterialType(IRT.RefineTable[SelectedRaw].R1.Name),Amount);
			Amount = int(Components[14].Caption);
			if (Amount > 0)
				SephirothPlayer(PlayerOwner).Net.NotiMixRaw(GetRefineMaterialType(IRT.RefineTable[SelectedRaw].R2.Name),Amount);
			Amount = int(Components[15].Caption);
			if (Amount > 0)
				SephirothPlayer(PlayerOwner).Net.NotiMixRaw(GetRefineMaterialType(IRT.RefineTable[SelectedRaw].R3.Name),Amount);
			ResetRawData();
		}
	}
	else if (NotifyId == BN_ItemMix) {
		if (SelectedDetailType >= 0 && MixLevel >= 1 && MixLevel <= 10) {
			SephirothPlayer(PlayerOwner).Net.NotiMixRefined(Dealings[SelectedDetailType],MixLevel);
//			SelectedDetailType = -1;
		}
	}
	else if (NotifyId >= BN_ShowRefines && NotifyId <= BN_ShowRefines+5) {
		ResetRawData();
		SelectedRaw = NotifyId-BN_ShowRefines;
	}
	else if (NotifyId == BN_MixLevelDown)
		MixLevel = Clamp(MixLevel - 1, 1, 10);
	else if (NotifyId == BN_MixLevelUp)
		MixLevel = Clamp(MixLevel + 1, 1, 10);
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if(!IsCursorInsideInterface())
		return false;

	if(Key == IK_LeftMouse && (Action == IST_Press || Action == IST_Release))
	{
		if((Controller.SelectingSource != None && Controller.SelectingSource.IsInState('Selecting')) ||
			(Controller.DragSource != None && Controller.DragSource.IsInState('Dragging')) )
		{
			Controller.ResetDragAndDropAll();
		}
	}

	
	if (Key == IK_LeftMouse && Action == IST_Press && IsCursorInsideComponent(Components[19])) {
		SelectedDetailType = (Controller.MouseY - Components[20].Y) / 13;
		MixLevel = 1;
		return true;
	}
	if (Action == IST_Press && IsCursorInsideComponent(Components[19])) {
		if (Key == IK_MouseWheelUp) {
			NotifyScrollUp(-1,1);
			return true;
		}
		if (Key == IK_MouseWheelDown) {
			NotifyScrollDown(-1,1);
			return true;
		}
	}
	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;
}

function OnPreRender(Canvas C)
{
	Components[13].bDisabled = SelectedRaw == -1;
	Components[14].bDisabled = SelectedRaw == -1;
	Components[15].bDisabled = SelectedRaw == -1;
}

function ZeroItems()
{
	Metal = 0;
	Wood = 0;
	GemStone = 0;
	Leather = 0;
	Herb = 0;
	Plywood = 0;
	Wedge = 0;
	Sawdust = 0;
	Bronze = 0;
	Steel = 0;
	AlloyPowder = 0;
	RLeather = 0;
	Strap = 0;
	Patch = 0;
	WareGemstone = 0;
	GemPowder = 0;
	PowerGem = 0;
	HealthHerb = 0;
	ManaHerb = 0;
	HerbRoot = 0;
}

function InternalUpdateItem(SephirothItem Item)
{
	local string Desc;
	local int Amount;

	Desc = Item.Description;
	Amount = Item.Amount;

	if (Item.DetailType == Item.IDT_Raw) {
		if (Desc == "Herb") Herb += Amount;
		else if (Desc == "Metal") Metal += Amount;
		else if (Desc == "Wood") Wood += Amount;
		else if (Desc == "Gemstone") Gemstone += Amount;
		else if (Desc == "Rawhide") Leather += Amount;
	}
	else if (Item.DetailType == Item.IDT_Refined) {
		if (Desc == "Plywood") Plywood += Amount;
		else if (Desc == "Wedge") Wedge+= Amount;
		else if (Desc == "Sawdust") Sawdust += Amount;
		else if (Desc == "Bronze") Bronze += Amount;
		else if (Desc == "Steel") Steel += Amount;
		else if (Desc == "Alloy Powder") AlloyPowder += Amount;
		else if (Desc == "Leather") RLeather += Amount;
		else if (Desc == "Strap") Strap += Amount;
		else if (Desc == "Patch") Patch += Amount;
		else if (Desc == "Ware Gemstone") WareGemstone += Amount;
		else if (Desc == "Gem Powder") GemPowder += Amount;
		else if (Desc == "Power Gem") PowerGem += Amount;
		else if (Desc == "Health Herb") HealthHerb += Amount;
		else if (Desc == "Mana Herb") ManaHerb += Amount;
		else if (Desc == "Herb Root") HerbRoot += Amount;
	}
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y,Y2,Y3,fX,fY,fAddY;
	local int i, k;
	local int MixIndex;
	local color OldColor;

	X = Components[0].X;
	Y = Components[0].Y;

	C.KTextFormat = ETextAlign.TA_MiddleCenter;

	C.SetDrawColor(229,231,174);
	C.DrawKoreanText(Localize("ItemMix","Compound","Sephiroth"),X,Y+10,Components[0].XL,20);

	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(Localize("ItemMix","ItemMix","Sephiroth"),X,Y+38,Components[0].XL,14);

	C.SetDrawColor(184,200,255);
	C.DrawKoreanText(Localize("ItemMix","RawName","Sephiroth"),X+20,Y+63,71,13);    //21 61   //������ 26, 57
	C.DrawKoreanText(Localize("ItemMix","RawAmount","Sephiroth"),X+87,Y+63,43,13);

	C.SetDrawColor(255,255,255);

	ZeroItems();
	SepInventory.UpdateItems();
	
	C.SetRenderStyleAlpha();
	for(i=CMP_Metal; i<=CMP_Herb; i++)
	{
		C.SetPos(Components[i].X - 16, Components[i].Y);
		C.DrawTile(IconList[i-CMP_Metal], 15, 15, 0, 0, 24, 24);
	}


	// ������
	fX = X + 85;
	fY = Y + 80;
	fAddY = 14;
	C.DrawKoreanText(Metal,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(Wood,fX,fY,43,13);		fY += fAddY;
	C.DrawKoreanText(Gemstone,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(Leather,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(Herb,fX,fY,43,13);

	// ������ �߰� ��ᰡ ������ 
	if (SelectedRaw >= 0)
	{
		fX = X + 146;
		fY = Y + 76;
		fAddY = 14;
		C.DrawKoreanText(Localize("ItemMix",IRT.RefineTable[SelectedRaw].R1.Name,"Sephiroth") $ "(" $ IRT.RefineTable[SelectedRaw].R1.Size $ ")",fX,fY,65,13);
		fY += fAddY;
		C.DrawKoreanText(Localize("ItemMix",IRT.RefineTable[SelectedRaw].R2.Name,"Sephiroth") $ "(" $ IRT.RefineTable[SelectedRaw].R2.Size $ ")",fX,fY,65,13);
		fY += fAddY;
		C.DrawKoreanText(Localize("ItemMix",IRT.RefineTable[SelectedRaw].R3.Name,"Sephiroth") $ "(" $ IRT.RefineTable[SelectedRaw].R3.Size $ ")",fX,fY,65,13);
	}


	//Done
	C.SetDrawColor(184,200,255);
	C.DrawKoreanText(Localize("ItemMix","RawName","Sephiroth"),X+20,Y+168,71,13);
	C.DrawKoreanText(Localize("ItemMix","RawAmount","Sephiroth"),X+87,Y+168,43,13);
	C.SetDrawColor(255,255,255);

	fX = X + 33;
	fY = Y + 184;
	fAddY = 14;
	C.DrawKoreanText(Localize("ItemMix","Plywood","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","Wedge","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","Sawdust","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","Bronze","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","Steel","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","AlloyPowder","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","RLeather","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","Strap","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","Patch","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","WareGemstone","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","GemPowder","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","PowerGem","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","HealthHerb","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","ManaHerb","Sephiroth"),fX,fY,55,13);	fY += fAddY;
	C.DrawKoreanText(Localize("ItemMix","HerbRoot","Sephiroth"),fX,fY,55,13);

	fX = X + 33;
	fY = Y + 184;
	for(i=5; i<=19; i++)
	{
		C.SetPos(fX - 16, fY);
		C.DrawTile(IconList[i], 15, 15, 0, 0, 24, 24);
		fY += fAddY;
	}


	//Done
	fX = X + 88;
	fY = Y + 184;
	fAddY = 14;
	C.DrawKoreanText(Plywood,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(Wedge,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(Sawdust,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(Bronze,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(Steel,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(AlloyPowder,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(RLeather,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(Strap,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(Patch,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(WareGemstone,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(GemPowder,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(PowerGem,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(HealthHerb,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(ManaHerb,fX,fY,43,13);	fY += fAddY;
	C.DrawKoreanText(HerbRoot,fX,fY,43,13);

	C.DrawKoreanText(Localize("ItemMix","MixLevel","Sephiroth") $ " " $ MixLevel,X+168,Y+260,73,13);

	//���� �� �𸣰����� Done
	if (SelectedDetailType >= 0) {
		for (i=0;i<ArrayCount(DetailTable);i++)
			if (DetailTable[i].Type == Dealings[SelectedDetailType])
				break;
		if (i < ArrayCount(DetailTable)) {
			MixIndex = (i * 10) + (MixLevel - 1);
			if (MixIndex < IRT.MixTable.Length)
			{
				fX = X + 142;
				Y3 = Y + 280;
				if (IRT.MixTable[MixIndex].R1.Name != "") {
					C.DrawKoreanText(Localize("ItemMix",IRT.MixTable[MixIndex].R1.Name,"Sephiroth"),fX,Y3,65,13);	//���� 139
					C.DrawKoreanText(IRT.MixTable[MixIndex].R1.Size,X+211,Y3,33,13);
					Y3 += 14;
				}
				if (IRT.MixTable[MixIndex].R2.Name != "") {
					C.DrawKoreanText(Localize("ItemMix",IRT.MixTable[MixIndex].R2.Name,"Sephiroth"),fX,Y3,65,13);
					C.DrawKoreanText(IRT.MixTable[MixIndex].R2.Size,X+211,Y3,33,13);
					Y3 += 14;
				}
				if (IRT.MixTable[MixIndex].R3.Name != "") {
					C.DrawKoreanText(Localize("ItemMix",IRT.MixTable[MixIndex].R3.Name,"Sephiroth"),fX,Y3,65,13);
					C.DrawKoreanText(IRT.MixTable[MixIndex].R3.Size,X+211,Y3,33,13);
					Y3 += 14;
				}
				if (IRT.MixTable[MixIndex].R4.Name != "") {
					C.DrawKoreanText(Localize("ItemMix",IRT.MixTable[MixIndex].R4.Name,"Sephiroth"),fX,Y3,65,13);
					C.DrawKoreanText(IRT.MixTable[MixIndex].R4.Size,X+211,Y3,33,13);
					Y3 += 14;
				}
				if (IRT.MixTable[MixIndex].R5.Name != "") {
					C.DrawKoreanText(Localize("ItemMix",IRT.MixTable[MixIndex].R5.Name,"Sephiroth"),fX,Y3,65,13);
					C.DrawKoreanText(IRT.MixTable[MixIndex].R5.Size,X+211,Y3,33,13);
					Y3 += 14;
				}
				if (IRT.MixTable[MixIndex].R6.Name != "") {
					C.DrawKoreanText(Localize("ItemMix",IRT.MixTable[MixIndex].R6.Name,"Sephiroth"),X+134,Y3,65,13);
					C.DrawKoreanText(IRT.MixTable[MixIndex].R6.Size,X+211,Y3,33,13);
					Y3 += 14;
				}
			}
		}
	}

	OldColor = C.DrawColor;
	C.KTextFormat = ETextAlign.TA_MiddleLeft;
	X = Components[20].X-5;
	Y = Components[20].Y+5;
	Y2 = Components[19].Y+5;
	for (i=0;i<Dealings.Length;i++) {
//	for (i=0;i<ArrayCount(DetailTable);i++)
		if (Y+i*13 >= Y2 && Y+i*13+13 <= Y2+81) {
			if (i == SelectedDetailType) {
				C.SetPos(X,Y+i*13);
				C.SetDrawColor(188,63,63);
				C.DrawRect(Texture'Engine.WhiteSquareTexture',80,13);
				C.SetDrawColor(255,255,255);
			}
			else
				C.DrawColor = OldColor;
			for (k=0;k<ArrayCount(DetailTable);k++)
				if (DetailTable[k].Type == Dealings[i])
					break;
			if (k < ArrayCount(DetailTable))
				C.DrawKoreanText(Localize("ItemMix",DetailTable[k].Name,"Sephiroth"),X,Y+i*13,80,13);
		}
	}
}

function NotifyScrollUp(int CmpId,int Amount)
{
	VLine -= Amount*13;
	if (VLine < 0)
		VLine = 0;
}

function NotifyScrollDown(int CmpId,int Amount)
{
	VLine += Amount*13;
	if (VLine >= Components[20].YL - 81)
		VLine = Components[20].YL - 81;
}

function Plane PushComponentPlane(int CmpId)
{
	local Plane P;
	P.X = Dealings.Length * 13;
	P.Y = 81;
	P.Z = 13;
	P.W = VLine;
	return P;
}

final function Texture LoadDynamicTexture(string TextureName)
{
	local Texture T;
	local int i;
	T = Texture(DynamicLoadObject(TextureName,class'Texture'));
	if (T != None) {
		for (i=0;i<DynamicTextures.Length;i++)
			if (T == DynamicTextures[i])
				break;
		if (i == DynamicTextures.Length) {
			T.AddReference();
			DynamicTextures[i] = T;
		}
	}
	return T;
}
final function FlushDynamicTextures()
{
	local int i,count;

	count = DynamicTextures.Length;
	for (i=0;i<DynamicTextures.Length;i++) {
		if (DynamicTextures[i] != None) {
			UnloadTexture(Viewport(PlayerOwner.Player),DynamicTextures[i]);
		}
	}
	DynamicTextures.Remove(0,count);
}

defaultproperties
{
     SelectedRaw=-1
     SelectedDetailType=-1
     DetailTable(0)=(Name="OneHand",Type=8)
     DetailTable(1)=(Name="Shield",Type=16)
     DetailTable(2)=(Name="Helmet",Type=20)
     DetailTable(3)=(Name="Armor",Type=15)
     DetailTable(4)=(Name="Robe",Type=19)
     DetailTable(5)=(Name="Brassard",Type=18)
     DetailTable(6)=(Name="Gaiter",Type=17)
     DetailTable(7)=(Name="Staff",Type=11)
     DetailTable(8)=(Name="Bow",Type=13)
     DetailTable(9)=(Name="HPotion",Type=2)
     DetailTable(10)=(Name="MPotion",Type=3)
     DetailTable(11)=(Name="HMPotion",Type=4)
     DetailTable(12)=(Name="Necklace",Type=6)
     DetailTable(13)=(Name="Bracelet",Type=7)
     DetailTable(14)=(Name="Ring",Type=5)
     DetailTable(15)=(Name="Gem",Type=26)
     DetailTable(16)=(Name="Glove",Type=10)
     DetailTable(17)=(Name="Protector",Type=38)
     DetailTable(18)=(Name="Stick",Type=40)
     DetailTable(19)=(Name="Sandal",Type=22)
     DetailTable(20)=(Name="Sleevelet",Type=23)
     DetailTable(21)=(Name="Garb",Type=24)
     DetailTable(22)=(Name="Gown",Type=25)
     DetailTable(23)=(Name="Cap",Type=21)
     MixLevel=1
     Components(0)=(XL=266.000000,YL=423.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=266.000000,YL=423.000000,PivotDir=PVT_Copy)
     Components(5)=(Id=5,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=237.000000,OffsetYL=14.000000,ToolTip="CloseContext")
     Components(6)=(Id=6,Caption="RefineItem",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=142.000000,OffsetYL=124.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="ItemMix",ToolTip="ItemRefine")
     Components(7)=(Id=7,Caption="RefineItem2",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=142.000000,OffsetYL=370.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="ItemMix",ToolTip="ItemMix")
     Components(8)=(Id=8,Caption="Metal",Type=RES_TextButton,bUseBackLight=True,XL=51.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=36.000000,OffsetYL=80.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="ItemMix")
     Components(9)=(Id=9,Caption="Wood",Type=RES_TextButton,bUseBackLight=True,XL=51.000000,YL=13.000000,PivotId=8,PivotDir=PVT_Down,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="ItemMix")
     Components(10)=(Id=10,Caption="Gemstone",Type=RES_TextButton,bUseBackLight=True,XL=51.000000,YL=13.000000,PivotId=9,PivotDir=PVT_Down,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="ItemMix")
     Components(11)=(Id=11,Caption="Leather",Type=RES_TextButton,bUseBackLight=True,XL=51.000000,YL=13.000000,PivotId=10,PivotDir=PVT_Down,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="ItemMix")
     Components(12)=(Id=12,Caption="Herb",Type=RES_TextButton,bUseBackLight=True,XL=51.000000,YL=13.000000,PivotId=11,PivotDir=PVT_Down,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="ItemMix")
     Components(13)=(Id=13,Type=RES_Edit,XL=33.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=213.000000,OffsetYL=76.000000,MaxChar=4,ToolTip="EditRawAmount")
     Components(14)=(Id=14,Type=RES_Edit,XL=33.000000,YL=13.000000,PivotId=13,PivotDir=PVT_Down,OffsetYL=1.000000,MaxChar=4,ToolTip="EditRawAmount")
     Components(15)=(Id=15,Type=RES_Edit,XL=33.000000,YL=13.000000,PivotId=14,PivotDir=PVT_Down,OffsetYL=1.000000,MaxChar=4,ToolTip="EditRawAmount")
     Components(16)=(Id=16,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=144.000000,OffsetYL=257.000000,ToolTip="SelectLowItemLevel")
     Components(17)=(Id=17,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=231.000000,OffsetYL=257.000000,ToolTip="SelectHighItemLevel")
     Components(18)=(Id=18,Type=RES_ScrollBar,XL=20.000000,YL=92.000000,PivotDir=PVT_Copy,OffsetXL=231.000000,OffsetYL=164.000000)
     Components(19)=(Id=19,XL=106.000000,YL=91.000000,PivotDir=PVT_Copy,OffsetXL=152.000000,OffsetYL=167.000000)
     Components(20)=(Id=20,XL=96.000000,YL=234.000000)
     TextureResources(0)=(Package="UI_2011",Path="win_mix",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_brw_l_n",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="btn_brw_l_o",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_brw_l_c",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="btn_s_arr_l_n",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011_btn",Path="btn_s_arr_l_o",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011_btn",Path="btn_s_arr_l_c",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011_btn",Path="btn_s_arr_r_n",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011_btn",Path="btn_s_arr_r_o",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_s_arr_r_c",Style=STY_Alpha)
}
