class CSkillTree extends CSelectable;

var Skill LastSkill;
var SkillBook CurrentBook;
var string CurrentBookName;
var array<Texture> TreeTextures;

var string sTitle;

const BN_Exit = 2;
const BN_LowLv = 3;
const BN_HighLv = 4;


const BN_BareHand = 5;
const BN_BareFoot = 6;
const BN_OneHand = 7;
const BN_Bow = 8;
const BN_Spirit = 9;
const BN_Staff = 10;
const BN_Red = 11;
const BN_RedSupport = 12;
const BN_Blue = 13;
const BN_BlueSupport = 14;

var array<Texture> DynamicTextures;

var CInfoBox InfoBox;

//add neive : ���� ��ų -------------------------------------------------------
const MAX_BSC = 3; //add neive : �ʺ��� ��ų ����
const MAX_FSC = 8; // First Skill Count 
const MAX_SSC = 13; // Second Skill Count
const MAX_ASC = 16; //add neive : AC ��ų ����

const INDEX_BSC = 3;
const INDEX_FSC = 8;
const INDEX_SSC = 13;
const INDEX_ASC = 16;

var bool bOnHighLv;
var int nGrade; // 0:�ʱ� 1:SC 2:RC 3:AC 
var array<QuickKeyButton> QuickKeyButtons;
var array<Texture> SkillIconsDisable;

delegate function SetHotKeySprite(SephirothPlayer PC, int SlotIndex, int BoxIndex, bool bSet);

//-----------------------------------------------------------------------------

function ShowDefaultTree()
{
	local string sJob;

	sJob = string(SephirothPlayer(PlayerOwner).PSI.JobName);

	if( sJob == "Bare" )
		NotifyComponent(-1, BN_BareHand);
	else if(sJob == "OneHand")
		NotifyComponent(-1, BN_OneHand);
	else if(sJob == "Bow")
		NotifyComponent(-1, BN_Bow);
	else if(sJob == "Red")
		NotifyComponent(-1, BN_Red);
	else if(sJob == "Blue")
		NotifyComponent(-1, BN_Blue);
}

function OnInit()
{
	SetButton();

	ShowDefaultTree(); // ó�� �ѷ��� ��ų Ʈ��

	sTitle = Localize("CSkillTree", "S_Title", "SephirothUI");

	InfoBox = CInfoBox(AddInterface("SephirothUI.CSkillInfoBox"));

	GotoState('Nothing');
}

function OnFlush()
{
	FlushDynamicTextures();

	InfoBox.HideInterface();
	RemoveInterface(InfoBox);
	InfoBox = None;

	Controller.ResetDragAndDropAll();
}

final function Texture LoadDynamicTexture(string TextureName)
{
	local Texture T;
	local int i;
	T = Texture(DynamicLoadObject(TextureName,class'Texture'));
	if ( T != None ) 
	{
		for ( i = 0;i < DynamicTextures.Length;i++ )
			if ( T == DynamicTextures[i] )
				break;
		if ( i == DynamicTextures.Length ) 
		{
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
	for ( i = 0;i < DynamicTextures.Length;i++ ) 
	{
		if ( DynamicTextures[i] != None ) 
		{
			UnloadTexture(Viewport(PlayerOwner.Player),DynamicTextures[i]);
		}
	}
	DynamicTextures.Remove(0,count);

	for( i = 0; i < QuickKeyButtons.Length;++i )
	{
		QuickKeyButtons[i].Destroy();
		QuickKeyButtons[i] = None;
	}

	QuickKeyButtons.Remove(0, QuickKeyButtons.Length);
}

function DestroyInfoBox()
{
	InfoBox.HideInterface();
	RemoveInterface(InfoBox);
	InfoBox = None;
}

function Layout(Canvas C)
{
	local int i, tmpX, tmpY;

	MoveComponentId(0,True,C.ClipX - Components[0].XL * Components[0].ScaleX,0);
	for ( i = 1; i < Components.Length; i++ )
		MoveComponentId(i);

	//add neive : ���� ��ų ---------------------------------------------------
	for( i = 0; i < QuickKeyButtons.Length; i++ )
	{
		if( i < MAX_BSC ) //add neive : �ʺ��� ��ų
		{
			tmpX = Components[0].X + 24;
			tmpY = Components[0].Y + 100 + (i * 73);
		}
		else if(i < INDEX_FSC)
		{
			tmpX = Components[0].X + 24 + 62;
			tmpY = Components[0].Y + 100 + ((i - INDEX_BSC) * 73);
		}
		else if(i < INDEX_SSC)
		{
			tmpX = Components[0].X + 24 + (62 * 2);
			tmpY = Components[0].Y + 100 + ((i - INDEX_FSC) * 73);
		}
		else if(i < INDEX_ASC)
		{
			tmpX = Components[0].X + 24 + (62 * 3);
			tmpY = Components[0].Y + 100 + ((i - INDEX_SSC) * 73);
		}

		QuickKeyButtons[i].SetPos(tmpX, tmpY);
		QuickKeyButtons[i].SetInfoboxPos(0, -10, 1);
	}
	//-------------------------------------------------------------------------

	Super.Layout(C);
}

function LoadTree(string BookName)
{
	TreeTextures.Remove(0,TreeTextures.Length);

	TreeTextures[0] = LoadDynamicTexture("SkillTrees_2011."$BookName);

}

function Texture LoadSkillSprite(Skill Skill,InterfaceRegion Rgn)	
{
	local string SpriteString;

	SpriteString = "SkillSprites."$Skill.BookName$"."$Skill.SkillName;
	if ( !Skill.bLearned || !Skill.bEnabled )
		SpriteString = SpriteString$"D";
	else if (IsCursorInsideRegion(Rgn))
		SpriteString = SpriteString$"O";
	else
		SpriteString = SpriteString$"N";
	return Texture(DynamicLoadObject(SpriteString, class'Texture'));
}

function OnPreRender(Canvas C)		//modified by yj  Layout�� Notifycompnent�� ����� ������.
{
	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, sTitle);

	C.SetPos(Components[0].X + 11,Components[0].Y + 56);
	C.DrawTile(TextureResources[17].Resource,256,4,0,0,4,4);

	if( CurrentBookName != "HighLv" )
	{
		C.SetPos(Components[0].X + 11,Components[0].Y + 86);	// ��ų ���� ��ư �ٷ� �Ʒ� ����
		C.DrawTile(TextureResources[17].Resource,256,4,0,0,4,4);
	}
}

function DrawObject(Canvas C)
{
	local int i;
	local float fX, fY;
	local InterfaceRegion Frame, SpriteRgn;
	local float DrawStart;
	local Skill Skill;
	local Texture Sprite;
	local color OldColor;

	local PlayerServerInfo PSI;
	local CInterface TopInterface;

	PSI = SephirothPlayer(PlayerOwner).PSI;
	TopInterface = SephirothInterface(PlayerOwner.myHud).ITopOnCursor;

	C.SetDrawColor(255,255,255);

	//add neive : ���� ��ų ---------------------------------------------------
	if ( CurrentBookName == "HighLv" )
	{
		DrawHighLvSkill(C);
		return;
	}
	//-------------------------------------------------------------------------

	if ( CurrentBook == None )
		return;

	Frame.X = Components[1].X;
	Frame.Y = Components[1].Y;
	Frame.W = Components[1].XL;
	Frame.H = Components[1].YL;



	C.SetRenderStyleAlpha();
	C.SetPos(Frame.X, max(DrawStart, Frame.Y));
	C.DrawTile(TreeTextures[0],256, 469, 0, 0, 256, 469);

	OldColor = C.DrawColor;
	C.Style = ERenderStyle.STY_Normal;

	for ( i = 0;i < CurrentBook.Skills.Length;i++ )
	{
		Skill = CurrentBook.Skills[i];

		Sprite = LoadSkillSprite(Skill,SpriteRgn);
		if ( Sprite != None )
		{
			fX = Frame.X + 47 + (44 * Skill.TreeLoc.X);
			fY = Frame.Y + 22 + (44 * Skill.TreeLoc.Y);

			if( Sprite != None )
			{
				C.SetDrawColor(255,255,255);
				C.SetPos(fX, fY);
				if( IsCursorInsideAt(fX, fY, Sprite.USize, Sprite.VSize) )
				{
					LastSkill = Skill;
					C.SetDrawColor(255,242,0);
					C.DrawTile(Sprite, 30, 30, 0, 0, Sprite.USize, Sprite.VSize);
				}
				else
					C.DrawTile(Sprite, 30, 30, 0, 0, Sprite.USize, Sprite.VSize);
			}
		}

		if ( LastSkill != None && Controller.DragObject == None && Controller.bMouseMoved && TopInterface == Self )
			InfoBox.SetInfo(LastSkill, Controller.MouseX, Controller.MouseY, True, C.ClipX, C.ClipY);
		else
			LastSkill = None;
	}

	C.DrawColor = OldColor;	
}

function DrawHighLvSkill(Canvas C)
{
	local int i, nSkillNum;
	local int X,Y, cx, cy;
	local PlayerServerInfo PSI;
//	local string SC, RC, LC;
	local float width, height; 
	local color OldColor;

	PSI = SephirothPlayer(PlayerOwner).PSI;

	nSkillNum = MAX_BSC;
	if( PSI.Grade == 1 )
		nSkillNum = MAX_SSC;
	else if(PSI.Grade == 2)
		nSkillNum = MAX_FSC;
	else if(PSI.Grade == 3) //add neive : AC ��ų
		nSkillNum = MAX_ASC;

	//add neive : �ʺ��� ��ų, ������ ��ų�� ������ �� �����ش�
	for( i = 0; i < INDEX_BSC; i++ )
		QuickKeyButtons[i].bVisible = True;

	C.KTextFormat = ETextAlign.TA_MiddleCenter;

	// grade�� ���� ����Ű ǥ��
	if( PSI.Grade > 0 )
	{
		for( i = INDEX_BSC; i < nSkillNum; i++ )
		{
			// grade�� ���� ��ư�� show/hide
			if( PSI.SecondSkillBook.Skills[i].Grade <= nGrade ) // Ŭ���� ������ �׷��̵常 �����ش�
				QuickKeyButtons[i].bVisible = True;
			else
				QuickKeyButtons[i].bVisible = False;
		}
	}

	X = Components[0].X;
	Y = Components[0].Y;
	cx = Components[0].X + 24;
	cy = Components[0].Y + 100;
	width = 62;
	height = 73;

	C.SetDrawColor(255,255,255);
	
	//add neive : �ʺ��� ��ų, �׵θ� ǥ�� ------------------------------------
/*	C.SetDrawColor(70,180,100);
	C.SetPos(cx, cy);
	C.DrawBox(C, 50, 327);

	LC = "LC   ";
	X = cx;
	Y = 375;

	C.DrawTextJustified(LC, 1, X,Y-1,X+width,Y+height);*/


	C.SetPos(X + 16, Y + 70);
	C.DrawTile(TextureResources[18].Resource, 60, 419, 0, 0, 60, 419);

	for( i = 0; i < INDEX_BSC; i++ )
	{
		C.SetPos(QuickKeyButtons[i].WinX - 4, QuickKeyButtons[i].WinY + 44);
		C.DrawTile(TextureResources[19].Resource, 52,26, 0,0, 52,26);
		C.DrawKoreanText(PSI.SecondSkillBook.Skills[i].SkillLevel$"/10", QuickKeyButtons[i].WinX - 4, QuickKeyButtons[i].WinY + 45, 52, 26);
	}

	C.SetDrawColor(173,229,179);
	C.DrawKoreanText(Localize("CSkillTree","S_Low","SephirothUI"), X + 28, Y + 75, 38, 14);
	//-------------------------------------------------------------------------

	if( nGrade == 0 )	// PSI.Grade -> nGrade�� ��ü�Ͽ����ϴ�. 2009.10.29.Sinhyub.
		return ;

	// SC ǥ�� ----------------------------------------------------------------
	if( nGrade > 0 )
	{
/*		SC = "SC:" $ string(PSI.SkillCredit);
		X = cx;
		Y = 375;
		OldColor = C.DrawColor;
		C.SetDrawColor(198,173,96);
		C.DrawTextJustified(SC, 1, X-1,Y,X-1+width,Y+height);
		C.DrawTextJustified(SC, 1, X+1,Y,X+1+width,Y+height);
		C.DrawTextJustified(SC, 1, X,Y-1,X+width,Y-1+height);
		C.DrawTextJustified(SC, 1, X,Y+1,X+width,Y+1+height);
		C.SetPos(cx+HighLevelSkill_OffSetX, cy);	//���� 16
		C.DrawBox(C, 50, 327);
		C.SetDrawColor(0,0,0);
		C.DrawTextJustified(SC, 1, X,Y,X+width,Y+height);*/

		C.SetDrawColor(255,255,255);
		C.SetPos(X + 16 + 62, Y + 70);
		C.DrawTile(TextureResources[18].Resource, 60, 419, 0, 0, 60, 419);

		for( i = INDEX_BSC; i < MAX_FSC; i++ )
		{
			C.SetPos(QuickKeyButtons[i].WinX - 4, QuickKeyButtons[i].WinY + 44);
			C.DrawTile(TextureResources[19].Resource, 52,26, 0,0, 52,26);
			C.DrawKoreanText(PSI.SecondSkillBook.Skills[i].SkillLevel$"/10", QuickKeyButtons[i].WinX - 4, QuickKeyButtons[i].WinY + 45, 52, 26);
		}

		// ����Ʈ ǥ��
		C.SetDrawColor(231,202,174);
		C.DrawKoreanText(Localize("CSkillTree","S_HighPoint","SephirothUI"), X + 26, Y + 511, 94, 14);
		C.SetPos(X + 130, Y + 511);
		C.DrawTile(TextureResources[20].Resource,38,16,0,0,38,16);
		C.SetDrawColor(255,255,255);
		C.DrawKoreanText(string(PSI.SkillCredit), X + 130, Y + 511, 38, 14);


		C.SetDrawColor(229,224,174);
		C.DrawKoreanText(Localize("CSkillTree","S_High","SephirothUI"), X + 28 + 62, Y + 75, 38, 14);
	}
	//-------------------------------------------------------------------------

	if( nGrade > 1 ) //RC�� ����ϴ� �κ�
	{
/*		RC = "RC:" $ string(PSI.RC);
		X = cx + (HighLevelSkill_OffSetX*2);
		Y = 375;
		C.SetDrawColor(236,123,96);
		C.DrawTextJustified(RC, 1, X-1,Y,X-1+width,Y+height);
		C.DrawTextJustified(RC, 1, X+1,Y,X+1+width,Y+height);
		C.DrawTextJustified(RC, 1, X,Y-1,X+width,Y-1+height);
		C.DrawTextJustified(RC, 1, X,Y+1,X+width,Y+1+height);
		// �׵θ� ǥ�� ------------------------------------------------------------
		C.SetPos(cx+(HighLevelSkill_OffSetX*2), cy);
		C.DrawBox(C, 50, 327);
		//-------------------------------------------------------------------------
		C.SetDrawColor(0,0,0);
		C.DrawTextJustified(RC, 1, X,Y,X+width,Y+height);*/

		C.SetDrawColor(255,255,255);
		C.SetPos(X + 16 + (62 * 2), Y + 70);
		C.DrawTile(TextureResources[18].Resource, 60, 419, 0, 0, 60, 419);

		for( i = MAX_FSC + 1; i < MAX_SSC; i++ )	// + 1 �� ������ Ʈ���������̼� �н�
		{
			C.SetPos(QuickKeyButtons[i].WinX - 4, QuickKeyButtons[i].WinY + 44);
			C.DrawTile(TextureResources[19].Resource, 52,26, 0,0, 52,26);
			C.DrawKoreanText(PSI.SecondSkillBook.Skills[i].SkillLevel$"/10", QuickKeyButtons[i].WinX - 4, QuickKeyButtons[i].WinY + 45, 52, 26);
		}

		// ����Ʈ ǥ��
		C.SetDrawColor(231,202,174);
		C.DrawKoreanText(Localize("CSkillTree","S_RPoint","SephirothUI"), X + 26, Y + 534, 94, 14);
		C.SetPos(X + 130, Y + 534);
		C.DrawTile(TextureResources[20].Resource,38,16,0,0,38,16);
		C.SetDrawColor(255,255,255);
		C.DrawKoreanText(string(PSI.RC), X + 130, Y + 534, 38, 14);


		C.SetDrawColor(229,174,174);
		C.DrawKoreanText(Localize("CSkillTree","S_RC","SephirothUI"), X + 28 + (62 * 2), Y + 75, 38, 14);
	}

	if( nGrade >= 3 ) //add neive : AC ��ų. 3�� Ŭ���� ǥ��
	{
		// 3�� �׵θ� ǥ�� --------------------------------------------------------
/*		RC = "AC   ";
		X = cx + (HighLevelSkill_OffSetX*3);
		Y = 375;
//		C.SetDrawColor(236,123,96);
		C.DrawTextJustified(RC, 1, X-1,Y,X-1+width,Y+height);
		C.DrawTextJustified(RC, 1, X+1,Y,X+1+width,Y+height);
		C.DrawTextJustified(RC, 1, X,Y-1,X+width,Y-1+height);
		C.DrawTextJustified(RC, 1, X,Y+1,X+width,Y+1+height);
		// �׵θ� ǥ�� ------------------------------------------------------------
		C.SetPos(cx+(HighLevelSkill_OffSetX*3), cy);
		C.SetDrawColor(255,255,255);
		C.DrawBox(C, 50, 327);
		//-------------------------------------------------------------------------
		C.SetDrawColor(255,255,255);
		C.DrawTextJustified(RC, 1, X,Y,X+width,Y+height);*/
		//-------------------------------------------------------------------------

		C.SetDrawColor(255,255,255);
		C.SetPos(X + 16 + (62 * 3), Y + 70);
		C.DrawTile(TextureResources[18].Resource, 60, 419, 0, 0, 60, 419);

		for( i = MAX_SSC; i < MAX_ASC; i++ )
		{
			C.SetPos(QuickKeyButtons[i].WinX - 4, QuickKeyButtons[i].WinY + 44);
			C.DrawTile(TextureResources[19].Resource, 52,26, 0,0, 52,26);
			C.DrawKoreanText(PSI.SecondSkillBook.Skills[i].SkillLevel$"/10", QuickKeyButtons[i].WinX - 4, QuickKeyButtons[i].WinY + 45, 52, 26);
		}

		C.SetDrawColor(255,255,255);
		C.DrawKoreanText(Localize("CSkillTree","S_AC","SephirothUI"), X + 28 + (62 * 3), Y + 75, 38, 14);
	}

	C.DrawColor = OldColor;
}

function CreateQuickKeyButton_(int i, string skillname)	
{
	QuickKeyButtons[i] = class'QuickKeyButton'.Static.Create(Self, class'GConst'.Default.BTSkill, skillname);
	QuickKeyButtons[i].ShowInterface();
}

function InitQuickKeyButton_(int i)
{
	QuickKeyButtons[i].SetButtonSize(1);
	QuickKeyButtons[i].SetActionOnRightClick(True);
}

function SetTabTexture(int SelectedComponentId)		//���õ� �ǰ� �׷��� ���� ���� �ؽ��ĸ� �����Ѵ�.
{
	local int i;
	for( i = BN_BareHand; i <= BN_BlueSupport; i++ )
	{
		if( i == SelectedComponentId )
			SetComponentTextureId(Components[i],16, -1,16,16);
		else
			SetComponentTextureId(Components[i],14, -1,16,15);	
	}
}

function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	local string BookName;
	local int i, nTotalSkillLv, nCount;
	local PlayerServerInfo PSI;
		
	if ( NotifyId == BN_BareHand ) 
	{ 
		BookName = "BareHand"; SetTabTexture(NotifyId);
	}	
	//modified by yj
	else if (NotifyId == BN_BareFoot) 
	{ 
		BookName = "BareFoot"; SetTabTexture(NotifyId);
	}
	else if (NotifyId == BN_OneHand) 
	{ 
		BookName = "OneHand"; SetTabTexture(NotifyId);
	}
	else if (NotifyId == BN_Bow) 
	{ 
		BookName = "Bow"; SetTabTexture(NotifyId);
	}
	else if (NotifyId == BN_Spirit) 
	{
		BookName = "Spirit"; SetTabTexture(NotifyId);
	}
	else if (NotifyId == BN_Staff) 
	{ 
		BookName = "Staff"; SetTabTexture(NotifyId);
	}
	else if (NotifyId == BN_Red) 
	{ 
		BookName = "Red"; SetTabTexture(NotifyId);
	}
	else if (NotifyId == BN_RedSupport) 
	{ 
		BookName = "RedSupport"; SetTabTexture(NotifyId);
	}
	else if (NotifyId == BN_Blue) 
	{ 
		BookName = "Blue"; SetTabTexture(NotifyId);
	}
	else if (NotifyId == BN_BlueSupport) 
	{ 
		BookName = "BlueSupport"; SetTabTexture(NotifyId);
	}
	else if (NotifyId == BN_LowLv) //add neive : �Ϲ� ��ų
	{ 
		SetComponentTextureId(Components[3],11, -1,11,11);
		SetComponentTextureId(Components[4],9, -1,11,10);
		bOnHighLv = False;
		CurrentBookName = "";
		ShowDefaultTree();
		return ;
	}
	else if (NotifyId == BN_HighLv) //add neive : ���� ��ų			
	{
		SetComponentTextureId(Components[4],11, -1,11,11);
		SetComponentTextureId(Components[3],9, -1,11,10);
		bOnHighLv = True;
		BookName = "HighLv";
	}  			 
	else if (NotifyId == BN_Exit)
	{
		Controller.ResetDragAndDropAll();
		Parent.NotifyInterface(Self,INT_Close);
	}


	//add neive : ���� ��ų ---------------------------------------------------
	PSI = SephirothPlayer(PlayerOwner).PSI;

	// �Ź� 1�� ��ų������ 2�� ��ų������ üũ --------------------------------
	for( i = MAX_BSC ; i < PSI.SecondSkillBook.Skills.Length ; i++ )
		nTotalSkillLv = nTotalSkillLv + PSI.SecondSkillBook.Skills[i].SkillLevel;

	nGrade = 0;
	nCount = MAX_BSC;

	if( nTotalSkillLv != 0 || PSI.SkillCredit != 0 ) // ��ų ������ 1 �̻��� ��ų�� �ְų� ���� ��ų ����Ʈ�� �ִٸ� 1�� ��ų�����ڷ� �з�
	{
		nGrade = 1;
		nCount = MAX_FSC;
	}

	if( PSI.Grade == 1 ) // �̷��� �Ǹ� 2�� ��ų�����ڷ� �з�
	{
		nGrade = 2;
		nCount = MAX_SSC;
	}

	if( PSI.Grade == 2 ) //add neive : �űԽ�ų. �̷��� �Ǹ� 2�� ��ų�����ڷ� �з�
	{
		nGrade = 3;
		nCount = MAX_ASC;
	}
	//-------------------------------------------------------------------------

	// L ��ư���� �ٷ� ���� �� ----------------------------------------------
	if( bOnHighLv == True )
	{
		BookName = "HighLv";
		CurrentBookName = "HighLv";
		bOnHighLv = False;

		for( i = 0; i < nCount; i++ )
		{
			if( QuickKeyButtons[i] == None )
			{
				if( PSI.SecondSkillBook.Skills[i].Grade == 0 ) //add neive : �ʺ��� ��ų
				{
					CreateQuickKeyButton_(i, PSI.SecondSkillBook.Skills[i].SkillName);
					InitQuickKeyButton_(i);
				}
				else if(PSI.SecondSkillBook.Skills[i].Grade == 3) //add neive : AC ��ų
				{
					if( PSI.SecondSkillBook.Skills[i].SkillLevel > 0 )
					{
						CreateQuickKeyButton_(i, PSI.SecondSkillBook.Skills[i].SkillName);
						InitQuickKeyButton_(i);
					}
				}
				else
				{
					CreateQuickKeyButton_(i, PSI.SecondSkillBook.Skills[i].SkillName);
					InitQuickKeyButton_(i);				
				}
			}
		}
	}
	//-------------------------------------------------------------------------


	if( BookName == "HighLv" )
	{
		FlushDynamicTextures();
		TreeTextures.Remove(0,TreeTextures.Length);
		CurrentBookName = BookName;
		LastSkill = None;
		if ( InfoBox != None )
			InfoBox.SetInfo(None);

		for( i = 0 ; i < nCount ; i++ )
			if( QuickKeyButtons[i] == None )
			{
				if( PSI.SecondSkillBook.Skills[i].Grade == 0 ) //add neive : �ʺ��� ��ų
				{
					CreateQuickKeyButton_(i, PSI.SecondSkillBook.Skills[i].SkillName);
					InitQuickKeyButton_(i);
				}
				else if(PSI.SecondSkillBook.Skills[i].Grade == 3) //add neive : AC ��ų
				{
					if( nGrade >= 3 )//if(PSI.SecondSkillBook.Skills[i].SkillLevel > 0)
					{
						CreateQuickKeyButton_(i, PSI.SecondSkillBook.Skills[i].SkillName);
						InitQuickKeyButton_(i);
					}
				}
				else
				{
					CreateQuickKeyButton_(i, PSI.SecondSkillBook.Skills[i].SkillName);
					InitQuickKeyButton_(i);				
				}
			}
	}
	//-------------------------------------------------------------------------
	else if (BookName != CurrentBookName) 
	{
		FlushDynamicTextures();
		CurrentBook = FindSkillBook(BookName);
		LoadTree(BookName);
		CurrentBookName = BookName;
		LastSkill = None;
		if ( InfoBox != None )
			InfoBox.SetInfo(None);
	}

	Components[5].bVisible = PSI.JobName == 'Bare' && CurrentBookName != "HighLv";
	Components[6].bVisible = PSI.JobName == 'Bare' && CurrentBookName != "HighLv";
	Components[7].bVisible = PSI.JobName == 'OneHand' && CurrentBookName != "HighLv";
	Components[8].bVisible = PSI.JobName == 'Bow' && CurrentBookName != "HighLv";
	Components[9].bVisible = PSI.JobName == 'Bow' && CurrentBookName != "HighLv";
	Components[10].bVisible = ( PSI.JobName == 'Red' || PSI.JobName == 'Blue' ) && CurrentBookName != "HighLv";
	Components[11].bVisible = PSI.JobName == 'Red' && CurrentBookName != "HighLv";
	Components[12].bVisible = PSI.JobName == 'Red' && CurrentBookName != "HighLv";
	Components[13].bVisible = PSI.JobName == 'Blue' && CurrentBookName != "HighLv";
	Components[14].bVisible = PSI.JobName == 'Blue' && CurrentBookName != "HighLv";
}

function SkillBook FindSkillBook(string BookName)
{
	local int i;
	for ( i = 0;i < SephirothPlayer(PlayerOwner).PSI.SkillBooks.Length;i++ ) 
	{
		if ( SephirothPlayer(PlayerOwner).PSI.SkillBooks[i].BookName == BookName )
			return SephirothPlayer(PlayerOwner).PSI.SkillBooks[i];
	}
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if ( Action == IST_Press ) 
	{
		if ( Key == IK_Escape ) 
		{
			if ( InfoBox.Source != None ) 
			{
				InfoBox.SetInfo(None);
				LastSkill = None;
				return True;
			}
			Parent.NotifyInterface(Self, INT_Close);
			return True;
		}
	}

	if ( Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]) )
		return True;
}

function Point GetMousePosToSkillPos()
{
	local Point P;

	if( IsCursorInsideComponent(Components[1]) )
	{
		P.X = (Controller.MouseX - Components[1].X - 47) / 44;
		P.Y = (Controller.MouseY - Components[1].Y - 22) / 44;
	}
	else
	{
		P.X = -1;
		P.Y = -1;
	}

	return P;
}

function bool DoubleClick()
{
//	local int i;
	local Point Point;
	local Skill Skill;

	//add neive : ���� ��ų ---------------------------------------------------
	if ( CurrentBookName == "HighLv" )
		return HLSkillDoubleClick();
	//-------------------------------------------------------------------------

	Point = GetMousePosToSkillPos();
	if ( Point.X != -1 && Point.Y != -1 )
	{
		Skill = SephirothPlayer(PlayerOwner).QuerySkillByIndex(CurrentBookName, Point.X, Point.Y);
		if ( Skill != None && Skill.bLearned && Skill.bEnabled )
		{

			if ( Skill.IsCombo() ) 
			{
				SephirothPlayer(PlayerOwner).SetHotSkill(0,Skill.SkillName);
				return True;
			}
			else if (Skill.IsFinish()) 
			{
				SephirothPlayer(PlayerOwner).SetHotSkill(1,Skill.SkillName);
				return True;
			}
			else if (Skill.IsMagic()) 
			{
				SephirothPlayer(PlayerOwner).SetHotSkill(2,Skill.SkillName);
				return True;
			}
		}
	}
	return False;
}

//add neive : ���� ��ų ���� Ŭ���� -------------------------------------------
function bool HLSkillDoubleClick()
{
	local Secondskill Skill;
	local int i, MaxSkillNums;
	local float X,Y;
	local PlayerServerInfo PSI;
	local int QuickSlotColumns;
	local int QuickSlotRows;
	local int QuickSlotTotalNum;
	QuickSlotTotalNum = class 'QuickKeyConst'.Default.QuickSlotColumns;
	QuickSlotTotalNum *= class 'QuickKeyConst'.Default.QuickSlotRows;
	
	PSI = SephirothPlayer(PlayerOwner).PSI;

	MaxSkillNums = MAX_BSC;
	if( nGrade == 1 )
		MaxSkillNums = MAX_FSC;
	else if(nGrade == 2)
		MaxSkillNums = MAX_SSC;
	else if(nGrade == 3) //add neive : AC ��ų
		MaxSkillNums = MAX_ASC;
	

	for( i = 0 ; i < MaxSkillNums ; i++ )
	{
		if( i < INDEX_BSC ) //add neive : �ʺ��� ��ų
		{
			X = Components[0].X + 24;
			Y = Components[0].Y + 100 + (i * 73);
		}
		else if(i < INDEX_FSC)
		{
			X = Components[0].X + 24 + 62;
			Y = Components[0].Y + 100 + ((i - INDEX_BSC) * 73);
		}
		else if(i < INDEX_SSC)
		{
			X = Components[0].X + 24 + (62 * 2);
			Y = Components[0].Y + 100 + ((i - INDEX_FSC) * 73);
		}
		else if(i < INDEX_ASC)
		{
			X = Components[0].X + 24 + (62 * 3);
			Y = Components[0].Y + 100 + ((i - INDEX_SSC) * 73);
		}

		if( IsCursorInsideAt(X,Y,48,48) )
		{
			Skill = SephirothPlayer(PlayerOwner).PSI.SecondSkillBook.Skills[i];
			if( Skill != None && Skill.SkillType > 0 && Skill.SkillType <= 6 )
			{
				if( Skill.SkillLevel > 0 )
				{
					for( i = 0 ; i < QuickSlotTotalNum ; i++ )
					{
						QuickSlotColumns = i / class 'QuickKeyConst'.Default.QuickSlotRows;
						QuickSlotRows = i % class 'QuickKeyConst'.Default.QuickSlotRows;
						if( PSI.QuickKeys[i].KeyName == "" )
						{
							SephirothPlayer(PlayerOwner).SetHotKey(i,class'GConst'.Default.BTSkill,Skill.SkillName);
							SetHotkeySprite(SephirothPlayer(PlayerOwner), QuickSlotColumns, QuickSlotRows, True);
							return True;
						}
					}
				}		
			}
		}
	}

	return False;
}
//-----------------------------------------------------------------------------




function bool ObjectSelecting()				//Find it!!! study more!
{
	
	local Point Point;
	local Skill Skill;
//	local InterfaceRegion Rgn;

	if( CurrentBookName == "HighLv" )
	{
		return HighLvSkillSelecting();
	}
	else
	{
		if ( !IsCursorInsideComponent(Components[1]) )
			return False;

		Point = GetMousePosToSkillPos();
		if ( Point.X == -1 && Point.Y == -1 )
			return False;

		Skill = SephirothPlayer(PlayerOwner).QuerySkillByIndex(CurrentBookName,Point.X,Point.Y);

		if ( Skill != None && Skill.bLearned && Skill.bEnabled )
		{
			Controller.MergeSelectCandidate(Skill);
			return True;
		}
	}

	return False;
}

//add neive : ���� ���� ��ų --------------------------------------------------
function bool HighLvSkillSelecting()
{
	local Secondskill Skill;
	local int i, MaxSkillNums;
	local float X,Y;
	
	MaxSkillNums = MAX_BSC;
	if( nGrade == 1 )
		MaxSkillNums = MAX_FSC;
	else if(nGrade == 2)
		MaxSkillNums = MAX_SSC;
	else if(nGrade == 3) //add neive : AC ��ų
		MaxSkillNums = MAX_ASC;

	for( i = 0 ; i < MaxSkillNums ; i++ )
	{
		if( i < INDEX_BSC ) //add neive : �ʺ��� ��ų
		{
			X = Components[0].X + 24;
			Y = Components[0].Y + 100 + (i * 73);
		}
		else if(i < INDEX_FSC)
		{
			X = Components[0].X + 24 + 62;
			Y = Components[0].Y + 100 + ((i - INDEX_BSC) * 73);
		}
		else if(i < INDEX_SSC)
		{
			X = Components[0].X + 24 + (62 * 2);
			Y = Components[0].Y + 100 + ((i - INDEX_FSC) * 73);
		}
		else if(i < INDEX_ASC)
		{
			X = Components[0].X + 24 + (62 * 3);
			Y = Components[0].Y + 100 + ((i - INDEX_SSC) * 73);
		}

		if( IsCursorInsideAt(X,Y,48,48) )
		{
			Skill = SephirothPlayer(PlayerOwner).PSI.SecondSkillBook.Skills[i];
			if( Skill != None && Skill.SkillType != 0 && Skill.bLearned )
			{
				Controller.MergeSelectCandidate(Skill);
				return True;			
			}
		}
	}

	return False;
}
//-----------------------------------------------------------------------------

function bool Drop()
{
	if ( IsCursorInsideComponent(Components[1]) )
		return True;
}

function RenderDragging(Canvas C)
{
	local Skill S;
	local Texture Sprite;

	S = Skill(Controller.SelectedList[0]);
	if ( S != None ) 
	{
		Sprite = Texture(DynamicLoadObject("SkillSprites."$S.BookName$"."$S.SkillName$"N", class'Texture'));
		if ( Sprite != None ) 
		{
			C.SetPos(Controller.MouseX - 16,Controller.MouseY - 16);
			C.DrawTile(Sprite,32,32,0,0,32,32);
		}
	}
}


function bool CanDrag()
{
	if( !IsCursorInsideInterface() )
		return False;

	return Controller.IsSomethingSelected();
}

function SetButton()
{
	local int i;
	local PlayerServerInfo PSI;

	SetComponentTextureId(Components[2],12, -1,12,13);
	SetComponentTextureId(Components[3],9, -1,11,10);
	SetComponentTextureId(Components[4],9, -1,11,10);

	SetComponentNotify(Components[2],BN_Exit,Self);
	SetComponentNotify(Components[3],BN_LowLv,Self); // �Ϲ� ��ų
	SetComponentNotify(Components[4],BN_HighLv,Self); // ���� ��ų	


	SetComponentNotify(Components[5],BN_BareHand,Self);
	SetComponentNotify(Components[6],BN_BareFoot,Self);
	SetComponentNotify(Components[7],BN_OneHand,Self);
	SetComponentNotify(Components[8],BN_Bow,Self);
	SetComponentNotify(Components[9],BN_Spirit,Self);
	SetComponentNotify(Components[10],BN_Staff,Self);
	SetComponentNotify(Components[11],BN_Red,Self);
	SetComponentNotify(Components[12],BN_RedSupport,Self);
	SetComponentNotify(Components[13],BN_Blue,Self);
	SetComponentNotify(Components[14],BN_BlueSupport,Self);

	for( i = 5; i <= 14; i++ )
		VisibleComponent(Components[i], False);

	if( bOnHighLv == True )
	{
		SetComponentTextureId(Components[4],11, -1,11,11);
	}
	else
	{
		SetComponentTextureId(Components[3],11, -1,11,11);

		PSI = SephirothPlayer(PlayerOwner).PSI;

		if( PSI.JobName == 'Bare' )
		{
			VisibleComponent(Components[5], True);
			VisibleComponent(Components[6], True);			
		}
		else if(PSI.JobName == 'OneHand')
		{
			VisibleComponent(Components[7], True);				
		}
		else if(PSI.JobName == 'Bow')
		{
			VisibleComponent(Components[8], True);
			VisibleComponent(Components[9], True);	
		}
		else if(PSI.JobName == 'Red')
		{
			VisibleComponent(Components[10], True);
			VisibleComponent(Components[11], True);
			VisibleComponent(Components[12], True);				
		}
		else if(PSI.JobName == 'Blue')
		{
			VisibleComponent(Components[10], True);
			VisibleComponent(Components[13], True);
			VisibleComponent(Components[14], True);	
		}
	}
}

defaultproperties
{
	Components(0)=(XL=279.000000,YL=571.000000)
	Components(1)=(Id=1,XL=256.000000,YL=469.000000,PivotDir=PVT_Copy,OffsetXL=11.000000,OffsetYL=90.000000)
	Components(2)=(Id=2,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=249.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="CloseContext")
	Components(3)=(Id=3,Caption="LowLvSkill",Type=RES_PushButton,XL=120.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=36.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
	Components(4)=(Id=4,Caption="HighLvSkill",Type=RES_PushButton,XL=120.000000,YL=24.000000,PivotId=3,PivotDir=PVT_Right,OffsetXL=3.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
	Components(5)=(Id=5,Caption="BareHandSkill",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=66.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
	Components(6)=(Id=6,Caption="BareFootSkill",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotId=5,PivotDir=PVT_Right,OffsetXL=3.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
	Components(7)=(Id=7,Caption="OneHandSkill",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=66.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
	Components(8)=(Id=8,Caption="BowSkill",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=66.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
	Components(9)=(Id=9,Caption="SpiritSkill",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotId=8,PivotDir=PVT_Right,OffsetXL=3.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
	Components(10)=(Id=10,Caption="StaffSkill",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=66.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
	Components(11)=(Id=11,Caption="RedSkill",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotId=10,PivotDir=PVT_Right,OffsetXL=3.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
	Components(12)=(Id=12,Caption="RedSupportSkill",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotId=11,PivotDir=PVT_Right,OffsetXL=3.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
	Components(13)=(Id=13,Caption="BlueSkill",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotId=10,PivotDir=PVT_Right,OffsetXL=3.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
	Components(14)=(Id=14,Caption="BlueSupportSkill",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotId=13,PivotDir=PVT_Right,OffsetXL=3.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
	TextureResources(0)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
	TextureResources(1)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
	TextureResources(2)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
	TextureResources(3)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
	TextureResources(4)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
	TextureResources(5)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
	TextureResources(6)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
	TextureResources(7)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
	TextureResources(8)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
	TextureResources(9)=(Package="UI_2011_btn",Path="skill_tab_l_n",Style=STY_Alpha)
	TextureResources(10)=(Package="UI_2011_btn",Path="skill_tab_l_o",Style=STY_Alpha)
	TextureResources(11)=(Package="UI_2011_btn",Path="skill_tab_l_c",Style=STY_Alpha)
	TextureResources(12)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
	TextureResources(13)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
	TextureResources(14)=(Package="UI_2011_btn",Path="skill_tab_s_n",Style=STY_Alpha)
	TextureResources(15)=(Package="UI_2011_btn",Path="skill_tab_s_o",Style=STY_Alpha)
	TextureResources(16)=(Package="UI_2011_btn",Path="skill_tab_s_c",Style=STY_Alpha)
	TextureResources(17)=(Package="UI_2011",Path="tab_line",Style=STY_Alpha)
	TextureResources(18)=(Package="UI_2011",Path="skill_high_icon_bg",Style=STY_Alpha)
	TextureResources(19)=(Package="UI_2011",Path="skill_level_bg",Style=STY_Alpha)
	TextureResources(20)=(Package="UI_2011",Path="input_bg_s",Style=STY_Alpha)
	bAcceptDoubleClick=True
	IsBottom=True
}
