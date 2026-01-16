class QuickKeyButton extends CInterface;

// keios - ������, ��ų ���� ����Ű


// data
var QuickKeyInfo QuickKeyInfo;

// display info
var Texture DisplayTexture;

var string CachedTextureName;
var byte QuickKeySize;

// options
var bool Option_ShowCooldown;
var bool Option_ShowInfoBox;
var bool Option_ActionOnDblClick;
var bool Option_ActionOnRightClick;


// infobox setting
var vector InfoboxPos;
var int	InfoBoxAnchor;


// objects
var ConstantColor BgColor;
var FinalBlend BgBlend;

// internals
var float ChargeRate;

var string m_sLimit;


// const
const QUICKKEYSIZE_SMALL = 0;
const QUICKKEYSIZE_LARGE = 1;
const SMALL_SIZE_X = 32;
const SMALL_SIZE_Y = 32;
const LARGE_SIZE_X = 48;
const LARGE_SIZE_Y = 48;

// �־��� InfoBoxPos�� ����ʿ� ��ġ��ų���ΰ��� �����ϴ� �ɼ� - ���游���.
const ANCHOR_ORIGIN	= 0;
const ANCHOR_LEFT	= 1;
const ANCHOR_RIGHT	= 2;

///////////////////////////////////////////
// create from PSI
static function QuickKeyButton CreateFromPSI(CMultiInterface parent_interface, byte _slotid)
{
	local QuickKeyInfo qkinfo;
	local QuickKeyButton qkbtn;

	if(_slotid < 0)
		return None;

	// spawn & addinterface
	qkbtn = QuickKeyButton(parent_interface.AddInterface("SephirothUI.QuickKeyButton"));
	if(qkbtn == None)
		return None;

	// create&link quickkeyinfo 
	qkinfo = class'QuickKeyInfo'.static.Create(parent_interface.PlayerOwner, qkbtn);
	if(qkinfo == None)
	{
		parent_interface.RemoveInterface(qkbtn);
		return None;
	}
	qkinfo.UpdateFromPSI(_slotid);

	qkbtn.QuickKeyInfo = qkinfo;

	return qkbtn;
}


///////////////////////////////////////////
// create new function
static function QuickKeyButton Create(CMultiInterface parent_interface, 
										byte _type, 
										string _keyname)
{
	local QuickKeyInfo qkinfo;
	local QuickKeyButton qkbtn;

	// spawn & addinterface
	qkbtn = QuickKeyButton(parent_interface.AddInterface("SephirothUI.QuickKeyButton"));
	if(qkbtn == None)
		return None;

	// create&link quickkeyinfo 
	qkinfo = class'QuickKeyInfo'.static.Create(parent_interface.PlayerOwner, qkbtn);	// default slotid = -1
	if(qkinfo == None)
	{
		parent_interface.RemoveInterface(qkbtn);
		return None;
	}
	qkinfo.Update(_type, _keyname);

	qkbtn.QuickKeyInfo = qkinfo;

	return qkbtn;
}

/////////////////////////////////////////////
// detroy
event Destroyed()
{
	HideInterface();

	CMultiInterface(Parent).RemoveInterface(Self);
}


/////////////////////////////////////////////
// CInterface function

// CInterface::OnInit()
function OnInit()
{
	BgColor = new(none) class'ConstantColor';
	BgBlend = new(none) class'FinalBlend';
	BgBlend.Material = BgColor;
	BgBlend.FrameBufferBlending = BgBlend.EFrameBufferBlending.FB_AlphaBlend;
	BgColor.Color = class'Canvas'.static.MakeColor(0,0,255,100);
	
	m_sLimit = Localize("CItemInfoBox", "S_Limit", "SephirothUI");
}

// CInterface::OnFlush()
function OnFlush()
{
	QuickKeyInfo	= None;
	DisplayTexture	= None;

	BgBlend = None;
	BgColor = None;
}

// CInterface::Layout
function Layout(Canvas C)
{
	MoveComponent(Components[0], true, WinX, WinY);
}




/////////////////////////////////////////////////////





/////////////////////////////////////////////////////
// internal functions

// * 2ndSkill�� ��� �پ��� ��쿡 ���� Cooldown, Enabled�� üũ�� �ʿ䰡 �ִ�. *
// * (������ ���� �ڵ�� ������ ������ �ϵ��� �صξ���) *

//	GetTextureName_	function

// texture�� �̸��� ����
// QuickKeyInfo�� skill_ref, ISI_ref�� �����Ǿ��־�� �ϹǷ�, update�Ŀ� ����ؾ��Ѵ�.
function string GetTextureName_()
{
	local string _texturename;
	local string _modelname;

	_texturename = "";

	switch(QuickKeyInfo.Type)
	{
	case class'GConst'.default.BTNone:
		break;
	case class'GConst'.default.BTPotion:
	case class'GConst'.default.BTScroll:
		// update texture
		if (QuickKeyInfo.ISI_ref != None)
		{
			if(IsMarketItem(QuickKeyInfo.ISI_ref.ModelName))
				_texturename = "ItemSpritesM." $ QuickKeyInfo.ISI_ref.ModelName;
			else
				_texturename = "ItemSprites." $ QuickKeyInfo.ISI_ref.ModelName;
		}
		else
		{
			// hotkey cache�κ���???
			_modelname = SephirothInterface(PlayerOwner.myHud).GetHotkeyModelName(QuickKeyInfo.KeyName);
			if (_modelname != "") 
			{
				if(IsMarketItem(_modelname))
					_texturename = "ItemSpritesM." $ _modelname;
				else
				_texturename = "ItemSprites." $ _modelname;
			}
		}
		break;
	case class'GConst'.default.BTSkill:
		if(QuickKeyInfo.Skill_ref != None)
		{
			if(QuickKeyInfo.Skill_ref.IsA('SecondSkill'))
			{
				if(QuickKeySize == QUICKKEYSIZE_SMALL)
				{
					if(QuickKeyInfo.Learned && QuickKeyInfo.Enabled)
						_texturename = "SecondSkillUI.SkillIcons."$QuickKeyInfo.Skill_ref.SkillName$"S";
					else
					{
						// small�� transformation�� �ִ�.
						if(SecondSkill(QuickKeyInfo.Skill_ref).SkillType == 6)
							_texturename = "SecondSkillUI.SkillIcons."$QuickKeyInfo.Skill_ref.SkillName$"SD";
					}
				}
				else 
				{
					if(QuickKeyInfo.Learned && QuickKeyInfo.Enabled 
						&& (SecondSkill(QuickKeyInfo.Skill_ref).SkillType == 6 || QuickKeyInfo.Skill_ref.SkillLevel > 0))
						_texturename = "SecondSkillUI.SkillIcons."$QuickKeyInfo.Skill_ref.SkillName$"L";
					else // if(SecondSkill(QuickKeyInfo.Skill_ref).SkillType == 6)
						_texturename = "SecondSkillUI.SkillIcons."$QuickKeyInfo.Skill_ref.SkillName$"D";
				}
			}
			else
			{
				if(QuickKeyInfo.Learned && QuickKeyInfo.Enabled)
					_texturename = "SkillSprites." $ QuickKeyInfo.Skill_ref.BookName $ "." $ QuickKeyInfo.Skill_ref.SkillName $ "N";
				else
					_texturename = "SkillSprites." $ QuickKeyInfo.Skill_ref.BookName $ "." $ QuickKeyInfo.Skill_ref.SkillName $ "D";
			}
		}
		break;
	}
	return _texturename;
}

function bool IsMarketItem(string sName)
{
	local string sTemp;
	sTemp = Mid(sName, 0, 7);

	if(sTemp == "Market_")
		return true;

	return false;
}

function UpdateTexture_()
{
	local string _NewTextureName;

	_NewTextureName = GetTextureName_();
	
	// �������� ����� ��츸 texture �ε� ó��
	if(CachedTextureName != _NewTextureName)
	{
		// init to invisible
		Components[0].bVisible = false;

		CachedTextureName = _NewTextureName;
		if(_NewTextureName == "")
		{
			DisplayTexture = None;
			return;
		}

		DisplayTexture = Texture(DynamicLoadObject(_NewTextureName,class'Texture'));
		Components[0].RenderStyle = ERenderStyle.STY_Normal;
		Components[0].Texture = DisplayTexture;

		if(DisplayTexture == None)
		{
			// error
			//Log("QuickKeyButton::Update() - ERROR: TEXTURE NOT FOUND"@_NewTextureName);
			CachedTextureName = "";
			return;
		}
		
		Components[0].bVisible = true;
		Components[0].U = 0; Components[0].V = 0;
		Components[0].ScaleX = 1; Components[0].ScaleY = 1;

		if(QuickKeySize == QUICKKEYSIZE_SMALL)
		{
			Components[0].UL = SMALL_SIZE_X; Components[0].VL = SMALL_SIZE_Y;
			Components[0].XL = SMALL_SIZE_X; Components[0].YL = SMALL_SIZE_Y;
		}
		else if(QuickKeySize == QUICKKEYSIZE_LARGE)
		{
			Components[0].UL = LARGE_SIZE_X; Components[0].VL = LARGE_SIZE_Y;
			Components[0].XL = LARGE_SIZE_X; Components[0].YL = LARGE_SIZE_Y;
		}
	}
}


// cooldown ��Ÿ��

function UpdateCooldown_()
{
	if(QuickKeyInfo.Skill_ref != None && QuickKeyInfo.Skill_ref.IsA('SecondSkill'))
	{
		// !enabled�ų� !learned�̸� chargeǥ�ø� ���� �ʴ´�.
		// * ����: bCharged�� �ʱⰪ�� ����� ������Ʈ �ǰ� ���� �ʴ�. *
		ChargeRate = SecondSkill(QuickKeyInfo.Skill_ref).GetChargeRate(SephirothPlayer(PlayerOwner).PSI.SetAvilityLevel, PlayerOwner.Level.TimeSeconds);

		if(SecondSkill(QuickKeyInfo.Skill_ref).bCharged 
			|| SecondSkill(QuickKeyInfo.Skill_ref).ChargeStartTime == 0)
		{
			ChargeRate = 1.0;
		}
	}
	else
	{
		ChargeRate = 1.0;
	}
}


// infobox
function PlaceInfoBox_(CInfoBox _infobox)
{
	switch(InfoBoxAnchor)
	{
	case ANCHOR_LEFT:
		_infobox.WinX = WinX - _infobox.WinWidth - InfoboxPos.x;
		_infobox.WinY = WinY + InfoboxPos.y;
		break;
	case ANCHOR_RIGHT:
		_infobox.WinX = WinX + _infobox.WinWidth + InfoboxPos.x;
		_infobox.WinY = WinY + InfoboxPos.y;
		break;

	case ANCHOR_ORIGIN:
	default:
		_infobox.WinX = WinX + InfoboxPos.x;
		_infobox.WinY = WinY + InfoboxPos.y;
		break;
	}
}


function UpdateInfoBox_()
{
	ShowInfoBox_(IsCursorInsideComponent(Components[0]));
}

function ShowInfoBox_(bool bShow)
{
	if ( SephirothInterface(PlayerOwner.myHud).ITopOnCursor != SephirothInterface(PlayerOwner.myHud).SkillTree )	{

		SephirothInterface(PlayerOwner.myHud).GSecondSkillInfo.SetInfo(None);
		return;
	}

	if(bShow)
	{
		// * sephirothinterface�� InfoBox�� SecondSkillInfoBox, SkillInfo�� SkillInfoBox�̴�.
		if(QuickKeyInfo.Skill_ref != None)
		{
			if(QuickKeyInfo.Skill_ref.IsA('SecondSkill'))
			{
				if(SecondSkill(QuickKeyInfo.Skill_ref).Grade == 3) //add neive : AC ��ų 0���̸� ����â �ȶ߰�
				{
					if(SecondSkill(QuickKeyInfo.Skill_ref).SkillLevel > 0)
					{
						SephirothInterface(PlayerOwner.myHud).GSecondSkillInfo.SetInfo(QuickKeyInfo.Skill_ref, InfoBoxPos.X, InfoBoxPos.Y, false);

						SephirothInterface(PlayerOwner.myHud).GSecondSkillInfo.RefObject = Self;
						PlaceInfoBox_(SephirothInterface(PlayerOwner.myHud).GSecondSkillInfo);
					}
				}
				else
				{
					SephirothInterface(PlayerOwner.myHud).GSecondSkillInfo.SetInfo(QuickKeyInfo.Skill_ref, InfoBoxPos.X, InfoBoxPos.Y, false);

					SephirothInterface(PlayerOwner.myHud).GSecondSkillInfo.RefObject = Self;
					PlaceInfoBox_(SephirothInterface(PlayerOwner.myHud).GSecondSkillInfo);
				}
			}
			else
			{
//				SephirothInterface(PlayerOwner.myHud).GSkillInfo.SetInfo(QuickKeyInfo.Skill_ref, InfoBoxPos.X, InfoBoxPos.Y, false);

				SephirothInterface(PlayerOwner.myHud).GSkillInfo.RefObject = Self;
				PlaceInfoBox_(SephirothInterface(PlayerOwner.myHud).GSkillInfo);
			}
		}
	}
	else
	{
		if(SephirothInterface(PlayerOwner.myHud).GSecondSkillInfo.RefObject == Self)
			SephirothInterface(PlayerOwner.myHud).GSecondSkillInfo.SetInfo(None);

		if(SephirothInterface(PlayerOwner.myHud).GSkillInfo.RefObject == Self)
			SephirothInterface(PlayerOwner.myHud).GSkillInfo.SetInfo(None);
	}
}


/////////////////////////////////////////////////////


/////////////////////////////////////////////////////
// PROCESS EVENTS



event Tick(float delta)
{
	UpdateTick_();

	UpdateCooldown_();	// update cooldown at every frame
	UpdateInfoBox_();
	ProcessMouseEnterLeave_();
}


function bool OnMouseEnter()
{
	//Log("OnMouseEnter");

	if(Option_ShowInfoBox)
		ShowInfoBox_(true);

	return true;
}


function bool OnMouseLeave()
{
	//Log("OnMouseLeave");

	if(Option_ShowInfoBox)
		ShowInfoBox_(false);

	return true;
}

// mouse enter/leave ó��
function ProcessMouseEnterLeave_()
{
	local bool current_in, last_in;

	current_in = IsCursorInsideComponent(Components[0]);
	last_in = Controller.LastMouseX >= Components[0].X && Controller.LastMouseX <= Components[0].X+Components[0].XL*Components[0].ScaleX 
				&&	Controller.LastMouseY >= Components[0].Y && Controller.LastMouseY <= Components[0].Y+Components[0].YL*Components[0].ScaleY;
	
	if(!last_in && current_in)
	{
		// enter

		// showinfo

		OnMouseEnter();
	}
	else if(last_in && !current_in)
	{
		// leave

		// hideinfo

		OnMouseLeave();
	}
}

// keyevent
function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if(Key == IK_RightMouse && Action == IST_Release)
	{
		if(Option_ActionOnRightClick)
		{
			if(bVisible && IsCursorInsideComponent(Components[0]))
			{
				Self.Action();
				return true;
			}
		}
	}

	return false;
}


// double click
function bool DoubleClick()
{
	//Log("DoubleClick"@Self);

	if(bVisible && IsCursorInsideComponent(Components[0]))
	{
		if(Option_ActionOnDblClick)
		{
			Action();
			return true;
		}
	}
	return false;
}

/////////////////////////////////////////////////////




/////////////////////////////////////////////////////
// RENDERING FUNCTION


function OnPostRender(HUD H, Canvas C)
{
	local vector button_size;

	button_size = GetButtonSize();

	// show cooldown
	if(Option_ShowCooldown)
	{
		if(ChargeRate >= 0 && ChargeRate < 1.0)
		{
			C.SetPos(Components[0].X, Components[0].Y);
			C.DrawTile(BgBlend, button_size.X, button_size.Y * (1.0 - ChargeRate),0,0,0,0);
		}
	}

	// draw amount
	DrawItemAmount_(C);
}



// ����Ű�� ��ϵ� �������� ���� ��ο�
function DrawItemAmount_(Canvas C)
{
	local vector button_size;

	button_size = GetButtonSize();

	if(QuickKeyInfo.Type == class'GConst'.default.BTPotion || QuickKeyInfo.Type == class'GConst'.default.BTScroll)
	{
		if(QuickKeyInfo.Amount == 0 || QuickKeyInfo.ISI_ref == None)
			C.SetDrawColor(128,128,128);
		if(QuickKeyInfo.Amount == -99)
			C.SetDrawColor(255,255,0);
		else
			C.SetDrawColor(255,255,255);

		C.SetKoreanTextAlign(ETextAlign.TA_BottomRight); //ETextAlign.TA_TopLeft);

		if(QuickKeyInfo.Amount == -99)
			C.DrawKoreanText(m_sLimit,Components[0].X,Components[0].Y,button_size.X,button_size.Y);
		else
			C.DrawKoreanText(QuickKeyInfo.Amount,Components[0].X,Components[0].Y,button_size.X,button_size.Y);
	}
}


/////////////////////////////////////////////////////







/////////////////////////////////////////////
// Update Function


// Update - QuickKeyInfo�� ���� update�ϰ�, texture�� ���� �ε��Ѵ�.
function Update(byte _type, string _keyname)
{
	QuickKeyInfo.Update(_type, _keyname);

	UpdateTexture_();
	UpdateCooldown_();
	UpdateInfoBox_();
}

function UpdateFromPSI(byte _slotid)
{
	QuickKeyInfo.UpdateFromPSI(_slotid);

	UpdateTexture_();
	UpdateCooldown_();
	UpdateInfoBox_();
}

function UpdateTick_()
{
	QuickKeyInfo.UpdateTick();
	UpdateTexture_();
}


/////////////////////////////////////////////////////



/////////////////////////////////////
//	PUBLIC FUNCTIONS

function SetSlotId(int slot_id)
{
	QuickKeyInfo.SlotId = slot_id;
}


function SetButtonSize(byte _size)
{
	if(_size != QUICKKEYSIZE_SMALL && _size != QUICKKEYSIZE_LARGE)
		_size = QUICKKEYSIZE_SMALL;
	QuickKeySize = _size;

	UpdateTexture_();
}

function vector GetButtonSize()
{
	local vector ret;

	switch(QuickKeySize)
	{
	case QUICKKEYSIZE_SMALL:
		ret.X = SMALL_SIZE_X;
		ret.Y = SMALL_SIZE_Y;
		break;
	case QUICKKEYSIZE_LARGE:
		ret.X = LARGE_SIZE_X;
		ret.Y = LARGE_SIZE_Y;
		break;
	}
	return ret;
}


// Ű�� ����� �׼��� �����Ѵ�.
// 0 : ����
function int Action()
{
	return QuickKeyInfo.Action();
}




/////////////////////////////////////
// setting options

function SetShowInfoBox(bool bShow)
{
	Option_ShowInfoBox = bShow;

	UpdateInfoBox_();
}

function SetShowCooldown(bool bShow)
{
	Option_ShowCooldown = bShow;

	UpdateCooldown_();
}

function SetActionOnDblClick(bool bAction)
{
	Option_ActionOnDblClick = bAction;
	bAcceptDoubleClick = bAction;
}

function SetActionOnRightClick(bool bAction)
{
	Option_ActionOnRightClick = bAction;
}

function SetInfoBoxPos(float X, float Y, int anchor)
{
	InfoBoxAnchor = anchor;
	InfoBoxPos.X = X; InfoBoxPos.Y = Y;
}




/////////////////////////////////////
//	DEFAULT PROPERTIES

defaultproperties
{
     CachedTextureName="***"
     Option_ShowCooldown=True
     Option_ShowInfoBox=True
     Components(0)=(Type=RES_Image,XL=32.000000,YL=32.000000)
}
