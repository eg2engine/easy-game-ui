class DissolveNotifyDiag extends CMultiInterface;

const BN_Close = 1;
const BN_OK = 2;
const BN_DissolveOK = 3;
const BN_Cancle=4;


var string strCategory;
var int nSubInvenIndex;

var array<SephirothItem> ResultItem;

var array<string> strDLResultItem;
var array<int> nDLResultItemCount;

var SephirothItem useISI;
var int nUsePrice;

var Sound DisResultSound;

function OnInit()
{
	SetComponentTextureId(Components[1],1,-1,3,2);
	SetComponentText(Components[1],"Ok");		// Sephiroth.kor 파일도 수정 해야함...
	SetComponentNotify(Components[1],BN_OK,Self);

	SetComponentTextureId(Components[2],1,-1,3,2);
	SetComponentText(Components[2],"Dissolve");		// Sephiroth.kor 파일도 수정 해야함...
	SetComponentNotify(Components[2],BN_DissolveOK,Self);

	SetComponentTextureId(Components[3],1,-1,3,2);
	SetComponentText(Components[3],"Cancel");
	SetComponentNotify(Components[3],BN_Cancle,Self);

	VisibleComponent(Components[1], false);
	VisibleComponent(Components[2], false);
	VisibleComponent(Components[3], false);
}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0, true, (C.ClipX-Components[0].XL)/2, (C.ClipY-Components[0].YL)/2);
	for (i=1;i<Components.Length;i++)
		MoveComponentId(i);
	Super.Layout(C);
}

function RenderResult(Canvas C)
{
	local SephirothItem ISI;
	local Material Sprite;
	local int i;
	local string strReslutText;
	local int nDrawX,nDrawY;

	if(ResultItem.Length > 0)
	{
		for (i=0;i<ResultItem.Length;i++)
		{
			ISI = ResultItem[i];

			if (ISI != None)
			{
				Sprite = ISI.GetMaterial(SephirothPlayer(PlayerOwner).PSI);

				if (Sprite != None)
				{
					C.SetRenderStyleAlpha();
					nDrawX = Components[0].X+24;
					nDrawY = Components[0].Y+19+(i*55);

					C.SetPos(nDrawX, nDrawY);
					C.DrawTile(Sprite, 40, 40, 0, 0, Sprite.MaterialUSize(), Sprite.MaterialVSize());

					strReslutText = strDLResultItem[i]@"X"@nDLResultItemCount[i];
					//C.KTextFormat = ETextAlign.TA_MiddleCenter;
					C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
					C.SetDrawColor(229,201,174);
					C.DrawKoreanText(strReslutText, nDrawX+54, nDrawY+12, 157, 16);
				}	
			}
		}
		
	}
}

function RenderNotify(Canvas C)
{
	local Material Sprite;
	local int nDrawX,nDrawY;
	local string strReslutText;

	if( useISI != None )
	{
		Sprite = useISI.GetMaterial(SephirothPlayer(PlayerOwner).PSI);
		if (Sprite != None)
		{
			nDrawX = Components[0].X+54;
			nDrawY = Components[0].Y+74;

			C.SetRenderStyleAlpha();
			C.SetPos(nDrawX, nDrawY);
			C.DrawTile(Sprite, 40, 40, 0, 0, useISI.Width*24, useISI.Height*24);

			C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
			C.SetDrawColor(229,201,174);
			C.DrawKoreanText(useISI.LocalizedDescription, nDrawX+24, nDrawY+12, 157, 16);

			strReslutText = localize("DISSOLVENOTIFY", "ConfirmStr", "SephirothUI");
			C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
			C.SetDrawColor(255,255,255);
			C.DrawKoreanText(strReslutText, nDrawX-10, nDrawY+57, 187, 16);

			if(nUsePrice > 0)
			{
				strReslutText = localize("DISSOLVENOTIFY", "ConfirmStrPrice", "SephirothUI")$nUsePrice;
				C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
				C.SetDrawColor(255,100,100);
				C.DrawKoreanText(strReslutText, nDrawX+55, nDrawY+77, 100, 16);
			}
		}
	}
}

function OnPostRender(HUD H, Canvas C)
{
	RenderNotify(C);
	RenderResult(C);
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if ( Key == IK_Escape && Action == IST_Press )	{
		Parent.NotifyInterface(Self, INT_Close);
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
	local DissolveDiag ParDlg;
	if (NotifyId == BN_Close)
	{
		CloseBox(0);
	}
	else if (NotifyId == BN_OK)
	{
		CloseBox(0);
	}
	else if (NotifyId == BN_DissolveOK)
	{
		ParDlg = DissolveDiag(Parent);
		if( ParDlg != None )
			ParDlg.StartDissolveItem( useISI );

		CloseBox(0);
	}
	else if (NotifyId == BN_Cancle)
	{
		Controller.bLockSelect = false;
		CloseBox(0);
	}
}

function CloseBox(int Value)
{
	local int i;

	HideInterface();
	useISI = None;

	for (i=0;i<ResultItem.Length;i++)
	{
		if(ResultItem[i] != none)
		{
//			ResultItem[i].Destroy();
			ResultItem[i] = None;
		}
	}
//	ResultItem.Empty();
//	ResultItem.clear();
}

function ConfirmDissolve( SephirothItem sepItem, int nPrice )
{
	// 버튼 위치 옴김..

	useISI = sepItem;
	nUsePrice = nPrice;

	VisibleComponent(Components[1], false);	// 
	VisibleComponent(Components[2], true);	// 
	VisibleComponent(Components[3], true);	// 

	SetComponentTextureId(Components[0],5);

	Controller.bLockSelect = true;
}

function ErrorDissolve( string strDesc, int errCode )
{
	local string TextError;

	if( errCode == 0)
	{
		TextError = strDesc@localize("DISSOLVENOTIFY", "ErrorCode01", "SephirothUI");
	}
	else if( errCode == -11)
	{
		TextError = strDesc@localize("DISSOLVENOTIFY", "ErrorCode11", "SephirothUI");
	}
	else if( errCode == -10)
	{
		TextError = strDesc@localize("DISSOLVENOTIFY", "ErrorCode10", "SephirothUI");
	}

	// 버튼 위치 옴김..
	VisibleComponent(Components[1], true);	// 
	VisibleComponent(Components[2], false);	// 
	VisibleComponent(Components[3], false);	// 

	// 메시지 출력
//	SetComponentText(Components[4],"TextError");
	Components[4].Caption = TextError;

	SetComponentTextureId(Components[0],4);
}

function ResultDissolve( array<string> strItem, array<string> strModel, array<int> nItemCount )
{
	local int i;
	local SephirothItem Item;

	for (i=0;i<strItem.Length;i++)
	{
		Item = new(None) class'SephirothItem';

		Item.TypeName = strItem[i];
		Item.ModelName = strModel[i];
		Item.LocalizedDescription = strItem[i]; 
		ResultItem[i] = Item;
	}

	strDLResultItem = strItem;
	nDLResultItemCount = nItemCount;

	VisibleComponent(Components[1], true);	// 
	VisibleComponent(Components[2], false);	// 
	VisibleComponent(Components[3], false);	// 

	SetComponentTextureId(Components[0],0);

	if( DisResultSound != none )
		PlayerOwner.PlaySound(DisResultSound, SLOT_Misc,4.0,true);
}

defaultproperties
{
     Components(0)=(Type=RES_Image,XL=272.000000,YL=224.000000,PivotDir=PVT_Copy)
     Components(1)=(Id=2,Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=92.000000,OffsetYL=180.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(2)=(Id=2,Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=32.000000,OffsetYL=180.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(3)=(Id=3,Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=152.000000,OffsetYL=180.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(4)=(Id=4,Caption="Msg",Type=RES_Text,XL=55.000000,YL=55.000000,PivotDir=PVT_Copy,OffsetXL=100.000000,OffsetYL=105.000000,TextAlign=TA_MiddleCenter,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Commands)
     TextureResources(0)=(Package="UI_2011",Path="crusher_result",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011",Path="win_keep_3",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011",Path="win_keep_3",Style=STY_Alpha)
}
