class CPlayerEquip extends CSelectable;

const BN_Exit = 101;

var WornItems WornItems;
var InterfaceRegion ItemRegion[32];

var string m_sTitle;
var PlayerServerInfo	TargetInfo;		// ����� �Ǵ� �÷��̾�

var CInfoBox	TooltipBoxes[6];


function OnInit()
{
	local int i;

	WornItems = TargetInfo.WornItems;
	WornItems.OnDrawItem = InternalDrawItem;

	Components[2].NotifyId = BN_Exit;
	SetComponentTextureId(Components[2], 1, -1, 2, 3);

	GotoState('Nothing');

	for ( i = 0 ; i < 6 ; i++ )
	{
		if ( TooltipBoxes[i] == none )
		TooltipBoxes[i] = CInfoBox(AddInterface("SephirothUI.CItemInfoBox"));
	}
}


function Layout(Canvas C)
{
	local int i;
//	MoveComponent(Components[0],true, C.ClipX-Components[0].XL * Components[0].ScaleX - OffsetXL, OffsetYL);
	for (i=1;i<Components.Length;i++)
		MoveComponent(Components[i]);
	Super.Layout(C);
}


function SetTargetInfo(PlayerServerInfo tInfo)
{
	TargetInfo = tInfo;
	m_sTitle = tInfo.PlayName$Localize("InventoryUI", "OtherEquip", "SephirothUI");
}


function Render(Canvas C)
{
	local int i;
	local CInterface theInterface;
	local SephirothInterface MainHud;

	if ( ClientController(TargetInfo.Owner) == None )	{

		Parent.NotifyInterface(Self, INT_Close);
		return;
	}

	Super.Render(C);
	DrawTitle(C, m_sTitle);

	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

	if ( theInterface == None )	{

		MainHud.ItemCompareBox.SetInfo(None);
		
		for ( i = 0 ; i < 6 ; i++ )
			TooltipBoxes[i].SetInfo(None);

		return;
	}

	if ( theInterface == Self )
		ShowItemInfo(C);
}


function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)	{

	local SephirothItem Item;
	local int EquipPlace;

	if ( Key == IK_Escape && Action == IST_Press )	{

		Parent.NotifyInterface(Self, INT_Close, "ByEscape");
		return true;
	}
}


function DrawItemBack(Canvas C, int OffsetX, int OffsetY, int i)
{
	local int nResId;
	nResId = ItemRegion[i].UsedResId;

	C.SetRenderStyleAlpha();
	C.SetPos(OffsetX + ItemRegion[i].X, OffsetY + ItemRegion[i].Y);
	C.DrawTile(TextureResources[nResId].Resource, ItemRegion[i].W, ItemRegion[i].H, 0, 0, ItemRegion[i].W, ItemRegion[i].H);
}


function InternalDrawItem(Canvas C, SephirothItem Item, int OffsetX, int OffsetY)
{
	local material Sprite;
	local int X, Y, XL, YL, nPlaceIndex;

	if ( TargetInfo == none )
		return;

	nPlaceIndex = Item.EquipPlace;

	Sprite = Item.GetMaterial(TargetInfo);
	X = OffsetX + ItemRegion[nPlaceIndex].X + ItemRegion[nPlaceIndex].W / 2;
	Y = OffsetY + ItemRegion[nPlaceIndex].Y + ItemRegion[nPlaceIndex].H / 2;
	XL = Item.Width * 25;
	YL = Item.Height * 25;
	X = X - XL / 2;
	Y = Y - YL / 2;
	DrawItemBack(C, OffsetX, OffsetY, nPlaceIndex);
	C.SetPos(X, Y);
	C.DrawTile(Sprite, XL, YL, 0, 0, XL, YL);

	if (Item.IsQuiver())
	{
		C.SetPos(X,Y);
		C.SetDrawColor(255,255,255);
		C.DrawText(Item.Amount);
	}
}


function SephirothItem GetItemUnderCursor(out int EquipPlace)
{
	local int i;
	local InterfaceRegion Rgn;

	if ( !IsCursorInsideComponent(Components[0]) || Controller.Modal() )
	{
		EquipPlace = -1;
		return None;
	}

	for ( i = 0 ; i < ArrayCount(ItemRegion) ; i++)
	{
		Rgn = ItemRegion[i];
		Rgn.X += Components[0].X;
		Rgn.Y += Components[0].Y;

		if (IsCursorInsideRegion(Rgn))
		{
			EquipPlace = i;
			return WornItems.FindItem(i);
		}
	}

	EquipPlace = -1;
	return None;
}


function ShowItemInfo(Canvas C)
{
	local CInfoBox InfoBox, CompMyBox;			// ������ ������ �� ������ ����
	local SephirothItem Item;
	local array<int> EquipPlaces;
	local int EquipPlace;
	local int i, cnt;
	local int OffsetX, OffsetY;

	local WornItems MyItems;

	if (!IsCursorInsideComponent(Components[0]))
		return;

	if ( TargetInfo == none )
		return;

	InfoBox = SephirothInterface(Parent).ItemCompareBox;
	CItemInfoBox(InfoBox).SetItemOwner(TargetInfo);
//	CompMyBox = SephirothInterface(Parent).ItemTooltipBox

	if (Controller.Modal() || Controller.ContextMenu != None || Controller.bLButtonPressed || (Controller.DragSource != None && Controller.DragSource.IsInState('Dragging')))
	{
		InfoBox.SetInfo(None);
		
		for ( i = 0 ; i < 6 ; i++ )
			TooltipBoxes[i].SetInfo(None);

		return;
	}

	//add neive : 12�� ������ ��Ʈ ȿ�� ---------------------------------------
	TargetInfo.SetSetItemLevel();
	//-------------------------------------------------------------------------

	Item = GetItemUnderCursor(EquipPlace);

	if ( Item != None && Controller.bMouseMoved )
	{
		CItemInfoBox(InfoBox).SetDisplayMethod(98);//@cs added for ȥ���ɽ���״̬
		InfoBox.SetInfo(Item, Controller.MouseX, Controller.MouseY, true, C.ClipX, C.ClipY);
		OffsetX = Controller.MouseX + InfoBox.WinWidth + 5;
		OffsetY = Controller.MouseY;


		//@cs changed ��Ҫ�޸�
		
		if ( Item.CanEquip() )
		{
			/* delete here
			cnt = 0;
			MyItems = SephirothPlayer(PlayerOwner).PSI.WornItems;

			for ( i = 0 ; i < MyItems.Items.Length ; i++ )
			{
				if ( MyItems.Items[i].EquipPlace == Item.EquipPlace )
				{
					CItemInfoBox(TooltipBoxes[cnt]).SetDisplayMethod(99);
					TooltipBoxes[cnt].SetInfo(MyItems.Items[i], OffsetX, OffsetY, false);
					TooltipBoxes[cnt].ShowInterface();

					OffsetX += TooltipBoxes[cnt].WinWidth;
					cnt++;
				}
			}

			for ( i = cnt ; i < 6 ; i++ )
				TooltipBoxes[i].SetInfo(None);
			*/

/*			EquipPlaces = WornItems.FindEquipPlaces(Item);

			for ( i = 0 ; i < EquipPlaces.Length ; i++ )
			{
				EquipPlace = EquipPlaces[i];
				
				if ( WornItems.Items[EquipPlace] != none )
				{
					//Log("Xelloss : index="$i@"EquipPlace="$EquipPlace);
					TooltipBoxes.Insert(cnt, 1);
					CItemInfoBox(TooltipBoxes[cnt]).SetDisplayMethod(99);
					TooltipBoxes[cnt].SetInfo(WornItems.Items[EquipPlace], OffsetX, OffsetY, false);
					OffsetX += TooltipBoxes[cnt].WinWidth;
					cnt++;
				}
			}*/
		}
/*	local array<int> EquipPlaces;
	if(Item.CanEquip())
	{
//		//Log("neive : check Render_Equip 1");
		EquipPlaces = WornItems.FindEquipPlaces(Item);

		for (i=0;i<EquipPlaces.Length;i++) {
			EquipPlace = EquipPlaces[i];
			DrawItemEquipPlaces(C, OffsetX, OffsetY, EquipPlace);
*/			
	}
	
}

/*
function DrawItemEquipPlaces(Canvas C, int OffsetX, int OffsetY, int i)
{
	local int nResId;
	nResId = ItemRegion[i].OverResId;

	C.SetRenderStyleAlpha();
	C.SetPos(OffsetX + ItemRegion[i].X, OffsetY + ItemRegion[i].Y);
	C.DrawTile(TextureResources[nResId].Resource, ItemRegion[i].W, ItemRegion[i].H, 0, 0, ItemRegion[i].W, ItemRegion[i].H);
}


function Render_EquipPlaces(Canvas C, SephirothItem Item, int OffsetX, int OffsetY)
{
	local int i, EquipPlace;
	local array<int> EquipPlaces;

	if ( Item.CanEquip() ) //add neive : ���� ���ȭ
	{
		EquipPlaces = WornItems.FindEquipPlaces(Item);

		for ( i = 0 ; i < EquipPlaces.Length ; i++ )
		{
			EquipPlace = EquipPlaces[i];
			DrawItemEquipPlaces(C, OffsetX, OffsetY, EquipPlace);
		}
	}
}
*/

function DrawObject(Canvas C)
{
	local int i;

	C.SetDrawColor(255, 255, 255);
	C.SetRenderStyleAlpha();
	WornItems.DrawItems(C, Components[0].X, Components[0].Y);
}


function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	Parent.NotifyInterface(Self, INT_Command, "ClearInfo");

	switch (NotifyId)	{

	case BN_EXIT :

		Controller.ResetDragAndDropAll();
		Parent.NotifyInterface(Self, INT_Close);
		break;
	}
}

defaultproperties
{
     ItemRegion(0)=(X=96.000000,Y=112.000000,W=78.000000,H=30.000000,OverResId=16,UsedResId=7)
     ItemRegion(1)=(X=108.000000,Y=51.000000,W=54.000000,H=54.000000,OverResId=24,UsedResId=11)
     ItemRegion(2)=(X=96.000000,Y=148.000000,W=78.000000,H=126.000000,OverResId=14,UsedResId=5)
     ItemRegion(3)=(X=108.000000,Y=316.000000,W=54.000000,H=78.000000,OverResId=18,UsedResId=9)
     ItemRegion(4)=(X=25.000000,Y=244.000000,W=61.000000,H=61.000000,OverResId=15,UsedResId=6)
     ItemRegion(5)=(X=184.000000,Y=244.000000,W=61.000000,H=61.000000,OverResId=15,UsedResId=6)
     ItemRegion(6)=(X=41.000000,Y=313.000000,W=30.000000,H=30.000000,OverResId=17,UsedResId=8)
     ItemRegion(7)=(X=199.000000,Y=313.000000,W=30.000000,H=30.000000,OverResId=17,UsedResId=8)
     ItemRegion(8)=(X=25.000000,Y=112.000000,W=61.000000,H=126.000000,OverResId=21,UsedResId=12)
     ItemRegion(9)=(X=184.000000,Y=112.000000,W=61.000000,H=126.000000,OverResId=25,UsedResId=12)
     ItemRegion(10)=(X=25.000000,Y=351.000000,W=30.000000,H=30.000000,OverResId=17,UsedResId=8)
     ItemRegion(11)=(X=56.000000,Y=351.000000,W=30.000000,H=30.000000,OverResId=17,UsedResId=8)
     ItemRegion(12)=(X=184.000000,Y=351.000000,W=30.000000,H=30.000000,OverResId=17,UsedResId=8)
     ItemRegion(13)=(X=215.000000,Y=351.000000,W=30.000000,H=30.000000,OverResId=17,UsedResId=8)
     ItemRegion(14)=(X=266.000000,Y=180.000000,W=54.000000,H=54.000000,OverResId=26,UsedResId=11)
     ItemRegion(15)=(X=325.000000,Y=180.000000,W=54.000000,H=54.000000,OverResId=26,UsedResId=11)
     ItemRegion(16)=(X=25.000000,Y=112.000000,W=61.000000,H=126.000000,OverResId=21,UsedResId=12)
     ItemRegion(17)=(X=76.000000,Y=51.000000,W=30.000000,H=54.000000,OverResId=13,UsedResId=4)
     ItemRegion(18)=(X=165.000000,Y=51.000000,W=30.000000,H=54.000000,OverResId=13,UsedResId=4)
     ItemRegion(19)=(X=277.000000,Y=51.000000,W=30.000000,H=54.000000,OverResId=22,UsedResId=4)
     ItemRegion(20)=(X=313.000000,Y=51.000000,W=30.000000,H=54.000000,OverResId=22,UsedResId=4)
     ItemRegion(21)=(X=349.000000,Y=51.000000,W=30.000000,H=54.000000,OverResId=22,UsedResId=4)
     ItemRegion(22)=(X=277.000000,Y=112.000000,W=30.000000,H=54.000000,OverResId=22,UsedResId=4)
     ItemRegion(23)=(X=313.000000,Y=112.000000,W=30.000000,H=54.000000,OverResId=22,UsedResId=4)
     ItemRegion(24)=(X=349.000000,Y=112.000000,W=30.000000,H=54.000000,OverResId=22,UsedResId=4)
     ItemRegion(25)=(X=266.000000,Y=238.000000,W=54.000000,H=54.000000,OverResId=20,UsedResId=11)
     ItemRegion(26)=(X=96.000000,Y=280.000000,W=78.000000,H=30.000000,OverResId=23,UsedResId=7)
     ItemRegion(27)=(X=325.000000,Y=238.000000,W=54.000000,H=54.000000,OverResId=20,UsedResId=11)
     ItemRegion(28)=(X=266.000000,Y=312.000000,W=54.000000,H=54.000000,OverResId=27,UsedResId=11)
     Components(0)=(XL=404.000000,YL=423.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=404.000000,YL=423.000000,PivotDir=PVT_Copy)
     Components(2)=(Id=2,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=374.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="CloseContext")
     Components(3)=(Id=3,Type=RES_Text,XL=280.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=10.000000,OffsetYL=50.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     TextureResources(0)=(Package="UI_2011",Path="win_inven_user",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_c",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="btn_inven_ear_n",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_inven_armor_n",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="btn_inven_glv_n",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011_btn",Path="btn_inven_neck_n",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011_btn",Path="btn_inven_ring_n",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011_btn",Path="btn_inven_shoe_n",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011_btn",Path="btn_inven_sml_n",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_inven_sora_n",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="btn_inven_swd_n",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="btn_inven_ear_o",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011_btn",Path="btn_inven_armor_o",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011_btn",Path="btn_inven_glv_o",Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2011_btn",Path="btn_inven_neck_o",Style=STY_Alpha)
     TextureResources(17)=(Package="UI_2011_btn",Path="btn_inven_ring_o",Style=STY_Alpha)
     TextureResources(18)=(Package="UI_2011_btn",Path="btn_inven_shoe_o",Style=STY_Alpha)
     TextureResources(19)=(Package="UI_2011_btn",Path="btn_inven_sml_o",Style=STY_Alpha)
     TextureResources(20)=(Package="UI_2011_btn",Path="btn_inven_sora_o",Style=STY_Alpha)
     TextureResources(21)=(Package="UI_2011_btn",Path="btn_inven_swd_o",Style=STY_Alpha)
     TextureResources(22)=(Package="UI_2011_btn",Path="btn_inven_charm_o",Style=STY_Alpha)
     TextureResources(23)=(Package="UI_2011_btn",Path="btn_inven_belt_o",Style=STY_Alpha)
     TextureResources(24)=(Package="UI_2011_btn",Path="btn_inven_helmet_o",Style=STY_Alpha)
     TextureResources(25)=(Package="UI_2011_btn",Path="btn_inven_shield_o",Style=STY_Alpha)
     TextureResources(26)=(Package="UI_2011_btn",Path="btn_inven_sora_2_o",Style=STY_Alpha)
     TextureResources(27)=(Package="UI_2011_btn",Path="btn_inven_sora_3_o",Style=STY_Alpha)
     IsBottom=True
}
