class SecondSkillInterface extends CSelectable
	config(SephirothUI);

var array<Texture> SkillIcons;
var array<Texture> SkillIconsDisable; //@by wj(08/29)
var bool bIconLoaded;

var Texture Back;
//var Texture Back2;
var Texture SlideLBtn;
var Texture SlideRBtn;

var CInfoBox InfoBox;

var INT OldGrade;
var INT Back_XL;
var INT Back_YL;
var INT SlideBt_OffsetY;
var INT Slot_StartX;
var INT Slot_StartY;

const RC_X = 102;
const RC_Y = 282;
var float SC_X;
var float SC_Y;

const Back_1st_U = 200;
const Back_1st_XL = 90;
const Back_1st_YL = 352;
const Icon_XL = 48;
const Icon_YL = 48;
const SlideBt_1st_OffsetY = 160;
const SlideBt_XL = 12;
const SlideBt_YL = 42;
const Slot_1st_StartX = 22;
const Slot_1st_StartY = 29;
const Slot_Offset = 58;
const BubbleSlotX = 18;

const Back_2nd_U = 0;
const Back_2nd_XL = 146;
const Back_2nd_YL = 323;
const SlideBt_2nd_OffsetY = 140;
const Slot_2nd_StartX = 20;
const Slot_2nd_StartY = 21;
const Slot_2nd_Offset = 58;

enum Skill2ndType{
	Show,
	SlideLeft,
	SlideRight,
	Hide
};

enum ClickObj{
	SlideButton,
	Slot
};

var Skill2ndType RenderState;
var globalconfig bool bWindowHidden;
var ClickObj ClickObject;
var int ClickSlotNum;

var float StartX,StartY;
var float SlideOffset;
var float SlideStartTime;
var float BackU;

// keios - quickkeybutton
var array<QuickKeyButton> QuickKeyButtons;


delegate function SetHotKeySprite(SephirothPlayer PC, int SlotIndex, int BoxIndex, bool bSet);

function OnInit()
{
	local int i;
	local PlayerServerInfo PSI;	
	
	//Back2 = Texture(DynamicLoadObject("SecondSkillUI.Default.Back2",class'Texture'));
	//Back1 = Texture(DynamicLoadObject("SecondSkillUI.Default.Back1",class'Texture'));
	Back = Texture(DynamicLoadObject("SecondSkillUI.Default.Back",class'Texture'));

	SlideLBtn = Texture(DynamicLoadObject("SecondSkillUI.Default.SlideLBtn",class'Texture'));
	SlideRBtn = Texture(DynamicLoadObject("SecondSkillUI.Default.SlideRBtn",class'Texture'));	

	InfoBox = CInfoBox(AddInterface("SephirothUI.SecondSkillInfoBox"));

	if (bWindowHidden)
		RenderState = Hide;
	else
		RenderState = Show;

	PSI = SephirothPlayer(PlayerOwner).PSI;
	if(PSI.Grade == 1) {
		BackU = Back_2nd_U;
		Back_XL = Back_2nd_XL;
		Back_YL = Back_2nd_YL;
		SlideBt_OffsetY = SlideBt_2nd_OffsetY;
		Slot_StartX = Slot_2nd_StartX;
		Slot_StartY = Slot_2nd_StartY;
		SC_X = 102;
		SC_Y = 258;
	}
	else {
		BackU = Back_1st_U;
		Back_XL = Back_1st_XL;
		Back_YL = Back_1st_YL;
		SlideBt_OffsetY = SlideBt_1st_OffsetY;
		Slot_StartX = Slot_1st_StartX;
		Slot_StartY = Slot_1st_StartY;
		SC_X = 45;
		SC_Y = 320;
	}
	OldGrade = PSI.Grade;

	// keios - quickkeybuttons init
	for(i = 0 ; i < PSI.SecondSkillBook.Skills.Length ; i++)
	{
		CreateQuickKeyButton_(i, PSI.SecondSkillBook.Skills[i].SkillName);
		InitQuickKeyButton_(i);
	}

	GotoState('Nothing');
}


function CreateQuickKeyButton_(int i, string skillname)
{
	QuickKeyButtons[i] = class'QuickKeyButton'.static.Create(Self, 
														class'GConst'.default.BTSkill, 
														skillname);
	QuickKeyButtons[i].ShowInterface();
}


// initial settings for quickkeybuttons
function InitQuickKeyButton_(int i)
{
	QuickKeyButtons[i].SetButtonSize(1);
	QuickKeyButtons[i].SetActionOnRightClick(true);
}





function LoadSkillIcons()
{
	local int i;
	local string TextureString;
	local SecondSkill Skill;
	local PlayerServerInfo PSI;
	local Texture T;

	PSI = SephirothPlayer(PlayerOwner).PSI;
//	SkillIcons.Remove(0,SkillIcons.Length);	

	for(i = 0 ; i < PSI.SecondSkillBook.Skills.Length ; i++)
	{
		Skill = PSI.SecondSkillBook.Skills[i];
//		if(SkillIcons[i] == None){		
			TextureString = "SecondSkillUI.SkillIcons."$Skill.SkillName$"L";		
			T = Texture(DynamicLoadObject(TextureString, class'Texture'));
			if(T != None)
				SkillIcons[i] = T;
			T = None;
//		}		
//		if(SkillIconsDisable[i] == None){
			TextureString = "SecondSkillUI.SkillIcons."$Skill.SkillName$"D";
			T = Texture(DynamicLoadObject(TextureString,class'Texture'));
			if(T != None)
				SkillIconsDisable[i] = T;
			T= None;
//		}		
	}
}


function OnFlush()
{
	local int i, count, countD;

	InfoBox.HideInterface();
	RemoveInterface(InfoBox);
	InfoBox = None;

	count = SkillIcons.Length;
	countD = SkillIconsDisable.Length;

	for(i = 0 ; i < SkillIcons.Length ; i++)
	{
		if(SkillIcons[i] != None)
			UnloadTexture(Viewport(PlayerOwner.Player), SkillIcons[i]);
		if(SkillIconsDisable[i] != None)
			UnloadTexture(Viewport(PlayerOwner.Player), SkillIconsDisable[i]);
	}
	SkillIcons.Remove(0, count);
	SkillIconsDisable.Remove(0,countD);
//	UnloadTexture(Viewport(PlayerOwner.Player), Back1);
//	UnloadTexture(Viewport(PlayerOwner.Player), Back2);
	UnloadTexture(Viewport(PlayerOwner.Player), Back);
	UnloadTexture(Viewport(PlayerOwner.Player), SlideLBtn);
	UnloadTexture(Viewport(PlayerOwner.Player), SlideRBtn);
	
	Controller.ResetDragAndDropAll();

	if (RenderState == Show)
		bWindowHidden = False;
	else
		bWindowHidden = True;
	SaveConfig();

	// keios
	for(i = 0; i < QuickKeyButtons.Length; ++i)
	{
		QuickKeyButtons[i].Destroy();
		QuickKeyButtons[i] = None;
	}

	QuickKeyButtons.Remove(0, QuickKeyButtons.Length);
}

event Tick(float DeltaTime)
{
}

function LayOut(Canvas C)
{
	local float CurrTime;
	local PlayerServerInfo PSI;
	local int i;
	local float tmpX, tmpY;

	PSI = SephirothPlayer(PlayerOwner).PSI;

	if(OldGrade != 1) {
		if(PSI.Grade == 1) {
			BackU = Back_2nd_U;
			Back_XL = Back_2nd_XL;
			Back_YL = Back_2nd_YL;
			SlideBt_OffsetY = SlideBt_2nd_OffsetY;
			Slot_StartX = Slot_2nd_StartX;
			Slot_StartY = Slot_2nd_StartY;
			SC_X = 102;
			SC_Y = 258;
		}
	}

	StartY = C.ClipY - 190 - Back_YL;
	if( RenderState == Hide )
		StartX = C.ClipX - SlideBt_XL;
	else if( RenderState == Show )
		StartX = C.ClipX - Back_XL - SlideBt_XL;
	else{
		switch(RenderState)
		{
		case SlideLeft:	
			CurrTime = PlayerOwner.Level.TimeSeconds;
			//if(CurrTime <= SlideStartTime)
			//	SlideStartTime = CurrTime;
			SlideOffset = Back_XL * ( (CurrTime - SlideStartTime)/0.4f );
			SlideOffset = FClamp(SlideOffset,0.0f,Back_XL);
			if(SlideOffset >= Back_XL)
			{
				SlideOffset = Back_XL;
				RenderState = Show;
				//@by wj(040213)------
				bWindowHidden = false;
				SaveConfig();
				//--------------------
			}
			StartX = C.ClipX - SlideBt_XL - SlideOffset;		
			break;
		case SlideRight:
			CurrTime = PlayerOwner.Level.TimeSeconds;
			//if(CurrTime <= SlideStartTime)
			//	SlideStartTime = CurrTime;
			SlideOffset = Back_XL * ( (CurrTime - SlideStartTime)/0.4f );
			SlideOffset = FClamp(SlideOffset,0.0f,Back_XL);
			if(SlideOffset >= Back_XL)
			{
				SlideOffset = Back_XL;
				RenderState = Hide;
				//@by wj(040213)------
				bWindowHidden = true;
				SaveConfig();
				//--------------------
			}
			StartX = C.ClipX - SlideBt_XL - Back_XL + SlideOffset;
			break;
		}
	}
	Components[0].XL = Back_XL;
	Components[0].YL = Back_YL;
	MoveComponentId(0,true,StartX,StartY);



	// keios - quickkeybuttons layout

	for(i = 0; i < QuickKeyButtons.Length; ++i)
	{
		tmpX = StartX + SlideBt_XL + Slot_StartX + (i / 5) * Slot_Offset;
		tmpY = StartY + Slot_StartY + (i % 5) * Slot_Offset;
	
		QuickKeyButtons[i].SetPos(tmpX, tmpY);
		QuickKeyButtons[i].SetInfoboxPos(0, -10, 1);
	}


	Super.LayOut(C);
}

function DrawObject(Canvas C)
{
	local int i;
	local int X,Y;
	local PlayerServerInfo PSI;
	local int MaxSkillNums;
	local string SC, RC;
	local float width, height; 
	local color OldColor;

	if (!bIconLoaded) {
		LoadSkillIcons();
		bIconloaded = true;
	}

	PSI = SephirothPlayer(PlayerOwner).PSI;
	if(PSI.Grade == 1)
		MaxSkillNums = 9;
	else
		MaxSkillNums = 5;

	// grade에 따라 단축키 표시
	for(i = 0 ; i < PSI.SecondSkillBook.Skills.Length ; i++)
	{
		if(QuickKeyButtons[i] == None)
		{
			// 새로 생긴 스킬
			CreateQuickKeyButton_(i, PSI.SecondSkillBook.Skills[i].SkillName);
		}

		// grade에 따라 버튼을 show/hide
		if(PSI.Grade != 1)
		{
			if(PSI.SecondSkillBook.Skills[i].Grade == 0)
			{
//				QuickKeyButtons[i].bVisible = true;
			}
			else
			{
				QuickKeyButtons[i].bVisible = false;
			}
		}
		else
		{
			QuickKeyButtons[i].bVisible = true;
		}
	}

	if(RenderState != Hide)
	{
		C.SetPos(StartX, StartY+SlideBt_OffsetY);
		if(RenderState == Show || RenderState == SlideRight)
			C.DrawTile(SlideRBtn,SlideBt_XL,SlideBt_YL,0,0,SlideBt_XL,SlideBt_YL);
		else if(RenderState == SlideLeft)
			C.DrawTile(SlideLBtn,SlideBt_XL,SlideBt_YL,0,0,SlideBt_XL,SlideBt_YL);
		C.SetPos(StartX+SlideBt_XL,StartY);
		C.DrawTile(Back, Back_XL, Back_YL, BackU, 0, Back_XL, Back_YL);
		
/*** keios commented out	****************
		if(InfoBox != None)
			InfoBox.SetInfo(None);

		for(i = 0 ; i < MaxSkillNums ; i++)
		{
			//X = StartX+SlideBt_XL+Slot_StartX;
			//Y = StartY+Slot_StartY+Slot_OffsetY*i;
			Skill = PSI.SecondSkillBook.Skills[i];
			X = StartX+SlideBt_XL+Slot_StartX+ (i / 5) * Slot_Offset;
			Y = StartY+Slot_StartY+ (i % 5) * Slot_Offset;
			C.SetPos(X,Y);			

			if(Skill.SkillName == "Transformation")
				C.DrawTile(SkillIcons[i], Icon_XL, Icon_YL, 0, 0, Icon_XL, Icon_YL);
			else if(Skill.SkillLevel == 0)
				C.DrawTile(SkillIconsDisable[i], Icon_XL, Icon_YL, 0,0,Icon_XL,Icon_YL);
			else
				C.DrawTile(SkillIcons[i], Icon_XL, Icon_YL, 0,0,Icon_XL,Icon_YL);

			if(RenderState == Show && CursorInRect(X,Y,Icon_XL,Icon_YL))
			{
				InfoBox.SetInfo(Skill,X,Y,true,C.ClipX,C.ClipY);
				SecondSkillInfoBox(InfoBox).SetBoxPosition(StartX,Y-10);
			}
			else if(RenderState == SlideLeft || RenderState == SlideRight)
				InfoBox.SetInfo(None);

//			for(k = 0 ; k < 4 ; k++)
//			{
//				X = StartX+BubbleSlotX+SlideBt_XL;
//				Y = BubbleSlotsY[i*4+k]+StartY;
//
//				C.SetPos(X,Y);
//				if(Skill.SkillLevel == 5)
//					C.DrawTile(BlueBubble, 8,8,0,0,8,8);
//				else if(Skill.SkillLevel > k)
//					C.DrawTile(RedBubble, 8,8,0,0,8,8);
//			}

		}
******************/

		SC = string(PSI.SkillCredit);
		width = 30;
		height = 16;
		X = StartX+SlideBt_XL+SC_X;
		Y = StartY+SC_Y;
		OldColor = C.DrawColor;
		C.SetDrawColor(198,173,96);
		C.DrawTextJustified(SC, 1, X-1,Y,X-1+width,Y+height);
		C.DrawTextJustified(SC, 1, X+1,Y,X+1+width,Y+height);
		C.DrawTextJustified(SC, 1, X,Y-1,X+width,Y-1+height);
		C.DrawTextJustified(SC, 1, X,Y+1,X+width,Y+1+height);
		C.SetDrawColor(0,0,0);
		C.DrawTextJustified(SC, 1, X,Y,X+width,Y+height);		
		if(PSI.Grade == 1) {
			//RC를 출력하는 부분
			RC = string(PSI.RC);
			X = StartX+SlideBt_XL+RC_X;
			Y = StartY+RC_Y;
			C.SetDrawColor(198,173,96);
			C.DrawTextJustified(RC, 1, X-1,Y,X-1+width,Y+height);
			C.DrawTextJustified(RC, 1, X+1,Y,X+1+width,Y+height);
			C.DrawTextJustified(RC, 1, X,Y-1,X+width,Y-1+height);
			C.DrawTextJustified(RC, 1, X,Y+1,X+width,Y+1+height);
			C.SetDrawColor(0,0,0);
			C.DrawTextJustified(RC, 1, X,Y,X+width,Y+height);
		}
		C.DrawColor = OldColor;
	}
/*	if(RenderState == SlideLeft || RenderState == SlideRight)
	{
		C.SetPos(StartX, StartY+SlideBt_OffsetY);
		if(RenderState == SlideLeft)
			C.DrawTile(SlideLBtn,SlideBt_XL,SlideBt_YL,0,0,SlideBt_XL,SlideBt_YL);
		else if(RenderState == SlideRight)
			C.DrawTile(SlideRBtn,SlideBt_XL,SlideBt_YL,0,0,SlideBt_XL,SlideBt_YL);
		C.SetPos(StartX+SlideBt_XL,StartY);
		C.DrawTile(Back1, Back_XL, 256,0,0,Back_XL,256);
		C.SetPos(StartX+SlideBt_XL,StartY+256);
		C.DrawTile(Back2, Back_XL, Back_YL - 256,0,0,Back_XL,Back_YL - 256);
		//LoadSkillIcons();

		for(i = 0 ; i < 5 ; i++)
		{
			X = StartX+SlideBt_XL+Slot_StartX;
			Y = StartY+Slot_StartY + Slot_OffsetY*i;			
			C.SetPos(X,Y);
			Skill = PSI.SecondSkillBook.Skills[i];
			
			if(Skill.SkillLevel == 0)
				C.DrawTile(SkillIconsDisable[i], Icon_XL, Icon_YL, 0,0,Icon_XL,Icon_YL);
			else
				C.DrawTile(SkillIcons[i], Icon_XL, Icon_YL, 0,0,Icon_XL,Icon_YL);
		}
		SC = string(PSI.SkillCredit);
		width = 30;
		height = 16;
		X = StartX+SlideBt_XL+54;
		Y = StartY+320;
		OldColor = C.DrawColor;
		C.SetDrawColor(198,173,96);
		C.DrawTextJustified(SC, 1, X-1,Y,X-1+width,Y+height);
		C.DrawTextJustified(SC, 1, X+1,Y,X+1+width,Y+height);
		C.DrawTextJustified(SC, 1, X,Y-1,X+width,Y-1+height);
		C.DrawTextJustified(SC, 1, X,Y+1,X+width,Y+1+height);
		C.SetDrawColor(0,0,0);
		C.DrawTextJustified(SC, 1, X,Y,X+width,Y+height);
		C.DrawColor = OldColor;
		InfoBox.SetInfo(None);
	}
*/
	if(RenderState == Hide)
	{
		C.SetPos(StartX, StartY+SlideBt_OffsetY);
		C.DrawTile(SlideLBtn,SlideBt_XL,SlideBt_YL,0,0,SlideBt_XL,SlideBt_YL);
		InfoBox.SetInfo(None);
	}
}

function bool CursorInRect(float X, float Y, float XL, float YL)
{
	local float MouseX, MouseY;

	MouseX = Controller.MouseX;
	MouseY = Controller.MouseY;

	if(MouseX >= X && MouseX < X+XL && MouseY >= Y && MouseY < Y+YL)
		return true;

	return false;
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local float X,Y;
	local int i, MaxSkillNums;

	if(Action == IST_Press && Key == IK_LeftMouse)
	{
		if(RenderState == Hide){
			X = StartX;
			Y = StartY+SlideBt_OffsetY;
			if(CursorInRect(X, Y, SlideBt_XL, SlideBt_YL))
			{
				ClickObject = SlideButton;
				return true;
			}
		}
		else if(RenderState == Show)
		{
			//X = StartX + Slot_StartX + SlideBt_XL;
			if(SephirothPlayer(PlayerOwner).PSI.Grade == 1)
				MaxSkillNums = 9;
			else
				MaxSkillNums = 5;
			//for(i = 0 ; i < SephirothPlayer(PlayerOwner).PSI.SecondSkillBook.Skills.Length ; i++)
			for(i = 0 ; i < MaxSkillNums ; i++)
			{
				X = StartX + Slot_StartX + SlideBt_XL + (i / 5) * Slot_Offset;
				Y = StartY + Slot_StartY + (i % 5) * Slot_Offset;
				//Y = StartY + Slot_StartY + Slot_OffsetY * i;				
				if(CursorInRect(X, Y, Icon_XL, Icon_YL))
				{
					ClickObject = Slot;
					ClickSlotNum = i;
					return true;
				}
			}
			X = StartX;
			Y = StartY+SlideBt_OffsetY;
			if(CursorInRect(X, Y, SlideBt_XL, SlideBt_YL))
			{
				ClickObject = SlideButton;
				return true;
			}
		}
	}

	if(Action == IST_Release && Key == IK_LeftMouse)
	{
		if(RenderState == Hide)
		{
			X = StartX;
			Y = StartY + SlideBt_OffsetY;
			if(CursorInRect(X,Y,SlideBt_XL,SlideBt_YL))
			{
				if(ClickObject == SlideButton)
				{
					RenderState = SlideLeft;
					SlideStartTime = PlayerOwner.Level.TimeSeconds;
					return true;
				}
			}
		}
		else if(RenderState == Show)
		{
			X = StartX;
			Y = StartY + SlideBt_OffsetY;
			if(CursorInRect(X,Y,SlideBt_XL,SlideBt_YL))
			{
				if(ClickObject == SlideButton)
				{
					RenderState = SlideRight;
					SlideStartTime = PlayerOwner.Level.TimeSeconds;
					return true;
				}
			}
		}
	}
	
	if(RenderState == Show && Key == IK_LeftMouse)
	{		
		X = StartX+SlideBt_XL;
		Y = StartY;		
		
		if(CursorInRect(X,Y,Back_XL,Back_YL))
			return true;
	}

	if (Key == IK_Escape && Action == IST_Press) {
		return OnSlide(false);
	}

	return false;		
}

function bool ObjectSelecting()
{
	local Secondskill Skill;
	local int i, MaxSkillNums;
	local float X,Y;
	
	if(SephirothPlayer(PlayerOwner).PSI.Grade == 1)
		MaxSkillNums = 9;
	else
		MaxSkillNums = 5;
	if(RenderState == Show)
	{		
		//for(i = 0 ; i < SephirothPlayer(PlayerOwner).PSI.SecondSkillBook.Skills.Length ; i++)
		for(i = 0 ; i < MaxSkillNums ; i++)
		{
			X = StartX + Slot_StartX + SlideBt_XL + (i / 5) * Slot_Offset;
			Y = StartY + Slot_StartY + (i % 5) * Slot_Offset;
			//Y = StartY + Slot_StartY + Slot_OffsetY * i;

			if(CursorInRect(X,Y,Icon_XL,Icon_YL))
			{
				Skill = SephirothPlayer(PlayerOwner).PSI.SecondSkillBook.Skills[i];
				if(Skill != None && Skill.SkillType != 0 && Skill.bLearned){
					Controller.MergeSelectCandidate(Skill);
					return true;				
				}
			}
		}
	}
	return false;
}

function bool Drop()
{
	local float X,Y;
	X = StartX+SlideBt_XL;
	Y = StartY;
	if(CursorInRect(X,Y,Back_XL,Back_YL))
		return true;
}

function RenderDragging(Canvas C)
{
	local Skill Skill;
	local Texture SkillIcon;
	if(Controller.SelectedList.Length == 0)
		return;
	Skill = Skill(Controller.SelectedList[0]);
	if(Skill != None && Skill.IsA('SecondSkill'))
	{
		SkillIcon = Texture(DynamicLoadObject("SecondSkillUI.SkillIcons."$Skill.SkillName$"S",class'Texture'));
		if(SkillIcon != None)
		{
			C.SetPos(Controller.MouseX-16,Controller.MouseY-16);
			C.DrawTile(SkillIcon,32,32,0,0,32,32);
		}
	}
}

function bool DoubleClick()
{
	local int i, index, MaxSkillNums;
	local SecondSkill Skill;
	local int X,Y;
	local PlayerServerInfo PSI;

	local int QuickSlotColumns;
	local int QuickSlotRows;
	local int QuickSlotTotalNum;
	QuickSlotTotalNum = class 'QuickKeyConst'.default.QuickSlotColumns;
	QuickSlotTotalNum *= class 'QuickKeyConst'.default.QuickSlotRows;

	PSI = SephirothPlayer(PlayerOwner).PSI;
	if(PSI.Grade == 1)
		MaxSkillNums = 9;
	else
		MaxSkillNums = 5;

	if(RenderState == Show)
	{
		//X = StartX + Slot_StartX + SlideBt_XL;			
		for(i = 0 ; i < SephirothPlayer(PlayerOwner).PSI.SecondSkillBook.Skills.Length ; i++)
		{
			X = StartX + Slot_StartX + SlideBt_XL + (i / 5) * Slot_Offset;
			Y = StartY + Slot_StartY + (i % 5) * Slot_Offset;
			//Y = StartY + Slot_StartY + Slot_OffsetY * i;
			if(CursorInRect(X, Y, Icon_XL, Icon_YL))
			{
				index = i;

				Skill = SephirothPlayer(PlayerOwner).PSI.SecondSkillBook.Skills[index]; // 더블 클릭으로 고른 스킬 정보
				if(Skill != None && Skill.SkillType > 0 && Skill.SkillType <= 6)
				{
					for(i = SephirothInterface(Parent).QuickSlotIndex * 12 ; i < QuickSlotTotalNum ; i++)
					{
						QuickSlotColumns = i / class 'QuickKeyConst'.default.QuickSlotRows;
						QuickSlotRows = i % class 'QuickKeyConst'.default.QuickSlotRows;
						if(PSI.QuickKeys[i].KeyName == "")
						{
							SephirothPlayer(PlayerOwner).SetHotKey(i,class'GConst'.default.BTSkill,Skill.SkillName);
							SetHotkeySprite(SephirothPlayer(PlayerOwner), QuickSlotColumns, QuickSlotRows, true);
							return true;
						}
					}			
				}
			}
		}
	}
	return false;
}

function bool PointCheck()
{
	local float X,Y;
	if(RenderState == Hide || RenderState == Show)
	{
		X = StartX;
		Y = StartY+SlideBt_OffsetY;
		if(CursorInRect(X,Y,SlideBt_XL,SlideBt_YL))
			return true;
	}
	if(RenderState == Show)
	{
		X = StartX+SlideBt_XL;
		Y = StartY;
		if(CursorInRect(X,Y,Back_XL,Back_YL))
			return true;
	}
	return false;
}

function bool CanDrag()
{
	if(!IsCursorInsideInterface())
		return false;
	
	return Controller.IsSomethingSelected();
}

function bool OnSlide(optional bool bOpenAccept)
{
	if (RenderState == Show) {
		RenderState = SlideRight;
		SlideStartTime = PlayerOwner.Level.TimeSeconds;
		SaveConfig();
		return true;
	}
	if (RenderState == Hide && bOpenAccept) {
		RenderState = SlideLeft;
		SlideStartTime = PlayerOwner.Level.TimeSeconds;
		SaveConfig();
		return true;
	}
	return false;
}

defaultproperties
{
     Components(0)=(XL=102.000000,YL=352.000000)
     bAcceptDoubleClick=True
}
