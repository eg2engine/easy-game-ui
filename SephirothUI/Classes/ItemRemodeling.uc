class ItemRemodeling	extends CSelectable;

const MainItemSlotX = 25;
const MainItemSlotY = 98;
const MainItemSlotWidth = 102;
const MainItemSlotHeight = 127;

const SubItemSlotX = 139;
const SubItemSlotY = 99;

const CellWidth  = 24;
const CellHeight = 24;
const CellHCount = 4;
const CellVCount = 5;

const BN_Exit		= 1;
const BN_Remodeling = 2;
const BN_Cancel		= 3;

const BS_Normal	 = 0;
const BS_Disable = 1;
const BS_Over	 = 2;
const BS_Click	 = 3;

var string	npcName;
var string	npcDialog;
var int		npcID;
var CBag	Bag;
//var CInfoBox InfoBox;

var SephirothItem				MainItem;
var array<SephirothItem>		Resources;
var Point						MainItemPos;
var array<Point>				ResourcesPos;
var CTextPool TextPool;
//Buttons----------------------------------------
struct SpriteImage
{
	var Texture Texture;
	var float U;
	var float V;
	var float UL;
	var float VL;
};

struct InterfaceButton
{
	var int Id;
	var int BtnState;
	var float X,Y,XL,YL;
	var int Normal, Disable, Pressed, Over;
	var string Tooltip;
	var string Text;
};

var array<InterfaceButton> Buttons;
var array<SpriteImage> UnitSprites;
var Texture UITexture;
var int PressedButtonNum;
var float PageX,PageY;

function SetSpriteTexture(OUT SpriteImage Sprite, Texture Texture)
{
	Sprite.Texture = Texture;
}

function SetButton(out InterfaceButton Button, int Id, float X, float Y, float XL, float YL)
{
	Button.Id = Id;
	Button.X = X;
	Button.Y = Y;
	Button.XL = XL;
	Button.YL = YL;
	Button.BtnState = BS_Normal;
}

function SetButtonResource(out InterfaceButton Button, optional int Normal, optional int Disable, optional int Pressed, optional int Over, OPTIONAL string Tooltip)
{
	Button.Normal = Normal;
	Button.Disable = Disable;
	Button.Pressed = Pressed;
	Button.Over = Over;
	Button.Tooltip = Tooltip;
}

function ProcessButtons()
{
	local int i;
	local float Sx,Sy,Ex,Ey;
	
	for(i = 0 ; i < Buttons.Length ; i++)
	{
		if(Buttons[i].BtnState == BS_Disable)
			continue;
		Buttons[i].BtnState = BS_Normal;
		if(i == PressedButtonNum){
			Buttons[i].BtnState = BS_Click;
			continue;
		}
		Sx = PageX+Buttons[i].X;
		Sy = PageY+Buttons[i].Y;
		Ex = Sx+Buttons[i].XL;
		Ey = Sy+Buttons[i].YL;
		if(Controller.MouseX > Sx && Controller.MouseX < Ex && Controller.MouseY > Sy && Controller.MouseY < Ey)
			Buttons[i].BtnState = BS_Over;
	}
}

function int CursorInButtons()
{
	local int i;
	local float Sx,Sy,Ex,Ey;
	
	for(i = 0 ; i < Buttons.Length ; i++)
	{	
		Sx = PageX+Buttons[i].X;
		Sy = PageY+Buttons[i].Y;
		Ex = Sx+Buttons[i].XL;
		Ey = Sy+Buttons[i].YL;		
		if(Controller.MouseX > Sx && Controller.MouseX < Ex && Controller.MouseY > Sy && Controller.MouseY < Ey)
			return i;
	}
	return -1;
}

function SetButtonText(int Index, string Text)
{
	Buttons[Index].Text = Text;
}

function DrawUnitSprite(Canvas C, SpriteImage Sprite, float X, float Y, float XL, float YL)
{
	local Texture SprTexture;
	C.SetPos(X,Y);
	SprTexture = Sprite.Texture;
	C.DrawTile(SprTexture,XL,YL,Sprite.U,Sprite.V,Sprite.UL,Sprite.VL);
}

function DrawButtons(Canvas C)
{
	local int i;
	local int Index;
	local float Sx,Sy,Ex,Ey;
	local Color OldColor, TextColor;

	ProcessButtons();
	for(i = 0 ; i < Buttons.Length ; i++)
	{
		Index = -1;
		Sx = PageX + Buttons[i].X;
		Sy = PageY + Buttons[i].Y;
		Ex = Sx + Buttons[i].XL;
		Ey = Sy + Buttons[i].YL;

		C.SetRenderStyleAlpha();
		OldColor = C.DrawColor;
		//C.SetDrawColor(255,255,255);
		TextColor = class'Canvas'.static.MakeColor(255,255,255);
		if(Buttons[i].BtnState == BS_Disable) {
			TextColor = class'Canvas'.static.MakeColor(160,160,160);
			Index = Buttons[i].Disable;
		}
		else if(Buttons[i].BtnState != BS_Normal){
			TextColor = class'Canvas'.static.MakeColor(167,230,191);
			Index = Buttons[i].Over;
			if(Buttons[i].BtnState == BS_Click) {
				Sx += 1;
				Sy += 1;
				Index = Buttons[i].Pressed;
			}
		}
		if(Index != -1)
			DrawUnitSprite(C, UnitSprites[Index], PageX+Buttons[i].X, PageY+Buttons[i].Y, Buttons[i].XL, Buttons[i].YL);
		C.DrawColor = TextColor;
		if(Buttons[i].Text != "")
			C.DrawKoreanText(Buttons[i].Text,Sx,Sy,Buttons[i].XL,Buttons[i].YL);
		C.DrawColor = OldColor;
	}
}
//-----------------------------------------------

function OnInit()
{
	TextPool = Spawn(class'Interface.CTextPool');
	TextPool.InterfaceController = Controller;
	TextPool.AllowedLines = 8;

	Bag = CBag(AddInterface("SephirothUI.CBag"));
	if (Bag != None)
		Bag.ShowInterface();
	Bag.OffsetXL = 264;

//	InfoBox = CInfoBox(AddInterface("SephirothUI.CItemInfoBox"));
	UITexture = Texture(DynamicLoadObject("UI_ItemRemodeling.default.Base",class'Texture'));
	SetSpriteTexture(UnitSprites[0],UITexture);
	SetSpriteTexture(UnitSprites[1],UITexture);
	SetButtonResource(Buttons[0],-1,-1,-1,1);
	SetButtonResource(Buttons[1],-1,-1,-1,-1);
	SetButtonText(1,Localize("ItemRemodeling","Remodeling","SephirothUI"));
	SetButtonText(2,Localize("ItemRemodeling","Cancel","SephirothUI"));
	Buttons[1].BtnState = BS_Disable;
	GotoState('Nothing');
}

function OnFlush()
{
/*	if(InfoBox != None) {
		InfoBox.HideInterface();
		RemoveInterface(InfoBox);
		InfoBox = None;
	}*/

	if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
		SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);

	if(Bag != None) {
		Bag.HideInterface();
		RemoveInterface(Bag);
		Bag = None;
	}
	if (TextPool != None) {
		TextPool.Destroy();
		TextPool = None;
	}
}

function LayOut(Canvas C)
{
	PageX = C.ClipX-Components[0].XL;
	PageY = 0;
	MoveComponent(Components[0],true,PageX,PageY);
	Super.LayOut(C);
}

function DrawMainItem(Canvas C)
{
	local Material Sprite;
	local float X, Y, XL, YL;

	if(MainItem == None)
		return;

	Sprite = MainItem.GetMaterial(SephirothPlayer(PlayerOwner).PSI);
	X = Components[0].X + MainItemSlotX + (MainItemSlotWidth - (MainItem.Width * 25)) / 2;
	Y = Components[0].Y + MainItemSlotY + (MainItemSlotHeight - (MainItem.Height * 25)) / 2;
	XL = MainItem.Width * 25;
	YL = MainItem.Height * 25;
	C.SetPos(X,Y);
	C.SetRenderStyleAlpha();
	C.DrawTile(Sprite,XL,YL,0,0,XL,YL);
}

function DrawSubItems(Canvas C)
{
	local Material Sprite;
	local float X, Y, XL, YL;
	local int i;
	local SephirothItem Item;

	for(i = 0 ; i < Resources.Length ; i++)
	{
		Item = Resources[i];
		Sprite = Item.GetMaterial(SephirothPlayer(PlayerOwner).PSI);
		X = Components[0].X + SubItemSlotX + ResourcesPos[i].X * 25;
		Y = Components[0].Y + SubItemSlotY + ResourcesPos[i].Y * 25;
		XL = Item.Width * 25 - 1;
		YL = Item.Height * 25 - 1;
		C.SetPos(X,Y);
		C.SetRenderStyleAlpha();
		C.DrawTile(Sprite, XL, YL, 0, 0, XL, YL);
	}
}

function SephirothItem GetItemUnderCursor()
{
	local float X, Y, XL, YL;
	local float MouseX, MouseY;
	local SephirothItem Item;
	local int i;

	MouseX = Controller.MouseX;
	MouseY = Controller.MouseY;

	if(MainItem != None){
		X = Components[0].X + MainItemSlotX + (MainItemSlotWidth - (MainItem.Width * 25)) / 2;
		Y = Components[0].Y + MainItemSlotY + (MainItemSlotHeight - (MainItem.Height * 25)) / 2;
		XL = MainItem.Width * 25;
		YL = MainItem.Height * 25;

		if(MouseX > X && MouseX < X+XL && MouseY > Y && MouseY < Y+YL)
			return MainItem;
	}

	for(i = 0 ; i < Resources.Length ; i++)
	{
		Item = Resources[i];
		X = Components[0].X + SubItemSlotX + ResourcesPos[i].X * 25;
		Y = Components[0].Y + SubItemSlotY + ResourcesPos[i].Y * 25;
		XL = Item.Width * 25;
		YL = Item.Height * 25;
		if(MouseX > X && MouseX < X+XL && MouseY > Y && MouseY < Y+YL)
			return Item;		
	}
	return None;
}

function ShowItemInfo(Canvas C, CInfoBox InfoBox)
{
	local SephirothItem Item;
	if(!IsCursorInsideInterface())
		return;
	
	if (Controller.Modal() || Controller.ContextMenu != None || Controller.bLButtonPressed || (Controller.DragSource != None && Controller.DragSource.IsInState('Dragging'))) {
		InfoBox.SetInfo(None);
		return;
	}

	Item = GetItemUnderCursor();
	if(Item != None && Controller.bMouseMoved)
		InfoBox.SetInfo(Item, Controller.MouseX, Controller.MouseY, true, C.ClipX, C.ClipY);
	else if(Item == None)
		InfoBox.SetInfo(None);
}

function DrawDialog(Canvas C, string Text, float Sx, float Sy, float XL)
{
	local int NewLine, TextLines;
	local string Msg;

	TextPool.RemoveAll();
	NewLine = InStr(Text,"\\n");
	while (NewLine != -1) {
		Msg = Left(Text,NewLine);
		Text = Mid(Text,NewLine+2);
		TextPool.AddMessage(Msg,class'Canvas'.static.MakeColor(255,255,255),12,ETextAlign.TA_MiddleCenter);
		NewLine = InStr(Text,"\\n");
		TextLines++;
	}
	TextPool.AddMessage(Text,class'Canvas'.static.MakeColor(255,255,255),12,ETextAlign.TA_MiddleCenter);
	TextPool.DrawMessage(C,int(Sx),int(Sy)+TextLines*14,int(XL));
}

function DrawObject(Canvas C)
{	
	local CInterface theInterface;
	local SephirothInterface MainHud;
	local float Sx,Sy;

	C.SetRenderStyleAlpha();
	DrawUnitSprite(C, UnitSprites[0], PageX, PageY, Components[0].XL, Components[0].YL);
	C.KTextFormat = ETextAlign.TA_MiddleCenter;	
	//npcName
	if(npcName != ""){
		Sx = PageX + 55;
		Sy = PageY + 20;		
		C.DrawKoreanText(npcName,Sx,Sy,156,26);


	}

	//MainItemText
	Sx = PageX + 24;
	Sy = PageY + 63;
	C.DrawKoreanText(Localize("ItemRemodeling","MainItem","SephirothUI"),Sx,Sy,102,22);
	//SubItemText
	Sx = PageX + 137;
	Sy = PageY + 63;
	C.DrawKoreanText(Localize("ItemRemodeling","SubItem","SephirothUI"),Sx,Sy,102,22);

	//npcDialog
	if(npcDialog != ""){
		Sx = PageX + 24;
		Sy = PageY + 236;
		//npcDialog = ClipText(C,npcDialog,110);
		//C.DrawKoreanText(npcDialog,Sx,Sy,217,113);
		DrawDialog(C,npcDialog,Sx,Sy+56,217);
		//C.DrawTextJustified(npcDialog,0,Sx,Sy,Sx+217,Sy+113);
	}
	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	
	DrawButtons(C);
	DrawMainItem(C);
	DrawSubItems(C);

/*	if(Bag != None)
		Bag.ShowItemInfo(C, InfoBox);

	ShowItemInfo(C, InfoBox);*/

	// Xelloss - 2011. 02. 24
	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

	if ( theInterface == None )	{

		MainHud.ItemTooltipBox.SetInfo(None);
		return;
	}

	if ( theInterface == Bag )
		CBag(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if ( theInterface.Parent == Self )
		ShowItemInfo(C, MainHud.ItemTooltipBox);
	else
		MainHud.ItemTooltipBox.SetInfo(None);

	// Xelloss - 2011. 02. 14
/*	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

	if ( theInterface == None )	{

		MainHud.ItemTooltipBox.SetInfo(None);
		return;
	}

	if ( theInterface == Self )	{
		
		theInterface = GetTopInterfaceBelowCursor();

		if ( CBag(theInterface) != None )
			CBag(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);
		else
			ShowItemInfo(C, MainHud.ItemTooltipBox);
	}
	else
		MainHud.ItemTooltipBox.SetInfo(None);*/
}

function bool ObjectSelecting()
{
	local SephirothItem Item;
	
	Item = GetItemUnderCursor();

	if(Item != None)
	{
		Controller.MergeSelectCandidate(Item);
		return true;
	}
	return false;
}

function bool CanDrag()
{
	return Controller.IsSomethingSelected();
}

function RenderDragging(Canvas C)
{
	local SephirothItem Item;
	local Material Sprite;
	local float StartX,StartY;
	local int ItemPosX, ItemPosY, Sx,Sy;

	if(Controller.Modal())
		return;

	if(Controller.SelectedList.Length == 1) {
		Item = SephirothItem(Controller.SelectedList[0]);
		
		if(Item != None) {
			ItemPosX = Controller.MouseX - (Item.Width / 2) * 25;
			ItemPosY = Controller.MouseY - (Item.Height / 2) * 25;
			StartX = Components[0].X + SubItemSlotX;
			StartY = Components[0].Y + SubItemSlotY;
			Sx = (ItemPosX - StartX) / 25;
			Sy = (ItemPosY - StartY) / 25;
			if(Sx >= 0 && Sx + Item.Width-1 < CellHCount && Sy >= 0 && Sy + Item.Height-1 < CellVCount) {
				if(IsAbleDropSubItem(Sx,Sy,Item))
					Sprite = Texture'CanDrop';
				else
					Sprite = Texture'CannotDrop';
				C.SetPos(PageX+SubItemSlotX+Sx*25,PageY+SubItemSlotY+Sy*25);
				C.DrawTile(Sprite,Item.Width*25,Item.Height*25,0,0,1,1);
			}

			Sprite = Item.GetMaterial(SephirothPlayer(PlayerOwner).PSI);
			if(Sprite != None) {
				C.SetRenderStyleAlpha();
				C.SetPos(Controller.MouseX - Item.Width * 12, Controller.MouseY - Item.Height * 12);
				C.DrawTile(Sprite, Item.Width * 24, Item.Height * 24, 0, 0, Item.Width * 24, Item.Height * 24);
			}
		}
	}
}

function bool IsAbleDropSubItem(int X, int Y, SephirothItem Item)
{
	local int Sx,Sy,Ex,Ey;
	local int ItemSx, ItemSy, ItemEx, ItemEy;
	local int i;	

	ItemSx = X;
	ItemSy = Y;
	ItemEx = ItemSx + Item.Width - 1;
	ItemEy = ItemSy + Item.Height - 1;

	for(i = 0 ; i < Resources.Length ; i++)
	{
		if(Item == Resources[i])
			continue;		
		Sx = ResourcesPos[i].X;
		Sy = ResourcesPos[i].Y;
		Ex = Sx + Resources[i].Width - 1;
		Ey = Sy + Resources[i].Height - 1;
		if((Sx < ItemEx || Sx == ItemEx) && (Sy < ItemEy || Sy == ItemEy) && 
			(Ex > ItemSx || Ex == ItemSx) && (Ey > ItemSy || Ey == ItemSy)){
			return false;
		}
	}
	return true;
}

function bool Drop()
{
	local SephirothItem Item;
	local float StartX, StartY, EndX, EndY;
	local float ItemPosX, ItemPosY;
	local float MouseX,MouseY;
	local int MainItemX, MainItemY;
	local Point ItemPos;
	local int i;

	MainItemX = -1;
	MainItemY = -1;
		
	if(Controller.SelectedList.Length > 1 || Controller.SelectedList.Length == 0)
		return false;
	
	Item = SephirothItem(Controller.SelectedList[0]);
	ItemPosX = Controller.MouseX - (Item.Width / 2) * 25;
	ItemPosY = Controller.MouseY - (Item.Height / 2) * 25;
	MouseX = Controller.MouseX;
	MouseY = Controller.MouseY;

	if(Item.Level > 10)
		return false;

	StartX = Components[0].X + MainItemSlotX;
	StartY = Components[0].Y + MainItemSlotY;
	EndX = StartX + MainItemSlotWidth;
	EndY = StartY + MainItemSlotHeight;
	if(MainItem == None && MouseX > StartX && MouseX < EndX && MouseY > StartY && MouseY < EndY) {
		if(!Controller.DragSource.IsA('CBag'))
			return true;
		MainItem = Item;
		Bag.RegisterItem(Item);
		SephirothPlayer(PlayerOwner).Net.NotiRemodelItemDesc(MainItem.X,MainItem.Y,Resources);
		return true;
	}
	StartX = Components[0].X + SubItemSlotX;
	StartY = Components[0].Y + SubItemSlotY;
	ItemPos.X = (ItemPosX - StartX) / 25;
	ItemPos.Y = (ItemPosY - StartY) / 25;
	if(ItemPos.X >= 0 && ItemPos.X + Item.Width-1 < CellHCount && ItemPos.Y >= 0 && ItemPos.Y + Item.Height-1 < CellVCount) {		
		if(IsAbleDropSubItem(ItemPos.X, ItemPos.Y, Item)){
			if(!Controller.DragSource.IsA('CBag')){
				for(i = 0 ; i < Resources.Length ; i++)
				{
					if(Item == Resources[i]){
						ResourcesPos[i] = ItemPos;
						return true;
					}
				}
			}
			else{
				Bag.RegisterItem(Item);
				ResourcesPos[Resources.Length] = ItemPos;
				Resources[Resources.Length] = Item;
				if(MainItem != None) {
					MainItemX = MainItem.X;
					MainItemY = MainItem.Y;
				}
				SephirothPlayer(PlayerOwner).Net.NotiRemodelItemDesc(MainItemX,MainItemY,Resources);
			}
		}
		return true;
	}
	if(IsCursorInsideInterface())
		return true;
	return false;
}

function RemoveItem(SephirothItem Item)
{
	local int i;

	if(Item == None)
		return;

	if(Item == MainItem){
		//Log("=====>RemoveItem MainItem :"@MainItem);
		Bag.UnRegisterItem(Item);
		MainItem = None;
	}
	else {
		for(i = 0 ; i < Resources.Length ; i++)
		{
			if(Resources[i] == Item){
				Bag.UnRegisterItem(Item);
				Resources.Remove(i,1);
				ResourcesPos.Remove(i,1);
			}
		}
	}
	if(MainItem != None)
		SephirothPlayer(PlayerOwner).Net.NotiRemodelItemDesc(MainItem.X,MainItem.Y,Resources);
	else
		SephirothPlayer(PlayerOwner).Net.NotiRemodelItemDesc(-1,-1,Resources);
}

function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyType,optional coerce string Command)	{

	if ( Interface == Bag && NotifyType == INT_Close )	{

		if ( Command == "ByEscape" )	{

			if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
				SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
			else
				Parent.NotifyInterface(Self, NotifyType, Command);
		}
	}
}


function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local int Index;
	local ClientController CC;
	local SephirothItem Item;

	CC = ClientController(PlayerOwner);

	if(Key == IK_Escape && Action == IST_Press) {
		Parent.NotifyInterface(Self, INT_Close, "ByEscape");
		return true;
	}
	if(Key == IK_LeftMouse && Action == IST_Press) {
		PressedButtonNum = CursorInButtons();
	}
	if(Key == IK_LeftMouse && Action == IST_Release) {
		if(PressedButtonNum != -1){
			Index = PressedButtonNum;
			if(Buttons[Index].Id == BN_Exit) {
				Parent.NotifyInterface(Self, INT_Close);
				return true;
			}
			if(Buttons[Index].Id == BN_Remodeling && Buttons[Index].BtnState != BS_Disable) {
				SephirothPlayer(PlayerOwner).Net.NotiRemodelItem(npcID,MainItem.X, MainItem.Y, Resources);
				Parent.NotifyInterface(Self, INT_Close);
				return true;
			}
			PressedButtonNum = -1;
		}
	}
	if(KEY == IK_RightMouse && Action == IST_Release) {
		Item = GetItemUnderCursor();
		RemoveItem(Item);
		return true;
	}
	if(Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;
	return false;
}

function SetNpcName(int ID,string Name)
{
	npcID = ID;
	npcName = Name;
}

function OnRemodelItemDesc(bool bAble, string Dialog)
{
	if(bAble)
		Buttons[1].BtnState = BS_Normal;
	else
		Buttons[1].BtnState = BS_Disable;

	npcDialog = Dialog;
}


function bool IsCursorInsideInterface()	{

	if ( IsCursorInsideComponent(Components[0]) || Bag.IsCursorInsideInterface() )
		return true;

	return false;
}

defaultproperties
{
     Buttons(0)=(Id=1,X=218.000000,Y=18.000000,XL=30.000000,YL=30.000000)
     Buttons(1)=(Id=2,X=25.000000,Y=360.000000,XL=216.000000,YL=18.000000)
     UnitSprites(0)=(UL=264.000000,VL=402.000000)
     UnitSprites(1)=(U=300.000000,V=54.000000,UL=30.000000,VL=30.000000)
     PressedButtonNum=-1
     Components(0)=(XL=264.000000,YL=402.000000)
}
