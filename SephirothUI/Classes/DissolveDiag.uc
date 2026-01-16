class DissolveDiag extends CMultiInterface
	config(Dissolve);

//struct init DissolveCategory
//{
//	var String					ItemName;			// BG Texture Name
//	var int						price;			// BG Texture Name
//};

struct init DissolveList
{
	var String					CategoryType;
	var String					ItemName;
	var int						price;
	// 할래다 말았다 더 이상하당..
	//var config array<DissolveCategory> UseItem;
};

var config array<DissolveList> DisList;

var string m_sTitle;

const BN_Close = 1;

var CBag Bag;
var CSubInventorySelectBox SubSelectBox;
var DissolveNotifyDiag DisNotifyDlg;

var string strCategory;
var int nSubInvenIndex;

var SephirothItem useISI;

var float fDisGauge;
var float fMaxGauge;
var float fStartTime;
var int nTexAniIndex;

var SephirothItem TempUseISI;

var int useItemPosX;
var int useItemPosY;

var sound	DissolveSound;

function OnInit()
{
	SetComponentTextureId(Components[1],1,-1,1,2);
	Components[1].NotifyId = BN_Close;

	Bag = CBag(AddInterface("SephirothUI.CBag"));

	if (Bag != None)
		Bag.ShowInterface();

	SubSelectBox = CSubInventorySelectBox(AddInterface("SephirothUI.CSubInventorySelectBox"));
	if ( SubSelectbox != None)
	{
		SubSelectBox.ShowInterface();
		SubSelectBox.MoveWindow(800,Bag.Components[0].Y+Bag.Components[0].YL);
	}

	DisNotifyDlg = DissolveNotifyDiag(AddInterface("SephirothUI.DissolveNotifyDiag"));
	if (DisNotifyDlg != None)
		DisNotifyDlg.HideInterface();

	m_sTitle = Localize("DISSOLVE","Title", "SephirothUI");
}

function OnFlush()
{
	if(Controller.bMouseDrag)
		Controller.bMouseDrag = false;

	Controller.SelectingSource = None;
	Controller.DragSource = None;
	Controller.ResetSelecting();
	Controller.ResetDragging();
	Controller.ResetObjectList();
	Controller.bLockSelect = false;

	if (Bag != None) {
		Bag.SepInventory.SelectAll(false);
		Bag.HideInterface();
		RemoveInterface(Bag);
		Bag = None;
	}
	if (SubSelectBox != none){
		SubSelectBox.HideInterface();
		RemoveInterface(SubSelectBox);
		SubSelectBox = none;
	}
	if (DisNotifyDlg != none){
		DisNotifyDlg.HideInterface();
		RemoveInterface(DisNotifyDlg);
		DisNotifyDlg = none;
	}
}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0, true, (C.ClipX-Components[0].XL)/2, (C.ClipY-Components[0].YL)/2);
	for (i=1;i<Components.Length;i++)
		MoveComponentId(i);
	Super.Layout(C);
}

function vector PushComponentVector(int CmpId)
{
	local vector V;

	V.X = 0;
	V.Y = fDisGauge;
	V.Z = fMaxGauge;
	return V;
}

function RenderDragging(Canvas C)
{
	local SephirothItem ISI;
	local Material Sprite;

//	local CStore Store;

//	Store = CStore(Parent);
//	if (Store != None && (/*Store.Store.ActionState == Store.Store.BN_Sell || */Store.Store.ActionState == Store.Store.BN_Repair))
//		return;

	if (Controller.Modal())
		return;

	if(Controller.SelectedList.Length == 1)
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		//if (Controller.DragSource.IsA('CBag'))
		//		Render_EquipPlaces(C, ISI, Components[0].X, Components[0].Y);

		//if (ISI != None)
		//{
		//	Sprite = ISI.GetMaterial(SephirothPlayer(PlayerOwner).PSI);

		//	if (Sprite != None)
		//	{
		//		C.SetRenderStyleAlpha();
		//		C.SetPos(Controller.MouseX - ISI.Width*12, Controller.MouseY - ISI.Height*12);
		//		C.DrawTile(Sprite, ISI.Width*24, ISI.Height*24, 0, 0, ISI.Width*24, ISI.Height*24);
		//	}	
		//}
	}
}

function RenderDissolveItem(Canvas C)
{
	local Material Sprite;

	//if (Controller.Modal())
	//	return;


	if (useISI != None)
	{
		Sprite = useISI.GetMaterial(SephirothPlayer(PlayerOwner).PSI);

		if (Sprite != None)
		{
			C.SetRenderStyleAlpha();
			C.SetPos(Components[0].X+10, Components[0].Y+10);
			C.DrawTile(Sprite, useISI.Width*12, useISI.Height*12, 0, 0, useISI.Width*24, useISI.Height*24);
		}	
	}
}

function ProcessGauge(Canvas C, float fPer)
{
	//local int OldItem;

	if( useISI == None )
		return;

	if( fDisGauge < fMaxGauge )
	{
		fDisGauge = Level.TimeSeconds - fStartTime;
		//SetComponentTextureId(Components[3],4);
		nTexAniIndex++;
		if(nTexAniIndex > 3)
			nTexAniIndex = 0;
		SetComponentTextureId(Components[3],nTexAniIndex+4);

		if( DissolveSound != none && fDisGauge < fMaxGauge-1 )
			PlayerOwner.PlaySound(DissolveSound, SLOT_Misc,4.0,true);
			//PlayerOwner.PlaySound(DissolveSound, SLOT_Misc,4.0,true);
	}
	else
	{
		SendDissolveItem();
		//Disable('Timer');
		//SetComponentTextureId(Components[3],4);
	}
}

function OnPostRender(HUD H, Canvas C)
{
	DrawTitle(C, m_sTitle);
	ProcessGauge(C, 0 );
}

function Render(Canvas C)	{

	local CInterface theInterface;
	local SephirothInterface MainHud;

	Super.Render(C);

	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

	if ( theInterface == Bag )
		Bag.ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if ( CBagResizable(theInterface) != None )
		CBagResizable(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);

}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	//Log("function bool OnKeyEvent INININ"@Key@Controller.PressX@Controller.PressY@Components[2].X);
	if ( Key == IK_Escape && Action == IST_Press )	{
		Parent.NotifyInterface(Self, INT_Close);
		return true;
	}

	if ( Key == IK_LeftMouse && Action == IST_Release && IsCursorInsideComponent(Components[3]) /*&& IsPosInsideComponent(Components[2], Controller.PressX, Controller.PressY)*/)
	{
		if( useISI == None && fDisGauge == 0.0f )
		{
			SetConsumeItem();
			Controller.ResetDragAndDropAll();
		}
		return true;
	}

	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
	{
		return true;
	}

	if (Super.OnKeyEvent(Key,Action,Delta))
		return true;
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if (NotifyId == BN_Close) {
		Parent.NotifyInterface(Self,INT_Close);
	}
	//else if (NotifyId == BN_DissolveOK)
	//{
	//	if( useISI != None )
	//	{
	//		SephirothPlayer(PlayerOwner).Net.NotiDissolveItem(strCategory,nSubInvenIndex,useISI.X,useISI.Y);
	//		useISI = None;
	//		nSubInvenIndex = 0;
	//	}
	//}
	//else if (NotifyId == BN_No)
	//{
	//	Parent.NotifyInterface(Self,INT_Close);
	//}
}

function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{
	local int Cmd;

	//Log("function NotifyInterface IN"@Interface@NotifyType@Command);
	if ( Interface == Bag && NotifyType == INT_Close )	{
		Parent.NotifyInterface(Self,INT_Close);
		//if ( Command == "ByEscape" )	{

		//	if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
		//		SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
		//	else
		//	class'CMessageBox'.static.MessageBox(Self, "CloseBooth", Localize("Modals","BoothClose","Sephiroth"), MB_YesNo, IDM_Close);
		//}				
	}
}

simulated function timer()
{
	//nTexAniIndex++;
	//if(nTexAniIndex > 4)
	//	nTexAniIndex = 0;
	//SetComponentTextureId(Components[3],nTexAniIndex+4);

	//Log("simulated function timer IN"@nTexAniIndex);
}

function SetConsumeItem()
{
	local int numDisRec;
	local int i;
	local string strTypeName;
	local SephirothItem SelectItem;

	if(Controller.SelectedList.Length == 1)
	{
		SelectItem = SephirothItem(Controller.SelectedList[0]);

		// 원래는 여기서 패킷을 날려서 확인 절차가 필요하다..
		if ( CBag(Controller.SelectingSource) != None )
			nSubInvenIndex = 1;
		else if ( CBagResizable(Controller.SelectingSource) != None )
			nSubInvenIndex = CBagResizable(Controller.SelectingSource).SubInvenIndex + 2;
		//	SephirothPlayer(PlayerOwner).Net.NotiDissolveItem(strCategory,nSubInvenIndex,SelectItem.X,SelectItem.Y);
		SephirothPlayer(PlayerOwner).Net.NotiDissolveItem(strCategory,-1*nSubInvenIndex,SelectItem.X,SelectItem.Y);
		TempUseISI = SelectItem;

		useItemPosX = SelectItem.X;
		useItemPosY = SelectItem.Y;
		return;

		numDisRec = DisList.Length;

		for(i=0;i<numDisRec;i++)
		{
			if(DisList[i].CategoryType == strCategory && DisList[i].ItemName == SelectItem.TypeName )
			{
				// 가격창 오픈
				if(DisNotifyDlg != None)
				{
					DisNotifyDlg.ShowInterface();
					DisNotifyDlg.ConfirmDissolve(SelectItem, DisList[i].price);
					//DisNotifyDlg.MoveWindow(800,100);
				}
				return;
			}
		}
		if(DisNotifyDlg != None)
		{
			//DisNotifyDlg.ShowInterface();
			//DisNotifyDlg.ErrorDissolve(SelectItem.LocalizedDescription, -11);
			class'CMessageBox'.static.MessageBox(self, "HelpMsg", SelectItem.LocalizedDescription$Localize("DISSOLVENOTIFY","ErrorCode12","SephirothUI"), MB_Ok);
		}
	}
	else
	{
//		useISI = None;
	}
}

function StartDissolveItem( SephirothItem SelectItem )
{
	if(SelectItem != None)
	{
		fStartTime = Level.TimeSeconds;
		fDisGauge = 0.0f;
		useISI = SelectItem;
		nTexAniIndex = 0;

		Controller.bLockSelect = true;
		//SetTimer(0.1f,true);
	}
}

function SendDissolveItem()
{
	local SephirothItem SendItem;

	if(nSubInvenIndex == 0)
		return;

	//if(nSubInvenIndex == 1)
	//	SendItem = SephirothPlayer(PlayerOwner).PSI.SepInventory.FindItem(useItemPosX,useItemPosY);
	//else
	//{
	//	SendItem = SephirothPlayer(PlayerOwner).PSI.SubInventories[nSubInvenIndex-2].FindItem(useItemPosX,useItemPosY);
	//}

	//if( useISI != None && SendItem == useISI )
	if( useISI != None )
	{
		SephirothPlayer(PlayerOwner).Net.NotiDissolveItem(strCategory,nSubInvenIndex,useISI.X,useISI.Y);
		useISI = None;
		TempUseISI = None;
		nSubInvenIndex = 1;

		useItemPosX = 0;
		useItemPosY = 0;

		Controller.bLockSelect = false;

		//fDisGauge = 0.0f;
	}
	else
	{
		// 메시지를 띄울까.? 훔훔훔..
		useISI = None;
		TempUseISI = None;
		nSubInvenIndex = 1;

		useItemPosX = 0;
		useItemPosY = 0;

		fDisGauge = 0.0f;

		Controller.bLockSelect = false;
	}
}

function SetCategory( string category )
{
	strCategory = category;
}

function ResultDissolve( int nErrCode, array<string> strItem, array<string> strModel, array<int> nItemCount )
{
	local int i;
	local int nItemPrice;
	local SephirothItem Item;
	local string strErr;

	if(nErrCode > 0 )
	{
		//Log("function ResultDissolve IN");
		//if( DissolveSound != none )
		//	PlayerOwner.PlaySound(DissolveSound, SLOT_Misc,0.0);

		DisNotifyDlg.ShowInterface();
		DisNotifyDlg.ResultDissolve(strItem, strModel, nItemCount);
	}
	else if(nErrCode == 0 )
	{
		//Item = new(None) class'SephirothItem';

		//Item.TypeName = strItem[0];
		//Item.ModelName = strModel[0];
		//Item.LocalizedDescription = strItem[0];
		nItemPrice = nItemCount[0];

		DisNotifyDlg.ShowInterface();
		DisNotifyDlg.ConfirmDissolve(TempUseISI, nItemPrice);

		TempUseISI = None;
		//Item = None;
	}
	else
	{
		if( nErrCode == -1)
		{
			strErr = "NO Item";
		}
		else if( nErrCode == -11)
		{
			strErr = "NO Category";
		}
		else if( nErrCode == -10)
		{
			strErr = "NO DissolveItem";
		}

		Item = new(None) class'SephirothItem';

		Item.TypeName = strItem[0];
		Item.ModelName = strModel[0];
		Item.LocalizedDescription = strItem[0]; 

		//DisNotifyDlg.ShowInterface();
		//DisNotifyDlg.ErrorDissolve("",nErrCode);
		class'CMessageBox'.static.MessageBox(self, "HelpMsg", Item.LocalizedDescription$Localize("DISSOLVENOTIFY","ErrorCode12","SephirothUI"), MB_Ok);

		Item = None;
	}
	
	fDisGauge = 0.0f;
}

defaultproperties
{
     nSubInvenIndex=1
     fMaxGauge=6.000000
     Components(0)=(Type=RES_Image,XL=254.000000,YL=178.000000,PivotDir=PVT_Copy)
     Components(1)=(Id=1,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=225.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="Close Dissolve Box")
     Components(2)=(Id=2,ResId=3,Type=RES_Gauge,XL=210.000000,YL=8.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=144.000000,bTextureSegment=True,GaugeDir=GDT_Right)
     Components(3)=(Id=3,ResId=4,Type=RES_Image,XL=228.000000,YL=104.000000,PivotDir=PVT_Copy,OffsetXL=13.000000,OffsetYL=37.000000)
     TextureResources(0)=(Package="UI_2011",Path="win_crusher",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="Gauge_blu_l",UL=114.000000,VL=10.000000,Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011",Path="crusher_1",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011",Path="crusher_2",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011",Path="crusher_3",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="crusher_4",Style=STY_Alpha)
}
