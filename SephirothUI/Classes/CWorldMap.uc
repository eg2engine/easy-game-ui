class CWorldMap extends CMultiInterface
	config(SephirothUI);

const TexSize = 512;
const MapSize = 65024;
const Radius = 64;


const BTN_EXIT = 1;
const BTN_ZONE = 2;
const BTN_ZONE_LIST = 3;
const CB_ShowZoneName = 4;
const BTN_NPCSearch = 5;
const BTN_ALPHA = 8;

const max_Components = 13;		// �� ���۳�Ʈ ����

const BTN_LA   = 100;
const BTN_VE   = 101;
const BTN_LAE  = 102;

var Texture txDlg;				// ���� ������ �ؽ���

var Texture txLadianes;			// ���Ƴ׽�
var Texture txLadianesEast;		// ���Ƴ׽� ����
var Texture txVeros;			// ���ν�

const iNone			= -1;
const iLadianes		= 0;
const iVeros		= 1;
const iLadianesEast	= 2;

var float PageX,PageY;

const MapTexOffsetX = 11;	//�⺻ �����ӿ��� ����� �ؽ��İ� �׷����� ��ġ ������. sinhyub
const MapTexOffsetY = 65;

var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

var string sTitle;

var string sSelectedZone;
var bool bOpenZoneList;

var bool bShowZoneName;

const MAX_ALPHA_CNT = 5;
var int nAlphaCount;			// ���İ�	//modified by yj Config�� ����
var int nZoomCount;				// �ܰ�
var int bAlphaDir;				// ���İ��� Ŀ���� �� (0) or �۾����� �� (1)
var int nPointAlpha;			// ��â�� ����� ����Ʈ�� ���� (������ ȿ���� ���� ����)

var CImeEdit NameEdit;
var string SearchNpcName;

var int nViewMapInx;			// ������ ���� �ִ� ����
var int nUserMapInx;			// ������ ���� �ִ� ���� (-1 ���� 0 ���Ƴ׽� 1 ���ν� 2~ ��Ÿ)
var int nUserSaveInx;			// ������ ó�� â�� ���� �� �ִ� ����


var CPositionData PosData;
var bool bOnOpenEditBox;		// NPC ã�� ������ �ڽ� on / off
var bool bOnNPC;				// NPC ǥ�� on / off
var int nNPCX;					// NPC ǥ�ÿ� ��ǥ
var int nNPCY;					// NPC ǥ�ÿ� ��ǥ
var string sNPCName;			// NPC �̸�


var bool bOnSMode;				// �������̽� ���������� ���

//-------------------modified by yj  ���İ� ����
var CSlide AlphaSlide;
var float AlphaSpeed;
var int AlphaTick;
var int AlphaTick_;


var array<Texture> DynamicTextures;

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

function OnInit()
{
	Components[1].NotifyId = BTN_EXIT;
	Components[2].NotifyId = BTN_ZONE;
	Components[3].NotifyId = BTN_NPCSearch;
	SetComponentNotify(Components[4], CB_ShowZoneName, Self);
	Components[4].bDisabled = true;
	Components[5].NotifyId = BTN_ZONE_LIST;

//	Components[8].NotifyId = BTN_ALPHA;

	Components[10].NotifyId = BTN_LA;
	Components[11].NotifyId = BTN_VE;
	Components[12].NotifyId = BTN_LAE;


	SetComponentTextureId(Components[1], 1,-1, 3, 2);	// x 
	SetComponentTextureId(Components[2],4,-1,6,5);	// ���� ����Ʈ
	SetComponentTextureId(Components[3],19,-1,21,20);	// npc ã��
//	SetComponentTextureId(Components[8],16,-1,18,17);	// ����

	SetComponentTextureId(Components[10],0,-1,0,0);	// ���� ����
	SetComponentTextureId(Components[11],0,-1,0,0);	// ���� ����
	SetComponentTextureId(Components[12],0,-1,0,0);	// ���� ����

	NameEdit = CImeEdit(AddInterface("Interface.CImeEdit"));

	if (NameEdit != None)
	{
		NameEdit.bNative = True;
		NameEdit.SetMaxWidth(20);
		NameEdit.SetSize(141,14);
		NameEdit.SetFocusEditBox(false);
		NameEdit.ShowInterface();
	}

	AlphaSlide = CSlide(AddInterface("Interface.CSlide"));
	if(AlphaSlide != None)
	{
		AlphaSlide.ShowInterface();
		AlphaSlide.SetSlide(Components[0].X, Components[0].Y, Components[7].XL, Components[7].YL, 0, nAlphaCount, MAX_ALPHA_CNT);
	}

	if(PageX == -1)
		ResetDefaultPosition();
	bMovingUI = true;	//Layout()���� â���� ��� UI�� üũ���ټ��ֵ����մϴ�. 2009.10.29.Sinhyub

	txDlg = Texture(DynamicLoadObject("UI_2011.world_win_info",class'Texture'));
	txLadianes = Texture(DynamicLoadObject("WorldMap.LadianesKOR",class'Texture'));
	txVeros = Texture(DynamicLoadObject("WorldMap.VerosKOR",class'Texture'));
	txLadianesEast = Texture(DynamicLoadObject("WorldMap.LadianesEastKOR",class'Texture'));

	sTitle = Localize("CWorldMap","Title","SephirothUI");

	if(PosData == None)
	{
		//PosData = spawn(class'CPositionData', self);
		PosData = new(None) class'CPositionData';
		PosData.Load();
	}
}

function OnFlush()
{
	FlushDynamicTextures();

	if(AlphaSlide != None)
	{
		RemoveInterface(AlphaSlide);
		AlphaSlide = None;
	}

	if (NameEdit != None) {
		NameEdit.SetFocusEditBox(false);
		NameEdit.HideInterface();
		RemoveInterface(NameEdit);
		NameEdit = None;
	}

	EmptyComboBox(Components[5]);

	SaveConfig();
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Key == IK_LeftMouse)
	{
		if ((Action == IST_Press))
		{
			if (IsCursorInsideComponent(Components[6]) && !NameEdit.HasFocus())
			{
				NameEdit.SetFocusEditBox(true);
				return true;
			}
			else if (!IsCursorInsideComponent(Components[6]) && NameEdit.HasFocus())
			{
				NameEdit.SetFocusEditBox(false);
				return true;
			}
/*
			if(IsCursorInsideComponent(Components[7])) // �����̵� ������ ���� ���
			{
				if(Components[8].bMousePress)
				{
					Components[8].X = Controller.MouseX;	// ���콺 ��ġ�� ���� �����̵� ��ư�� �̵�
					if(Components[8].X < Components[7].X)
						Components[8].X = Components[7].X;

					if(Components[8].X > Components[7].X + Components[7].XL)
						Components[8].X = Components[7].X + Components[7].XL;
					Components[8].Y = Components[7].Y;
				}
				return true;
			}
*/
			if(IsCursorInsideComponent(Components[0]))
			{
				bMovingUI = true;
				bIsDragging = true;			
				DragOffsetX = Controller.MouseX - PageX;
				DragOffsetY = Controller.MouseY - PageY;
				return true;
			}
		}
		if (Action == IST_Release && bIsDragging) {
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			return true;
		}
	}

}

function Layout(Canvas C)
{
	local int i;
	local int DX,DY;

	if(bMovingUI) {
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
			bMovingUI = false;
		}
	}
	MoveComponentId(0, true, PageX, PageY, Components[0].XL, Components[0].YL);

	// ��ư�� ��ġ, ��Ÿ �׸� ��ġ
	for(i=0; i<max_Components; i++)
		MoveComponentId(i, false);
/*
	if(	Components[8].Y != Components[7].Y)
		Components[8].Y = Components[7].Y;
	if(Components[8].X < Components[7].X)
		Components[8].X = Components[7].X;

	if(Components[8].X > Components[7].X + Components[7].XL)
		Components[8].X = Components[7].X + Components[7].XL;
*/

	AlphaSlide.SetPos(Components[7].X, Components[7].Y);

	if (NameEdit != None)
		NameEdit.SetPos(Components[6].X, Components[6].Y);
}

event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	if (!IsCursorInsideComponent(Components[0]))
		return;

	nAlphaCount =  AlphaSlide.GetSlideRate() * MAX_ALPHA_CNT;
/*
	if (Components[4].bMousePress && IsCursorInsideComponent(Components[4])) 	{
		AlphaTick_++;
		if(AlphaTick_ >= 20) {
			AlphaTick++;
			if (AlphaTick >= 1.0f / AlphaSpeed) {
				nAlphaCount = Clamp(nAlphaCount+1,0,5);
				AlphaTick = 0;
			}
		}
	}
	else if (Components[5].bMousePress && IsCursorInsideComponent(Components[5])) {
		AlphaTick_++;
		if(AlphaTick_ >= 20) {
			AlphaTick++;
			if (AlphaTick >= 1.0f / AlphaSpeed) {
				nAlphaCount = Clamp(nAlphaCount-1,0,5);
				AlphaTick = 0;
			}
		}
	}
	else 
		AlphaTick_ = 0;		//��.. tick���� ��� �̷��� �ε尡 ū��..
*/
}	

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch (NotifyId) 
	{
	case BTN_EXIT:
		Parent.NotifyInterface(Self,INT_Close);
		break;

	case BTN_ZONE:
		bOpenZoneList = !bOpenZoneList;
		break;

	case BTN_ZONE_LIST:
		//GetComponentText(Components[2]);
		break;

	case CB_ShowZoneName:
		if(Command == "Checked")
			bShowZoneName = true;
		else
			bShowZoneName = false;
		break;

	case BTN_NPCSearch:
		if(FindNPC(SearchNpcName) == false)
			AddMessage(1, Localize("Information","NotFindNPC","Sephiroth"), class'Canvas'.static.MakeColor(255,255,0));
		break;

	case BTN_LA:
		nViewMapInx = iLadianes;       // ������ �� �ε����� ���Ƴ׽���
		nZoomCount = 1;
		bOpenZoneList = false;
		break;

	case BTN_VE:
		nViewMapInx = iVeros;       // ������ �� �ε����� ���ν��� 
		nZoomCount = 1;
		bOpenZoneList = false;
		break;

	case BTN_LAE:
		nViewMapInx = iLadianesEast;       // ������ �� �ε����� ���Ƴ׽� ���� 
		nZoomCount = 1;
		bOpenZoneList = false;
		break;
	}
}

function bool PointCheck()
{
	return IsCursorInsideComponent(Components[0]);
}

function OnPreRender(Canvas C)
{
	local float fPX, fPY; // ����ʿ� ǥ�õ� �÷��̾��� x, y
	local float fNX, fNY; // ����ʿ� ǥ�õ� NPC�� x, y
	local color OldColor;
/*
	if (bool(ConsoleCommand("GETOPTIONI PinMinimap")))
	{
		Yaw = 0;
		Components[9].Rotation = PlayerOwner.Pawn.Rotation.Yaw + 16384;
	}
	else
	{
		Yaw = -PlayerOwner.Rotation.Yaw - 16384;
		Components[9].Rotation = PlayerOwner.Pawn.Rotation.Yaw + 16384;
	}
*/

	if(bOpenZoneList)
	{
		VisibleComponent(Components[10], true);
		VisibleComponent(Components[11], true);
		VisibleComponent(Components[12], true);
	}
	else
	{
		VisibleComponent(Components[10], false);
		VisibleComponent(Components[11], false);
		VisibleComponent(Components[12], false);
	}


	SearchNpcName = NameEdit.GetText();

	// ���⼭ �ȱ׸��� �ٸ� �������̽����� ���������� (��ư�鵵) ----------

	// ���� ������
	OldColor = C.DrawColor;
	C.DrawColor.A = 155 + (nAlphaCount*20);

	DrawBackGround3x3(C, 64, 64, 7, 8, 9, 10, 11, 12, 13, 14, 15);

	C.DrawTileAlphaArea(txDlg, PageX+20, PageY+36, 494, 24, 0, 0, 494, 24);

	// ���� �����̰� ------------------------------------------------------
	if(bAlphaDir == 1)
	{
		if(nPointAlpha > 155)
			nPointAlpha -= 10;
		else		
			bAlphaDir = 0;
	}
	else
	{
		if(nPointAlpha < 255)
			nPointAlpha += 10;
		else
			bAlphaDir = 1;
	}
	//---------------------------------------------------------------------

	// �� �׸���
	CheckUserArea(); // ���� ������ ��� ������ �ִ��� üũ

	switch(nViewMapInx)
	{
	case iLadianes: // ���Ƴ׽�
		fPX = ((PlayerOwner.Pawn.Location.X+40*MapSize)/100 - 22120)/(3050/512);
		fPY = ((PlayerOwner.Pawn.Location.Y+40*MapSize)/100 - 33810)/(2580/512);
		//C.DrawTileAlphaArea(txLadianes, PageX+MapTexOffsetX, PageY+MapTexOffsetY, 512, 512, 0, 0, 2048, 2048);
		C.DrawTileAlphaArea(txLadianes, PageX+MapTexOffsetX, PageY+MapTexOffsetY, 512, 512, 0, 0, 512, 512);
		if(nUserMapInx == nViewMapInx) // ���� �����ϰ� �ִ� ������ ��ġ�ϸ� �÷��̾� ǥ��
		{ 
			C.SetDrawColor(0,nPointAlpha,0);
			//C.SetPos(PageX+MapTexOffsetX+fPX-3, PageY+MapTexOffsetY+fPY-3); // Y �� - 5�� �׳� ����ġ;; �� �ȸ¾Ƽ�
			MoveComponentId(9, true, PageX+MapTexOffsetX+fPX-16, PageY+MapTexOffsetY+fPY-16, Components[9].XL, Components[9].YL);
			Components[9].bVisible = true;	//�÷��̾� ��ġ ǥ��
		}
		else
			Components[9].bVisible = false;

		if(bOnNPC == true)
		{ 
			fNX = ((nNPCX+40*MapSize)/100 - 22120)/(3050/512);
			fNY = ((nNPCY+40*MapSize)/100 - 33810)/(2580/512);

			C.SetDrawColor(nPointAlpha,255,255);
			C.SetPos(PageX+MapTexOffsetX+fNX-4, PageY+MapTexOffsetY+fNY-4);
			C.DrawTile(TextureResources[23].Resource,8,8,0,0,8,8);
		}
		break; 

	case iVeros: // ���ν�
		fPX = ((PlayerOwner.Pawn.Location.X+40*MapSize)/100 - 20820)/(3050/512);
		fPY = ((PlayerOwner.Pawn.Location.Y+40*MapSize)/100 - 24730)/(2580/512);
		//C.DrawTileAlphaArea(txVeros, PageX+MapTexOffsetX, PageY+MapTexOffsetY, 512, 512, 0, 0, 2048, 2048);
		C.DrawTileAlphaArea(txVeros, PageX+MapTexOffsetX, PageY+MapTexOffsetY, 512, 512, 0, 0, 512, 512);
		if(nUserMapInx == nViewMapInx)	// ���� �����ϰ� �ִ� ������ ��ġ�ϸ� �÷��̾� ǥ��
		{
			C.SetDrawColor(0,nPointAlpha,0);
			//C.SetPos(PageX+MapTexOffsetX+fPX, PageY+MapTexOffsetY+fPY); //�̰��ʿ���°Ű����� sinhyub
			MoveComponentId(9, true, PageX+MapTexOffsetX+fPX-16, PageY+MapTexOffsetY+fPY-16, Components[9].XL, Components[9].YL);
			Components[9].bVisible = true;		//make the component visiable, "explicitly". -2009.10.9.Sinhyub
		}
		else
			Components[9].bVisible = false;		//do not forget make visiable, "explicitly".

		if(bOnNPC == true)
		{ 
			fNX = ((nNPCX+40*MapSize)/100 - 20820)/(3050/512);
			fNY = ((nNPCY+40*MapSize)/100 - 24730)/(2580/512);

			C.SetDrawColor(nPointAlpha,255,255);
			C.SetPos(PageX+MapTexOffsetX+fNX-4, PageY+MapTexOffsetY+fNY-4);
			C.DrawTile(TextureResources[23].Resource,8,8,0,0,8,8);
		}
		break;

	case iLadianesEast:
		fPX = ((PlayerOwner.Pawn.Location.X+40*MapSize)/100 - 24680)/(3050/512);
		fPY = ((PlayerOwner.Pawn.Location.Y+40*MapSize)/100 - 33810)/(2580/512);

		C.DrawTileAlphaArea(txLadianesEast, PageX+MapTexOffsetX, PageY+MapTexOffsetY, 512, 512, 0, 0, 512, 512);
		if(nUserMapInx == nViewMapInx)	//���� �����ϰ� �ִ� ������ ��ġ�ϸ� �÷��̾� ǥ��
		{
			C.SetDrawColor(0,nPointAlpha,0);
			//C.SetPos(PageX+MapTexOffsetX+fPX, PageY+MapTexOffsetY+fPY);	�̰� �ʿ���°Ű�����
			MoveComponentId(9, true, PageX+MapTexOffsetX+fPX-16, PageY+MapTexOffsetY+fPY-16, Components[9].XL, Components[9].YL);//PageX+13+fPX-8, PageY+47+fPY-8, Components[9].XL, Components[9].YL);
			Components[9].bVisible = true;
		}
		else
			Components[9].bVisible = false;

		if(bOnNPC == true)
		{ 
			fNX = ((nNPCX+40*MapSize)/100 - 24680)/(3050/512);
			fNY = ((nNPCY+40*MapSize)/100 - 33810)/(2580/512);

			C.SetDrawColor(nPointAlpha,255,255);
			C.SetPos(PageX+MapTexOffsetX+fNX-4, PageY+MapTexOffsetY+fNY-4);
			C.DrawTile(TextureResources[23].Resource,8,8,0,0,8,8);
			//C.DrawRect1Fix(5, 5); //NPC ��ġ ǥ��
		}
		break;
	}

	C.DrawColor = OldColor;
	//C.DrawColor.A = 255;
	C.DrawColor.A = 155 + (nAlphaCount*20);
	//---------------------------------------------------------------------


	if(bOpenZoneList)
	{
//		C.SetPos();
//		C.DrawTile(TextureResources[0].Resource, 124, 14, 0, 0, 16, 16)

//		C.SetPos(Components[10].X, Components[10].Y);
//		C.DrawKoreanText("���Ƴ׽�", Components[10].X, Components[10].Y, Components[10].XL, Components[10].YL);

	}

	Components[9].Rotation = PlayerOwner.Pawn.Rotation.Yaw + 16384;
}

function OnPostRender(HUD H, Canvas C)
{
	local color OldColor;
	local int i, temp;
//	local Creature Creature;
//	local vector Loc;
	local float fNX,fNY;
	local float fMapStartX, fMapStartY;
	local int nLocalNpcX,nLocalNpcY;

	OldColor = C.DrawColor;

	C.DrawColor.A = 255;

	C.SetRenderStyleAlpha();

	GetMapStartXY(nViewMapInx, fMapStartX, fMapStartY);

	C.DrawColor.A = nPointAlpha;
/*
	for (i=0;i<GameManager(Level.Game).Creatures.Length;i++)
	{
		Creature = GameManager(Level.Game).Creatures[i];
		if (Creature != None && !Creature.bDeleteMe)
		{
			if (Creature.IsA('Npc'))
			{
				if(Creature.nSymbol == 0)
					continue;
//				//Log("neive : check creature loc " $ Creature.Location.X $ " / " $ Creature.Location.Y );
				//Loc = (Creature.Location - PlayerOwner.Pawn.Location);
				fNX = ((Creature.Location.X+40*MapSize)/100 - fMapStartX)/(3050/512);
				fNY = ((Creature.Location.Y+40*MapSize)/100 - fMapStartY)/(2580/512);
				//Log("neive : check creature fN " $ fNX $ " / " $ fNY );
				//C.SetPos(Center.X + Loc.X, Center.Y + Loc.Y);
				C.SetPos(PageX+MapTexOffsetX+fNX-5, PageY+MapTexOffsetY+fNY-8);
				switch(Creature.nSymbol)
				{
				case 1: C.DrawTile(TextureResources[24].Resource,11,16,0,0,11,16); break;
				case 2: C.DrawTile(TextureResources[25].Resource,11,16,0,0,11,16); break;
				case 3: C.DrawTile(TextureResources[26].Resource,11,16,0,0,11,16); break;
				case 4: C.DrawTile(TextureResources[27].Resource,11,16,0,0,11,16); break;
				case 5: C.DrawTile(TextureResources[28].Resource,11,16,0,0,11,16); break;
				case 6: C.DrawTile(TextureResources[29].Resource,11,16,0,0,11,16); break;
				}
			}
		}
	}
*/

	for(i=0; i<SephirothPlayer(PlayerOwner).LiveQuests.Length; i++)
	{
		//if(FindNPC(SephirothPlayer(PlayerOwner).LiveQuests[i].strLocaleName, true, nLocalNpcX, nLocalNpcY))
		if(GetNPC(SephirothPlayer(PlayerOwner).LiveQuests[i].strLocaleName, true, temp, nLocalNpcX, nLocalNpcY))
		{
			if(SephirothPlayer(PlayerOwner).LiveQuests[i].nSymbol == 0)
				continue;

			fNX = ((nLocalNpcX+40*MapSize)/100 - fMapStartX)/(3050/512);
			fNY = ((nLocalNpcY+40*MapSize)/100 - fMapStartY)/(2580/512);
			C.SetPos(PageX+MapTexOffsetX+fNX-10, PageY+MapTexOffsetY+fNY-12);

			switch(SephirothPlayer(PlayerOwner).LiveQuests[i].nSymbol)
			{
				case 1: C.DrawTile(TextureResources[24].Resource,19,24,0,0,19,24); break;
				case 2: C.DrawTile(TextureResources[25].Resource,19,24,0,0,19,24); break;
				case 3: C.DrawTile(TextureResources[26].Resource,19,24,0,0,19,24); break;
				case 4: C.DrawTile(TextureResources[27].Resource,19,24,0,0,19,24); break;
				case 5: C.DrawTile(TextureResources[28].Resource,19,24,0,0,19,24); break;
				case 6: C.DrawTile(TextureResources[29].Resource,19,24,0,0,19,24); break;
			}
		}
	}

	C.DrawColor.A = 255;
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);

	// ����
//	C.SetDrawColor(229,201,174);
//	C.DrawKoreanText(sTitle, Components[0].X, Components[0].Y+11, Components[0].XL, 15);
	DrawTitle(C, sTitle);

	// ������
	C.SetDrawColor(229,201,174);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	C.DrawKoreanText(Localize("CWorldMap","Alpha","SephirothUI"), Components[0].X+389, Components[0].Y+42, 50, 15);

	if(!NameEdit.HasFocus())
	{
		if(SearchNpcName == "") {
			C.KTextFormat = ETextAlign.TA_MiddleCenter;
			C.SetDrawColor(126,126,126);
			C.DrawKoreanText(Localize("CWorldMap","PlzNpcName","SephirothUI"),
				Components[6].X,Components[6].Y,Components[6].XL,Components[6].YL);
		}
	}

	// ������ ǥ��
	C.SetDrawColor(255,255,255);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.DrawKoreanText(Components[10+nViewMapInx].Caption, Components[5].X, Components[5].Y, Components[5].XL, Components[5].YL);

//	DrawCharacterLocation(C,450,40);	//World�ʿ��� ������ġ �׽�Ʈ�ϱ� ����. add Sinhyub
	C.DrawColor = OldColor;
}

function bool PushComponentBool(int CmpId)
{
	switch (CmpId)
	{
		case CB_ShowZoneName: return bShowZoneName;
	}
}

//#############################################################################
// ���� �Լ�
//#############################################################################

//�÷��̾��� ��ġ ��ǥ�� ǥ��.  addSinhyub
function DrawCharacterLocation(Canvas C, int offsetX, int offsetY)
{
	local string PosStr;
	local int PlayerLocX, PlayerLocY;	//�÷��̾� ��ġ. sinhyub
	local float XL, YL;	//PosStr ����

	//40*MapSize : ������ �߽��� �������� ��ǥ�� ����. �ٽø���, 80*80������ �߽� (40,40) �� (0,0)���� ���� . sinhyub
	PlayerLocX = PlayerOwner.Pawn.Location.X+40*MapSize;
    PlayerLocY = PlayerOwner.Pawn.Location.Y+40*MapSize;
    PosStr = PlayerLocX/100 $ ":" $ PlayerLocY/100;
    C.TextSize(PosStr,XL,YL);
    C.KTextFormat = ETextAlign.TA_MiddleCenter;
    C.DrawKoreanText(PosStr,Components[0].X+offsetX,Components[0].Y+offsetY,XL,YL);
}


// ������� �����Ǵ� ����ΰ� üũ
function bool IsCheckWorldMapUseArea()
{
	local float fPX, fPY;

	fPX = ((PlayerOwner.Pawn.Location.X+40*MapSize)/100 - 22120)/(3050/512);
	fPY = ((PlayerOwner.Pawn.Location.Y+40*MapSize)/100 - 33810)/(2580/512);
	if(512 > fPX && 0 < fPX && 512 > fPY && 0 < fPY)
	{
		return true; // ���Ƴ׽� �� �ִٸ� true
	}

	fPX = ((PlayerOwner.Pawn.Location.X+40*MapSize)/100 - 20820)/(3050/512);
	fPY = ((PlayerOwner.Pawn.Location.Y+40*MapSize)/100 - 24730)/(2580/512);
	if(512 > fPX && 0 < fPX && 512 > fPY && 0 < fPY)
	{
		return true; // ���ν� �� �ִٸ� true
	}

	fPX = ((PlayerOwner.Pawn.Location.X+40*MapSize)/100 - 24680)/(3050/512);
	fPY = ((PlayerOwner.Pawn.Location.Y+40*MapSize)/100 - 33810)/(2580/512);
	if(512 > fPX && 0 < fPX && 512 > fPY && 0 < fPY)
	{
		return true; // ���Ƴ׽� ���� �� �ִٸ� true
	}


	Parent.NotifyInterface(Self,INT_Close);
	AddMessage(1, Localize("Information","CannotUseWorldMap","Sephiroth"), class'Canvas'.static.MakeColor(255,255,0));

	return false; // ����� ����� �� ���� ���̸�� �ִٸ� false
}


// ������� On ������ �� ���� ���� ���� ---
function int InitWorldData()
{
	local float fPX, fPY;

	fPX = ((PlayerOwner.Pawn.Location.X+40*MapSize)/100 - 22120)/(3050/512);
	fPY = ((PlayerOwner.Pawn.Location.Y+40*MapSize)/100 - 33810)/(2580/512);
	if(3050 > fPX && 0 < fPX && 2580 > fPY && 0 < fPY)
	{ 
		nViewMapInx = iLadianes; // ���Ƴ׽��� ����
		nUserMapInx = iLadianes;
		if(nUserSaveInx == -1)
			nUserSaveInx = iLadianes;
		return nViewMapInx;
	}

	fPX = ((PlayerOwner.Pawn.Location.X+40*MapSize)/100 - 20820)/(3050/512);
	fPY = ((PlayerOwner.Pawn.Location.Y+40*MapSize)/100 - 24730)/(2580/512);
	if(3050 > fPX && 0 < fPX && 2580 > fPY && 0 < fPY)
	{
		nViewMapInx = iVeros; // ���ν��� ����
		nUserMapInx = iVeros;
		if(nUserSaveInx == -1)
			nUserSaveInx = iVeros;
		return nViewMapInx;
	}

	fPX = ((PlayerOwner.Pawn.Location.X+40*MapSize)/100 - 24680)/(3050/512);
	fPY = ((PlayerOwner.Pawn.Location.Y+40*MapSize)/100 - 33810)/(2580/512);
	if(3050 > fPX && 0 < fPX && 2580 > fPY && 0 < fPY)
	{
		nViewMapInx = iLadianesEast; // ���Ƴ׽� ���η� ����
		nUserMapInx = iLadianesEast;
		if(nUserSaveInx == -1)
			nUserSaveInx = iLadianesEast;
		return nViewMapInx;
	}

	return -1;
}

function int CheckUserArea()
{
	local float fPX, fPY;

	fPX = ((PlayerOwner.Pawn.Location.X+40*MapSize)/100 - 22120)/(3050/512);
	fPY = ((PlayerOwner.Pawn.Location.Y+40*MapSize)/100 - 33810)/(2580/512);

	if(512 > fPX && 0 < fPX && 512 > fPY && 0 < fPY)
	{ 
		nUserMapInx = iLadianes; // ���Ƴ׽��� ����
		if(nUserSaveInx != iLadianes) // ���� �� �̵��Ѱ� ���� �Ǿ��ٸ�
		{
			nViewMapInx = iLadianes;
			nUserSaveInx = iLadianes;
		}

		return iLadianes;
	}

	fPX = ((PlayerOwner.Pawn.Location.X+40*MapSize)/100 - 20820)/(3050/512);
	fPY = ((PlayerOwner.Pawn.Location.Y+40*MapSize)/100 - 24730)/(2580/512);

	if(512 > fPX && 0 < fPX && 512 > fPY && 0 < fPY)
	{
		nUserMapInx = iVeros; // ���ν��� ����
		if(nUserSaveInx != iVeros) // ���� �� �̵��Ѱ� ���� �Ǿ��ٸ�
		{	
			nViewMapInx = iVeros;
			nUserSaveInx = iVeros;
		}

		return iVeros;
	}

	fPX = ((PlayerOwner.Pawn.Location.X+40*MapSize)/100 - 24680)/(3050/512);
	fPY = ((PlayerOwner.Pawn.Location.Y+40*MapSize)/100 - 33810)/(2580/512);
	if(3050 > fPX && 0 < fPX && 2580 > fPY && 0 < fPY)
	{
		nUserMapInx = iLadianesEast; // ���Ƴ׽� ���η� ����
		if(nUserSaveInx != iLadianesEast) // ���� �� �̵��Ѱ� ���� �Ǿ��ٸ�
		{	
			nViewMapInx = iLadianesEast;
			nUserSaveInx = iLadianesEast;
		}

		return iLadianesEast;
	}

	Parent.NotifyInterface(Self,INT_Close); // ĳ���Ͱ� ���Ƴ׽�, ���ν� �ʵ忡 ���ٸ� ������� �ݴ´�
	AddMessage(1, Localize("Information","CannotUseWorldMap","Sephiroth"), class'Canvas'.static.MakeColor(255,255,0));

	return -1;
}

function GetMapStartXY(int nMapIndex, out float X, out float Y)
{
	switch(nMapIndex)
	{
	case iLadianes: X = 22120; Y = 33810; break;
	case iVeros: X = 20820; Y = 24730; break;
	case iLadianesEast: X = 24680; Y = 33810; break;
	}
}

function bool GetNPC(string Name, bool bSameArea, out int AreaIndex, out int X, out int Y)
{
    if(GameManager(Level.Game).GetNPCData(Name, AreaIndex, X, Y))
    {
	    if(bSameArea)
		    if(AreaIndex != nViewMapInx)
			    return false;

	    return true;
	}
	
	return false;
}

function bool FindNPC(String Name, optional bool bShowQuest, optional out int nX, optional out int nY)
{
	local int nTempIdx, nTempX, nTempY;

	if(GetNPC(Name, false, nTempIdx, nTempX, nTempY))
	{
		nViewMapInx = nTempIdx;
		nNPCX = nTempX;
		nNPCY = nTempY;
	}
	else
		return false;

	bOnNPC = true;
	sNPCName = Name;
	nZoomCount = 1; // ������ ��ü��

	return true;
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

	PageX = (ClipX-WinWidth)/10;
	PageY = (ClipY-WinHeight)/2;

	SaveConfig();
}

defaultproperties
{
     PageX=-1.000000
     PageY=-1.000000
     bShowZoneName=True
     nAlphaCount=5
     nZoomCount=1
     nPointAlpha=155
     nUserMapInx=-1
     nUserSaveInx=-1
     nNPCX=-1
     nNPCY=-1
     AlphaSpeed=0.200000
     Components(0)=(XL=534.000000,YL=617.000000)
     Components(1)=(Id=1,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=501.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="CloseContext")
     Components(2)=(Id=2,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=149.000000,OffsetYL=38.000000,ToolTip="ZoneList")
     Components(3)=(Id=3,Caption="Search",Type=RES_PushButton,XL=54.000000,YL=21.000000,PivotDir=PVT_Copy,OffsetXL=330.000000,OffsetYL=38.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms,ToolTip="FindNPC")
     Components(4)=(Id=4,Caption="ShowZoneName",Type=RES_CheckButton,XL=130.000000,YL=26.000000,PivotDir=PVT_Copy,OffsetXL=433.000000,OffsetYL=577.000000,TextAlign=TA_MiddleLeft,TextColor=(B=98,G=151,R=218,A=255),LocType=LCT_Terms)
     Components(5)=(Id=5,XL=124.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=25.000000,OffsetYL=41.000000)
     Components(6)=(Id=6,XL=141.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=184.000000,OffsetYL=41.000000)
     Components(7)=(Id=7,XL=70.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=442.000000,OffsetYL=39.000000)
     Components(9)=(Id=9,ResId=22,Type=RES_Image,XL=32.000000,YL=32.000000,bRotating=True)
     Components(10)=(Id=10,Caption="LA",Type=RES_PushButton,XL=124.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=25.000000,OffsetYL=61.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(11)=(Id=11,Caption="VE",Type=RES_PushButton,XL=124.000000,YL=16.000000,PivotId=10,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(12)=(Id=12,Caption="LAE",Type=RES_PushButton,XL=124.000000,YL=16.000000,PivotId=11,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     TextureResources(0)=(Package="UI_2011",Path="pulldown_bg",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_x_c",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="btn_s_arr_d_n",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_s_arr_d_o",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="btn_s_arr_d_c",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2011_btn",Path="btn_slide_n",Style=STY_Alpha)
     TextureResources(17)=(Package="UI_2011_btn",Path="btn_slide_o",Style=STY_Alpha)
     TextureResources(18)=(Package="UI_2011_btn",Path="btn_slide_c",Style=STY_Alpha)
     TextureResources(19)=(Package="UI_2011_btn",Path="btn_yell_s_n",Style=STY_Alpha)
     TextureResources(20)=(Package="UI_2011_btn",Path="btn_yell_s_o",Style=STY_Alpha)
     TextureResources(21)=(Package="UI_2011_btn",Path="btn_yell_s_c",Style=STY_Alpha)
     TextureResources(22)=(Package="UI_2011",Path="world_cursor",Style=STY_Alpha)
     TextureResources(23)=(Package="UI_2011",Path="world_npc",Style=STY_Alpha)
     TextureResources(24)=(Package="UI_2011",Path="icon_excl_g",Style=STY_Alpha)
     TextureResources(25)=(Package="UI_2011",Path="icon_excl_y",Style=STY_Alpha)
     TextureResources(26)=(Package="UI_2011",Path="icon_excl_b",Style=STY_Alpha)
     TextureResources(27)=(Package="UI_2011",Path="icon_que_g",Style=STY_Alpha)
     TextureResources(28)=(Package="UI_2011",Path="icon_que_y",Style=STY_Alpha)
     TextureResources(29)=(Package="UI_2011",Path="icon_que_b",Style=STY_Alpha)
     WinWidth=580.000000
     WinHeight=616.000000
     IsBottom=True
}
