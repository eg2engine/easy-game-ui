class RandomBoxDiag extends CMultiInterface
	dependsOn(RandomBoxType)
	config(RandomBox);

var string								RandomBoxTitle;
var RandomBoxType.RandomBoxRecordRes	RndBoxBGRes;
var RandomBoxType.RandomBoxRecordRes	RndBoxItemListTextRes;
var array<String>						ArrayItemListText;

var config	RandomboxModel	RndModel;
var config	string			RndModelName;
var RandomBoxType.RandomBoxRecordRes	RndBoxModelRes;
var Material							RndBoxModelSkin;
var RandomboxModel						ItemIconModel;
var Array<RandomboxModel>				ArItemIconModel;

var RandomBoxType.RandomBoxRecordRes	RndBoxItemListIconRes;

var RandomBoxType.RandomBoxRecordRes	RndBoxGaugeRes;

var color	RndBoxGaugeColor[5];
var RandomBoxType.RandomBoxRecordRes	RndBoxEffectRes[5];
var class<xEmitter>						RndBoxEffectEmitterResClass[5];
var xEmitter							RndBoxEffectEmitterRes[5];
var RandomBoxEffectMesh					RndBoxEffectMeshRes[5];
var RandomBoxSprite						RndBoxEffectSpriteRes[5];

var RandomBoxEffectMesh					HideEffectSpriteRes;

var string	RndBoxSoundName[5];
var sound	RndBoxSound[5];
var int		bPlaySound[5];

var float	TotalTime;

var float	RandomBoxTime[5];
var float	AminMeshTime[5];
var float	AminIconTime[5];

var string	getItemTypeName;
var Texture getItemTypeTexture;
var mesh	getItemTypeMesh;
var string	getRndItemName;

var config	vector RandMeshOffset;

var config	int nItemPosX;
var config	int nItemPosY;

var config	int nRndState;

var config	string RndBoxBGTexName;
var config	Texture TexRndBoxBG;

var config	string RndBoxIconTexName;
var config	Texture TexRndBoxIcon;

var config	float fRandGauge;
var config	float fMaxGauge;
var config	Texture TexRndBoxGauge;

var config	RandomBoxSprite ImageSprite;

var config	float fStartTime;
var config	float fResultStartTime;

var config	Array<Texture>		arRndItemTexture;
var Array<Mesh>					arRndItemMesh;
var config	int					nCurRndItemTxtIndex;
var config	float				fTextureAnyTime;
var config	float				fOlsTxtAnyTime;

var config	RandomBoxEffectMesh	RndEffectMesh;

var SephirothItem RndUseItem;
var string RndUseItemTypeName;
var int nSubInvenIndex;

var RandomBoxType.RandomBoxRecord	RndTypeRec;

var config	Texture ResultBgTexture;

struct init RandomBoxResInfo
{
	var String					ResName;
	var Vector					ResOffsetLoc;
	var Vector					ResOffsetRot;
	var float					ResSize;
};

var config	RandomBoxResInfo	BGInfo;
var config	RandomBoxResInfo	MeshInfo;

var int		CurrentItem;
var int		CurrentEffect;

var float	fTimeLine;
var float	fEffectTimeLine;
var float	fEffectStartTime;
var float	fHideTimeLine;
var float	fHideStartTime;
var int		nActorHideValue;
var float	fEffectHideValue;
var int		nEffectHideValue;

var Texture TexRndBoxHideEffect;

const BN_Close = 1;
const BN_RndOK = 2;
const BN_No=3;
const BN_Ok=4;
const IDS_ClanCreate = 100;
const IDM_ClanDelete = 101;

function OnInit()
{
	SetComponentTextureId(Components[2],1,-1,1,2);
	Components[2].NotifyId = BN_Close;

	SetComponentTextureId(Components[3],5,-1,7,6);
	SetComponentText(Components[3],"Ok");
	SetComponentNotify(Components[3],BN_Ok,Self);
	
	SetComponentTextureId(Components[4],5,-1,7,6);
	SetComponentText(Components[4],"Cancel");
	SetComponentNotify(Components[4],BN_No,Self);
}

function ShowInterface()
{
	local int nRecIndex;

	//nRecIndex = class'RandomBoxType'.Static.FindRndBoxRec(RndUseItem.TypeName, RndTypeRec);
	nRecIndex = class'RandomBoxType'.Static.FindRndBoxRec(RndUseItemTypeName, RndTypeRec);

	if( nRecIndex == -1 )
	{
		Parent.NotifyInterface(Self,INT_Close);
	}
	else
	{
		LoadResources(RndTypeRec);
		Super.ShowInterface();
	}
}

function OnFlush()
{
	local int i;
	if (RndModel != None) {
		RndModel.Destroy();
		RndModel = None;
	}

	if (ItemIconModel != None) {
		ItemIconModel.Destroy();
		ItemIconModel= None;
	}

	for (i=0;i<ArItemIconModel.Length;i++)
	{
		if(ArItemIconModel[i] != none)
		{
			ArItemIconModel[i].Destroy();
			ArItemIconModel[i] = None;
		}
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

function DrawRndItemText(Canvas C, string strItem, float X, float Y)
{
	if (strItem != "") {
		C.KTextFormat = ETextAlign.TA_MiddleCenter;
		C.DrawKoreanText(strItem, X, Y, 248, 19);
	}
}

function DrawModel(Canvas C)
{
	local vector CamPos,X,Y,Z;
	local rotator CamRot;
	local rotator CamRotResault;
	local byte  SavedAlpha;

	SavedAlpha = C.DrawColor.A;

	if (RndModel != None) {
		CamPos = PlayerOwner.Location;
		CamRot = PlayerOwner.Rotation;

		GetAxes(CamRot,X,Y,Z);
		CamRot = OrthoRotation(-X,-Y,Z);

		CamRotResault = CamRot;
		
		RndModel.SetRotation(CamRotResault);
		RndModel.SetLocation(CamPos + RndBoxModelRes.ResOffsetLoc.X * X + RndBoxModelRes.ResOffsetLoc.Y * Y + RndBoxModelRes.ResOffsetLoc.Z * Z);		// Xelloss

		if(arRndItemTexture.Length > 0 )
		{
			if(getItemTypeName == "" && arRndItemTexture[CurrentItem] != none)
			{
				RndModel.Skins[1] = arRndItemTexture[CurrentItem];
			}
			else if(getItemTypeTexture != none)
				RndModel.Skins[1] = getItemTypeTexture;
		}
		else if( ItemIconModel != none )
		{
			if(getItemTypeName == "" && arRndItemMesh[CurrentItem] != none)
			{
				if( ItemIconModel.Mesh == None )
				{
					if( nRndState < 3 )
						ItemIconModel.LinkMesh(arRndItemMesh[CurrentItem]);
				}
			}
			else if(getItemTypeMesh != none && ItemIconModel.Mesh == None && nRndState > 2)
			{
				ItemIconModel.LinkMesh(getItemTypeMesh);
				ItemIconModel.SetDrawScale(RndBoxItemListIconRes.ResResultSize);
			}
		}

		if( fHideTimeLine > 0 )
		{
			if (!RndModel.bStyleCreated) {
				RndModel.CreateStyle();
				if (RndModel.bStyleCreated)
					RndModel.AdjustColorStyle(class'Canvas'.static.MakeColor(127,127,127));
			}

			if (RndModel.bStyleCreated)
			{
				nActorHideValue = 255 - FClamp(fHideTimeLine / 3.0, 0.0, 1.0) * 255;
				RndModel.AdjustAlphaFade(nActorHideValue);
			}
		}

		C.DrawActor(RndModel, false, true, 90.0);
	}
	C.DrawColor.A = SavedAlpha;
}

function DrawSprite(Canvas C)
{
	local vector CamPos,X,Y,Z;
	local rotator CamRot;

	if (ImageSprite != None) {
		CamPos = PlayerOwner.Location;
		CamRot = PlayerOwner.Rotation;
		GetAxes(CamRot,X,Y,Z);
		ImageSprite.SetRotation(OrthoRotation(-X,-Y,Z));
		ImageSprite.SetLocation(CamPos + (RandMeshOffset.X-200) * X + RandMeshOffset.Y * Y + RandMeshOffset.Z * Z);		// Xelloss
		C.DrawActor(ImageSprite, false, false, 90.0);
	}
}

function OnPreRender(Canvas C)
{
	DrawBackGround3x3(C, 64, 64, 8, 9, 10, 11, 12, 13, 14, 15, 16);
}

function OnPostRender(HUD H, Canvas C)
{
	local byte  SavedAlpha;
	local int nEffectHideAlpha;
	local int nEffectHideRot;
	local float fEffectHideSize;
	local int nEffectCenterX,nEffectCenterY;
	local int nPosCenterX,nPosCenterY;
	local int nPosStartX,nPosStartY;
	local int nPosEndX,nPosEndY;
	local int nDrawSizeX,nDrawSizeY;
	local float OldClipX,OldClipY;

	DrawTitle(C, RandomBoxTitle);
	DrawModel(C);
	ProcessGauge(C, fRandGauge );
	DrawRndEffect(C);

	if(getItemTypeName != "" && nRndState >= 3 )
	{
		DrawRndItemText(C, getRndItemName,Components[RndBoxItemListTextRes.nComponentIndex].X, Components[RndBoxItemListTextRes.nComponentIndex].Y);
	}
	else
	{
		if(RndBoxItemListTextRes.ArrayItemList[CurrentItem] != "")
			DrawRndItemText(C, ArrayItemListText[CurrentItem],Components[RndBoxItemListTextRes.nComponentIndex].X, Components[RndBoxItemListTextRes.nComponentIndex].Y);
	}

	if( fEffectTimeLine <= 0.0 && fTimeLine > 0.0f )
		fEffectStartTime = Level.TimeSeconds;

	if( fHideTimeLine <= 0.0 && fTimeLine > 3.0f )
		fHideStartTime = Level.TimeSeconds;

	SavedAlpha = C.DrawColor.A;

	if( fEffectTimeLine > 0 )
	{
		nEffectHideRot = 0;

		if( fEffectTimeLine <= 1.0f )
		{
			nEffectHideAlpha = FClamp( fEffectTimeLine, 0.0, 1.0) * 255;
			fEffectHideSize = FClamp( fEffectTimeLine, 0.0, 1.0) * 8;
		}
		else
		{
			nEffectHideAlpha = 255 - (FClamp( (fEffectTimeLine-1.0f)/4.0, 0.0, 1.0) * 255);
			fEffectHideSize = 8;
		}
		nEffectCenterX = TexRndBoxHideEffect.USize*fEffectHideSize/2;
		nEffectCenterY = TexRndBoxHideEffect.VSize*fEffectHideSize/2;
		nPosCenterX = (Components[0].X+Components[0].XL/2)-nEffectCenterX;
		nPosCenterY = (Components[0].Y+Components[0].YL/2)-nEffectCenterY;

		nPosStartX = 0;
		nPosStartY = 0;

		nPosEndX = TexRndBoxHideEffect.USize;
		nPosEndY = TexRndBoxHideEffect.VSize;

		nDrawSizeX = TexRndBoxHideEffect.USize*fEffectHideSize;
		nDrawSizeY = TexRndBoxHideEffect.VSize*fEffectHideSize;

		if(nPosCenterX < Components[0].X)
		{
			nPosStartX = (Components[0].X-nPosCenterX)/fEffectHideSize;
			nPosCenterX = Components[0].X;
		}

		if(nPosCenterY < Components[0].Y)
		{
			nPosStartY = (Components[0].Y-nPosCenterY)/fEffectHideSize;
			nPosCenterY = Components[0].Y;
		}

		if( nDrawSizeX > Components[0].XL)
		{
			nPosEndX = TexRndBoxHideEffect.USize-(nPosStartX*2);
			nDrawSizeX = Components[0].XL;
		}

		if( nDrawSizeY > Components[0].YL)
		{
			nPosEndY = TexRndBoxHideEffect.VSize-(nPosStartY*2);
			nDrawSizeY = Components[0].YL;
		}

		C.SetPos(nPosCenterX, nPosCenterY);
		OldClipX = C.ClipX;
		OldClipY = C.ClipY;

		C.DrawColor.A = nEffectHideAlpha;
		C.DrawTile(TexRndBoxHideEffect,nDrawSizeX,nDrawSizeY,nPosStartX,nPosStartY,nPosEndX,nPosEndY);

		C.ClipX = OldClipX;
		C.ClipY = OldClipY;
	}
	C.DrawColor.A = SavedAlpha;
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Super.OnKeyEvent(Key,Action,Delta))
		return true;

	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if (NotifyId == BN_Close) {
		Parent.NotifyInterface(Self,INT_Close);
	}
	else if (NotifyId == BN_RndOK)
	{
		nRndState = 3;
		fRandGauge = fMaxGauge;
	}
	else if (NotifyId == BN_Ok)
	{
		Parent.NotifyInterface(Self,INT_Close);
	}
	else if (NotifyId == BN_No)
	{
		Parent.NotifyInterface(Self,INT_Close);
	}
}

function ProcessGauge(Canvas C, float fPer)
{
	local int OldItem;

	if( fRandGauge < fMaxGauge )
		fRandGauge = Level.TimeSeconds - fStartTime;

	if( (Level.TimeSeconds - fOlsTxtAnyTime) > AminIconTime[nRndState] )
	{
		OldItem = CurrentItem;
		CurrentItem++;
		if(CurrentItem >= RndBoxItemListIconRes.ArrayItemList.Length )
			CurrentItem = 0;

		ItemIconModel.LinkMesh( None );

		fOlsTxtAnyTime = Level.TimeSeconds;
	}

	CurrentEffect = nRndState;

	if( RndBoxSound[nRndState] != none )
		PlayerOwner.PlaySound(RndBoxSound[nRndState], SLOT_Misc,,true);

	if( fResultStartTime > 0)
	{
		fTimeLine = Level.TimeSeconds - fResultStartTime;
		if(fEffectStartTime > 0.0f)
			fEffectTimeLine = Level.TimeSeconds - fEffectStartTime;

		if(fHideStartTime > 0.0f)
			fHideTimeLine = Level.TimeSeconds - fHideStartTime;
	}
}

function DrawRndHideEffect(Canvas C)
{
	local vector CamPos,X,Y,Z;
	local rotator CamRot;

	CamPos = PlayerOwner.Location;
	CamRot = PlayerOwner.Rotation;
	GetAxes(CamRot,X,Y,Z);

	if(HideEffectSpriteRes != none)
	{
		HideEffectSpriteRes.SetRotation(OrthoRotation(-X,-Y,Z));
		HideEffectSpriteRes.SetLocation(CamPos + 150 * X + 0 * Y + 0 * Z);
		if( fEffectTimeLine <= 1.0f )
		{
			nEffectHideValue = FClamp( fEffectTimeLine, 0.0, 1.0) * 255;
			fEffectHideValue = FClamp( fEffectTimeLine, 0.0, 1.0) * 5.5;

			if (HideEffectSpriteRes.bStyleCreated)
				HideEffectSpriteRes.AdjustAlphaFade(nEffectHideValue);
		}
		else if( fEffectTimeLine <= 3.0f )
		{
		}
		else
		{
			nEffectHideValue = 255 - FClamp( fEffectTimeLine, 0.0, 1.0) * 255;

			if (HideEffectSpriteRes.bStyleCreated)
				HideEffectSpriteRes.AdjustAlphaFade(nEffectHideValue);
		}
		HideEffectSpriteRes.SetDrawScale(fEffectHideValue);
		C.DrawActorClipped(HideEffectSpriteRes,false, Components[0].X, Components[0].Y,Components[0].XL,Components[0].YL, true, 90.0);
	}

}

function DrawRndEffect(Canvas C)
{
	local vector CamPos,X,Y,Z;
	local rotator CamRot;
	local rotator CamRotEx;
	local vector EffectLoc;

	CamPos = PlayerOwner.Location;
	CamRot = PlayerOwner.Rotation;

	if(RndBoxEffectEmitterResClass[CurrentEffect] != none && RndBoxEffectEmitterRes[CurrentEffect] != none)
	{
		EffectLoc = CamPos;

		RndBoxEffectEmitterRes[CurrentEffect].SetLocation( EffectLoc );

		C.DrawActorClipped(RndBoxEffectEmitterRes[CurrentEffect],false, Components[0].X, Components[0].Y,Components[0].XL,Components[0].YL, true, 90.0);
	}
	else if(RndBoxEffectMeshRes[CurrentEffect] != none)
	{
		GetAxes(CamRot,X,Y,Z);
		CamRotEx = OrthoRotation(-X,-Y,Z);
		CamRotEx.Pitch += RndBoxEffectRes[CurrentEffect].ResOffsetRot.Pitch;
		CamRotEx.Yaw += RndBoxEffectRes[CurrentEffect].ResOffsetRot.Yaw;
		CamRotEx.Roll += RndBoxEffectRes[CurrentEffect].ResOffsetRot.Roll;
		RndBoxEffectMeshRes[CurrentEffect].SetRotation(CamRotEx);
		RndBoxEffectMeshRes[CurrentEffect].SetLocation(CamPos + RndBoxEffectRes[CurrentEffect].ResOffsetLoc.X * X + RndBoxEffectRes[CurrentEffect].ResOffsetLoc.Y * Y + RndBoxEffectRes[CurrentEffect].ResOffsetLoc.Z * Z);		// Xelloss

		C.DrawActorClipped(RndBoxEffectMeshRes[CurrentEffect],false, Components[0].X, Components[0].Y,Components[0].XL,Components[0].YL, true, 90.0);
	}
	else if(RndBoxEffectSpriteRes[CurrentEffect] != none)
	{
		CamRotEx = OrthoRotation(-X,-Y,Z);
		RndBoxEffectSpriteRes[CurrentEffect].SetRotation(OrthoRotation(-X,-Y,Z));
		RndBoxEffectSpriteRes[CurrentEffect].SetLocation(CamPos + RndBoxEffectRes[CurrentEffect].ResOffsetLoc.X * X + RndBoxEffectRes[CurrentEffect].ResOffsetLoc.Y * Y + RndBoxEffectRes[CurrentEffect].ResOffsetLoc.Z * Z);		// Xelloss

		C.DrawActorClipped(RndBoxEffectSpriteRes[CurrentEffect],false, Components[0].X, Components[0].Y,Components[0].XL,Components[0].YL, true, 90.0);
	}

}

function SetRndItem( SephirothItem SepItemInfo, optional int nSubIndex )
{
	RndUseItem = SepItemInfo;
	RndUseItemTypeName = RndUseItem.TypeName;
	nItemPosX = SepItemInfo.X;
	nItemPosY = SepItemInfo.Y;
	nSubInvenIndex = nSubIndex;
}

auto state RollingState
{
	simulated function timer()
	{
		local SephirothItem Item;

		if( RndModel == none )
		{
			Disable('Timer');
			return;
		}

		switch(nRndState)
		{
		case 0:
			if(RandomBoxTime[1] > 0.0f )
			{
				SetTimer(RandomBoxTime[1],false);
				if( RndBoxModelRes.RndMeshAnimName[1] != 'None')
					RndModel.LoopAnim(RndBoxModelRes.RndMeshAnimName[1],AminMeshTime[1]);
				nRndState = 1;
			}
			else if(RandomBoxTime[2] > 0.0f )
			{
				SetTimer(RandomBoxTime[2],false);
				if(RndBoxModelRes.RndMeshAnimName[2] != 'None')
					RndModel.LoopAnim(RndBoxModelRes.RndMeshAnimName[2],AminMeshTime[2]);
				nRndState = 2;
			}
			else
			{
				SetTimer(RandomBoxTime[0],false);
				if(RndBoxModelRes.RndMeshAnimName[0] != 'None')
					RndModel.LoopAnim(RndBoxModelRes.RndMeshAnimName[0],AminMeshTime[0]);
			}
			break;
		case 1:
			if(RandomBoxTime[2] > 0.0f )
			{
				SetTimer(RandomBoxTime[2],false);
				if(RndBoxModelRes.RndMeshAnimName[2] != 'None')
					RndModel.LoopAnim(RndBoxModelRes.RndMeshAnimName[2],AminMeshTime[2]);
				nRndState = 2;
			}
			else
			{
				SetTimer(RandomBoxTime[1],false);
				if(RndBoxModelRes.RndMeshAnimName[1] != 'None')
					RndModel.LoopAnim(RndBoxModelRes.RndMeshAnimName[1],AminMeshTime[1]);
			}
			break;
		case 2:
			if( getItemTypeName == "" && RandomBoxTime[3] > 0.0f )
			{
				if(nSubInvenIndex == -1)
					Item = SephirothPlayer(PlayerOwner).PSI.SepInventory.FindItemEx(RndUseItemTypeName);
				else
					Item = SephirothPlayer(PlayerOwner).PSI.SubInventories[(nSubInvenIndex-1)].FindItemEx(RndUseItemTypeName);
					
				if( Item != None )
				{
					if(nSubInvenIndex == -1)
						SephirothPlayer(PlayerOwner).Net.NotiCommand("ItemUse"@Item.X@Item.Y);
					else
						SephirothPlayer(PlayerOwner).Net.NotiCommand("ItemUseSub"@Item.X@Item.Y@nSubInvenIndex);
				}
				else
				{
					Disable('Timer');
					Parent.NotifyInterface(Self,INT_Close);
				}	
			}
		}	
	}
}

state GetItemState
{
	simulated function timer()
	{
		if( RndModel == none )
		{
			Disable('Timer');
			return;
		}
		switch(nRndState)
		{
		case 2:	
			// 실제 게임 아이템 출력..
			SetTimer(RandomBoxTime[3],false);
			nRndState = 3;
			ItemIconModel.LinkMesh( None );
			break;
		case 3:	
			// 실제 게임 아이템 출력..
			SetTimer(RandomBoxTime[4],false);
			if(RndBoxModelRes.RndMeshAnimName[4] != 'None')
				RndModel.LoopAnim(RndBoxModelRes.RndMeshAnimName[4],AminMeshTime[4]);
			nRndState = 4;
			if(ResultBgTexture == none)
				SetComponentTextureId(Components[RndBoxBGRes.nComponentIndex],4);
			else
				SetComponentTexture(Components[RndBoxBGRes.nComponentIndex],ResultBgTexture);
			break;
		case 4:
			Disable('Timer');
			nRndState = 4;
			Parent.NotifyInterface(Self,INT_Close);
			break;
		}	
	}
}

function vector PushComponentVector(int CmpId)
{
	local vector V;

	V.X = 0;
	V.Y = fRandGauge;
	V.Z = fMaxGauge;
	return V;
}

function LoadResources( RandomBoxType.RandomBoxRecord RndRec )
{
	local vector CamPos,X,Y,Z;
	local rotator CamRot;
	local int nRecIndex,i;
	local int nComponentIndex;
	local int nComponentTxtIndex;
	local string strResName;
	local SkeletalMesh RndSkMesh;

	nComponentIndex = Components.Length;
	nComponentTxtIndex = TextureResources.Length;

	CamPos = PlayerOwner.Location;
	CamRot = PlayerOwner.Rotation;
	GetAxes(CamRot,X,Y,Z);

	TotalTime = RndRec.TotalTime;
	fMaxGauge = TotalTime;

	for(i=0;i<5;i++)
	{
		RandomBoxTime[i] = RndRec.RndTime[i];
		AminMeshTime[i] = RndRec.AnimMeshSpeed[i];
		AminIconTime[i] = RndRec.AnimIconSpeed[i];
	}

	RandomBoxTitle = localize("RandBoxTitle", RndRec.RndBoxTitle, "RandBox");

	nRecIndex = class'RandomBoxType'.Static.LoadRndBoxRec( RndRec.BGImageName, RndBoxBGRes );
	if( nRecIndex != -1 && RndBoxBGRes.ResTypeName == "Component_Image" )
	{
		Components.Insert(Components.Length,1);
		nComponentIndex = Components.Length-1;
		TextureResources.Insert(TextureResources.Length,1);
		nComponentTxtIndex = TextureResources.Length-1;

		RndBoxBGRes.nComponentIndex = nComponentIndex;

		Components[nComponentIndex].Id = nComponentIndex;
		Components[nComponentIndex].Type = RES_Image;
		Components[nComponentIndex].ResId = nComponentTxtIndex;
		Components[nComponentIndex].XL = RndBoxBGRes.XL;
		Components[nComponentIndex].YL = RndBoxBGRes.YL;
		Components[nComponentIndex].PivotId = 0;
		Components[nComponentIndex].PivotDir = PVT_Copy;
		Components[nComponentIndex].OffsetXL= RndBoxBGRes.ResOffsetLoc.X;
		Components[nComponentIndex].OffsetYL= RndBoxBGRes.ResOffsetLoc.Y;

		TextureResources[nComponentTxtIndex].Package= RndBoxBGRes.ResPackageName;
		TextureResources[nComponentTxtIndex].Path= RndBoxBGRes.ResPathName;
		TextureResources[nComponentTxtIndex].Style= RndBoxBGRes.RenderStyle;

		if( RndBoxBGRes.SkinName != "" )
			ResultBgTexture = Texture(DynamicLoadObject(RndBoxBGRes.SkinName,class'Texture'));
		else
			ResultBgTexture = none;
	}
	
	nRecIndex = class'RandomBoxType'.Static.LoadRndBoxRec( RndRec.ItemListTextName, RndBoxItemListTextRes );
	if( nRecIndex != -1 && RndBoxItemListTextRes.ResTypeName == "ComponentText_List" )
	{
		for(i=0;i<RndBoxItemListTextRes.ArrayItemList.Length;i++)
			ArrayItemListText[i] = localize(RndRec.ItemListTextName, RndBoxItemListTextRes.ArrayItemList[i], "RandBox");
		Components.Insert(Components.Length,1);
		nComponentIndex = Components.Length-1;

		RndBoxItemListTextRes.nComponentIndex = nComponentIndex;

		Components[nComponentIndex].Id = nComponentIndex;
		Components[nComponentIndex].Type = RES_Text;
		Components[nComponentIndex].TextAlign = TA_MiddleCenter;
		Components[nComponentIndex].XL = RndBoxItemListTextRes.XL;
		Components[nComponentIndex].YL = RndBoxItemListTextRes.YL;
		Components[nComponentIndex].PivotId = 0;
		Components[nComponentIndex].PivotDir = PVT_Copy;
		Components[nComponentIndex].OffsetXL= RndBoxItemListTextRes.ResOffsetLoc.X;
		Components[nComponentIndex].OffsetYL= RndBoxItemListTextRes.ResOffsetLoc.Y;
		Components[nComponentIndex].TextColor=class'Canvas'.Static.MakeColor(255,255,255);
		Components[nComponentIndex].LocType = LCT_Terms;
		Components[nComponentIndex].Caption = ArrayItemListText[0];//localize(RndRec.RndBoxTitle, ArrayItemListText[0], "RandBox");
	}

	nRecIndex = class'RandomBoxType'.Static.LoadRndBoxRec(RndRec.MeshName, RndBoxModelRes);
	
	if (RndModel == None && nRecIndex != -1 && RndBoxModelRes.ResTypeName == "SkeletalMesh") {
		RndModel = Spawn(class<RandomboxModel>(DynamicLoadObject("SephirothUI.RandomboxModel", class'class')));
		if (RndModel != None) {
			strResName = RndBoxModelRes.ResPackageName$"."$RndBoxModelRes.ResPathName;
			RndSkMesh = SkeletalMesh(DynamicLoadObject(strResName, class'SkeletalMesh'));
			RndModel.LinkMesh(RndSkMesh);
			RndModel.bHidden = true;
			RndModel.SetCollision(false,false,false);
			RndModel.SetCollisionSize(0,0);
			RndModel.SetRotation(RndBoxModelRes.ResOffsetRot);

			RndModel.SetDrawScale(RndBoxModelRes.ResSize);
			RndModel.bUnlit = true;
			RndModel.SetDrawType(DT_Mesh);
			RndModel.CopySkinMaterialsToSkins();
			if(RndBoxModelRes.SkinName != "")
				RndModel.Skins[0] = Texture(DynamicLoadObject(RndBoxModelRes.SkinName,class'Texture'));
			RndBoxModelSkin = RndModel.Skins[0];

			RndModel.CreateStyle();

			if (RndModel.HasAnim(RndBoxModelRes.RndMeshAnimName[0]))
				RndModel.LoopAnim(RndBoxModelRes.RndMeshAnimName[0],AminMeshTime[0]);
			else
				RndModel.LoopAnim(RndBoxModelRes.RndMeshAnimName[1],AminMeshTime[1]);
		}
	}

	nRecIndex = class'RandomBoxType'.Static.LoadRndBoxRec(RndRec.ItemListIconName, RndBoxItemListIconRes);
	if( nRecIndex != -1 && RndBoxItemListIconRes.ResTypeName == "Image_List" )
	{
		for(i=0;i<RndBoxItemListIconRes.ArrayItemList.Length;i++)
		{
			arRndItemTexture[i] = Texture(DynamicLoadObject(RndBoxItemListIconRes.ArrayItemList[i],class'Texture'));
			arRndItemTexture[i].bAlphaTexture = true;
		}
	}
	else if( nRecIndex != -1 && RndBoxItemListIconRes.ResTypeName == "Mesh_List" )
	{
		ItemIconModel = Spawn(class<RandomboxModel>(DynamicLoadObject("SephirothUI.RandomboxModel", class'class')));
		RndModel.AttachToBone(ItemIconModel,'Dummy01');
		for(i=0;i<RndBoxItemListIconRes.ArrayItemList.Length;i++)
		{
			ArItemIconModel[i] = Spawn(class<RandomboxModel>(DynamicLoadObject("SephirothUI.RandomboxModel", class'class')));
			arRndItemMesh[i] = SkeletalMesh(DynamicLoadObject(RndBoxItemListIconRes.ArrayItemList[i], class'SkeletalMesh'));

			//ArItemIconModel[i].SetDrawScale(0.8);
			ArItemIconModel[i].LinkMesh(arRndItemMesh[i]);
		}
		ItemIconModel.SetDrawScale(RndBoxItemListIconRes.ResSize);
		ItemIconModel.LinkMesh(arRndItemMesh[0]);
	}

	nRecIndex = class'RandomBoxType'.Static.LoadRndBoxRec( RndRec.GaugeImageName, RndBoxGaugeRes );
	if( nRecIndex != -1 && RndBoxGaugeRes.ResTypeName == "Component_Gauge" )
	{
		Components.Insert(Components.Length,1);
		nComponentIndex = Components.Length-1;
		TextureResources.Insert(TextureResources.Length,1);
		nComponentTxtIndex = TextureResources.Length-1;

		RndBoxItemListTextRes.nComponentIndex = nComponentIndex;

		Components[nComponentIndex].Id = nComponentIndex;
		Components[nComponentIndex].Type = RES_Gauge;
		Components[nComponentIndex].ResId = nComponentTxtIndex;
		Components[nComponentIndex].XL = RndBoxGaugeRes.XL;
		Components[nComponentIndex].YL = RndBoxGaugeRes.YL;
		Components[nComponentIndex].OffsetXL= RndBoxGaugeRes.ResOffsetLoc.X;
		Components[nComponentIndex].OffsetYL= RndBoxGaugeRes.ResOffsetLoc.Y;
		Components[nComponentIndex].PivotId = 0;
		Components[nComponentIndex].PivotDir = PVT_Copy;
		Components[nComponentIndex].GaugeDir = GDT_Right;
		Components[nComponentIndex].bTextureSegment = true;

		TextureResources[nComponentTxtIndex].Package= RndBoxGaugeRes.ResPackageName;
		TextureResources[nComponentTxtIndex].Path= RndBoxGaugeRes.ResPathName;
		TextureResources[nComponentTxtIndex].Style= RndBoxGaugeRes.RenderStyle;
		TextureResources[nComponentTxtIndex].U = RndBoxGaugeRes.U;
		TextureResources[nComponentTxtIndex].V = RndBoxGaugeRes.V;
		TextureResources[nComponentTxtIndex].UL = RndBoxGaugeRes.UL;
		TextureResources[nComponentTxtIndex].VL = RndBoxGaugeRes.VL;
	}

	RndBoxGaugeColor[0] = RndRec.GaugeColor[0];
	RndBoxGaugeColor[1] = RndRec.GaugeColor[1];
	RndBoxGaugeColor[2] = RndRec.GaugeColor[2];

	for(i=0;i<5;i++)
	{
		nRecIndex = class'RandomBoxType'.Static.LoadRndBoxRec(RndRec.EffectName[i], RndBoxEffectRes[i]);
		if( nRecIndex != -1 )
		{
			if(RndBoxEffectRes[i].ResTypeName == "EmitterEffect")
			{
				strResName = RndBoxEffectRes[i].ResPackageName$"."$RndBoxEffectRes[i].ResPathName;
				RndBoxEffectEmitterResClass[i] = class<xEmitter>(DynamicLoadObject(strResName, class'class'));
				RndBoxEffectEmitterRes[i] = RndModel.spawn(RndBoxEffectEmitterResClass[i]);
				if (RndBoxEffectEmitterRes[i] != None) {
					RndBoxEffectEmitterRes[i].SetCollision(false,false,false);
					RndBoxEffectEmitterRes[i].SetCollisionSize(0,0);
					RndBoxEffectEmitterRes[i].SetRotation(rot(0,0,0));
					RndBoxEffectEmitterRes[i].SetDrawScale(RndBoxEffectRes[i].ResSize);
					RndBoxEffectEmitterRes[i].bUnlit = true;

					RndBoxEffectEmitterRes[i].SetBase(RndModel);
				}
			}
			else if(RndBoxEffectRes[i].ResTypeName == "StaticMeshEffect")
			{
				strResName = RndBoxEffectRes[i].ResPackageName$"."$RndBoxEffectRes[i].ResPathName;
				RndBoxEffectMeshRes[i] = Spawn(class<RandomBoxEffectMesh>(DynamicLoadObject("SephirothUI.RandomBoxEffectMesh", class'class')));
				if (RndBoxEffectMeshRes[i] != None)
				{
					
					RndBoxEffectMeshRes[i].SetStaticMesh(StaticMesh(DynamicLoadObject(strResName, class'StaticMesh')));
					RndBoxEffectMeshRes[i].bHidden = true;
					RndBoxEffectMeshRes[i].SetCollision(false,false,false);
					RndBoxEffectMeshRes[i].SetCollisionSize(0,0);
					RndBoxEffectMeshRes[i].SetRotation(rot(0,0,0));
					RndBoxEffectMeshRes[i].SetDrawScale(RndBoxEffectRes[i].ResSize);
					RndBoxEffectMeshRes[i].bUnlit = true;
				}
			}
			else if(RndBoxEffectRes[i].ResTypeName == "ImageEffect")
			{
				strResName = RndBoxEffectRes[i].ResPackageName$"."$RndBoxEffectRes[i].ResPathName;
				RndBoxEffectSpriteRes[i] = Spawn(class<RandomBoxSprite>(DynamicLoadObject("SephirothUI.RandomBoxSprite", class'class')));
				if (RndBoxEffectSpriteRes[i] != None)
				{
					RndBoxEffectSpriteRes[i].Texture = Texture(DynamicLoadObject(strResName,class'Texture'));
					RndBoxEffectSpriteRes[i].bHidden = true;
					RndBoxEffectSpriteRes[i].SetCollision(false,false,false);
					RndBoxEffectSpriteRes[i].SetCollisionSize(0,0);
					RndBoxEffectSpriteRes[i].SetRotation(rot(0,0,0));
					RndBoxEffectSpriteRes[i].SetDrawScale(RndBoxEffectRes[i].ResSize);
					RndBoxEffectSpriteRes[i].bUnlit = true;
				}
			}
		}
	}

	HideEffectSpriteRes = Spawn(class<RandomBoxEffectMesh>(DynamicLoadObject("SephirothUI.RandomBoxEffectMesh", class'class')));
	if (HideEffectSpriteRes != None)
	{
		HideEffectSpriteRes.SetStaticMesh(StaticMesh(DynamicLoadObject("BG_SellEffect_ST.RB_01_Open", class'StaticMesh')));
		HideEffectSpriteRes.bHidden = true;
		HideEffectSpriteRes.SetCollision(false,false,false);
		HideEffectSpriteRes.SetCollisionSize(0,0);
		HideEffectSpriteRes.SetDrawScale(1.0);
		HideEffectSpriteRes.bUnlit = true;

		if (!HideEffectSpriteRes.bStyleCreated) {
			HideEffectSpriteRes.CreateStyle();
			if (HideEffectSpriteRes.bStyleCreated)
				HideEffectSpriteRes.AdjustColorStyle(class'Canvas'.static.MakeColor(127,127,127));
		}
	}
	

	RndBoxSound[0] = Sound(DynamicLoadObject(RndRec.SoundName[0],class'Sound'));
	RndBoxSound[1] = Sound(DynamicLoadObject(RndRec.SoundName[1],class'Sound'));
	RndBoxSound[2] = Sound(DynamicLoadObject(RndRec.SoundName[2],class'Sound'));
	RndBoxSound[3] = Sound(DynamicLoadObject(RndRec.SoundName[3],class'Sound'));
	RndBoxSound[4] = Sound(DynamicLoadObject(RndRec.SoundName[4],class'Sound'));

	bPlaySound[0] = 0;
	bPlaySound[1] = 0;
	bPlaySound[2] = 0;
	bPlaySound[3] = 0;
	bPlaySound[4] = 0;

	getItemTypeName = "";
	getItemTypeTexture = none;
	getRndItemName = "";
	getItemTypeMesh = none;

	if(RandomBoxTime[0] > 0.0f )
	{
		SetTimer(RandomBoxTime[0],false);
		RndModel.LoopAnim(RndBoxModelRes.RndMeshAnimName[0],AminMeshTime[0]);
		nRndState = 0;
	}
	else
	{
		SetTimer(RandomBoxTime[1],false);
		RndModel.LoopAnim(RndBoxModelRes.RndMeshAnimName[1],AminMeshTime[1]);
		nRndState = 1;

	}

	TexRndBoxHideEffect.bAlphaTexture = true;

	fStartTime = Level.TimeSeconds;
	fResultStartTime = 0.0f;
	fTimeLine = 0.0;
	fEffectTimeLine = 0.0f;
	fHideTimeLine = 0.0f;
	nActorHideValue = 255;
	fEffectHideValue = 0.0f;
	nEffectHideValue = 0;
}

function ResultRandombox( string strTypeName, string strModelName, string LocalizedDescription )
{
	local SephirothItem Item;
	local string ResultModelName;
	local int i;

	Item = new(None) class'SephirothItem';

	Item.TypeName = strTypeName;
	Item.ModelName = strModelName;
	Item.LocalizedDescription = LocalizedDescription;

	getItemTypeName = strTypeName;
	if(arRndItemTexture.Length > 0)
	{
		getItemTypeTexture = Texture(Item.GetMaterial(SephirothPlayer(PlayerOwner).PSI));
		getItemTypeTexture.bAlphaTexture = true;
	}
	else
	{
		class'ModelCache'.static.GetMeshName(Item.ModelName, ResultModelName );
		getItemTypeMesh = SkeletalMesh(DynamicLoadObject(ResultModelName, class'SkeletalMesh'));

		if(getItemTypeMesh == None)
		{
			for(i=0;i<RndBoxItemListIconRes.ArrayItemList.Length;i++)
			{
				if( InStr( RndBoxItemListIconRes.ArrayItemList[i], strModelName) != -1 )
				{
					getItemTypeMesh = arRndItemMesh[i];
					break;
				}
			}
		}
	}
	getRndItemName = Item.LocalizedDescription;

	if(RndBoxModelRes.RndMeshAnimName[3] != 'None')
		RndModel.PlayAnim(RndBoxModelRes.RndMeshAnimName[3],AminMeshTime[3]);
	ItemIconModel.LinkMesh( None );
	nRndState = 2;
	SetTimer(1.0,false);
	GotoState('GetItemState');

	fResultStartTime = Level.TimeSeconds;

	Item = none;
}

defaultproperties
{
     RandMeshOffset=(X=550.000000,Z=100.000000)
     fMaxGauge=6.000000
     nCurRndItemTxtIndex=1
     fTextureAnyTime=0.200000
     nSubInvenIndex=-1
     TexRndBoxHideEffect=Texture'BG_SellEffect_T.Sell_Lighting02'
     Components(0)=(XL=390.000000,YL=370.000000)
     Components(2)=(Id=2,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=354.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="Close Random Box")
     Components(3)=(Id=3,Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=31.000000,OffsetYL=325.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(4)=(Id=4,Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=247.000000,OffsetYL=325.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     TextureResources(0)=(Package="RandomBox_UI",Path="RB_Window",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(4)=(Package="RandomBox_UI",Path="RB_01_bg_01",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_brw_l_n",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="btn_brw_l_o",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011_btn",Path="btn_brw_l_c",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
}
