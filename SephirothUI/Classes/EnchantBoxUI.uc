// keios - enchant box UI
class EnchantBoxUI extends CInterface;

// control ids
const ID_FRAME = 0;
const ID_ICONSTART = 1;

// constants
const UI_ICON_SPACEX		= 48;	// �����ܰ� ������ ������ ����X (icon[n].left - icon[n-1].left)
const UI_ICON_SPACEY		= 48;	// �����ܰ� ������ ������ ����Y (icon[n].top - icon[n-1].top)
const UI_ICON_OFFSETX		= 8;	// ICON_SPACE�ȿ��� icon�� x��ǥ�� ���ȼ� �����ʿ� ��ġ�� �� �����Ѵ�.
const UI_ICON_OFFSETY		= 8;	// 

const UI_ICON_SIZE			= 32;	// ENCHANT_ICON_SIZE*ENCHANT_ICON_SIZE

// types
struct SpriteImage
{
	var Texture Texture;
	var float U;
	var float V;
	var float UL;
	var float VL;
};

// vars
var int ColumnCount;
var int MaxIcons;
var float IconScale;
var bool bStackLeftUp;		// ���� ���� �������� �׾ư�

// blink ����
var float BlinkInterval;	// �����̴� �ð� ����
var float BlinkDuration;	// �� �ʵ��� �����̴��� ����(=enchant�� �����ð��� �����϶����� �����̴°�)
var float BlinkLastTime;	// ������ ������ �ð� ����


// controller
var ClientController OwnerController;



/*-------------------------*/
/* CREATE				   */
/*-------------------------*/

static function EnchantBoxUI Create(ClientController controller)
{
	local EnchantBoxUI instance;

	instance = new(controller) class'EnchantBoxUI';
	instance.OwnerController = controller;

	return instance;
}



/*-------------------------*/
/* INTERFACE INIT/LAYOUT   */
/*-------------------------*/

function OnInit()
{
	Super.OnInit();

	OwnerController = ClientController(PlayerOwner);

	OnUpdate();
}

function LayoutUI(Canvas C)
{
	WinWidth	= UI_ICON_SPACEX * ColumnCount;
	WinHeight	= UI_ICON_SPACEY * MaxIcons / ColumnCount;

	//	������Ʈ���� ��������ġ �������� �����մϴ�. -2009.11.5.Sinhyub
	//WinX=C.ClipX - WinWidth - 50;
	//WinY=C.ClipY - WinHeight - 70;//WinY = -50;
	WinX= C.ClipX/2 + 170;
	WinY= C.ClipY-WinHeight - 95;
}

function LayOut(Canvas C)
{
	local int i, len;

	// layout
	LayoutUI(C);

	MoveComponent(Components[ID_FRAME], true, WinX, WinY, 0, 0);

	len = Components.Length;
	for(i = 1 ; i < len ; i++)
	{
		MoveComponent(Components[i]);
	}

	Super.LayOut(C);
}


/*-------------------------*/
/* UPDATE FUNCTION		   */
/*-------------------------*/

function ClearIcons()
{
	if(Components.Length >= ID_ICONSTART)
		Components.Remove(ID_ICONSTART, Components.Length-ID_ICONSTART);
}

// enchantbox�� enchant �ϳ��� UI�� add
function AddEnchant(int enchantidx)
{
	local int comp_idx, uiicon_idx;
	local EnchantInfo			info;
	local EnchantInfoInstance	inst;
	local EnchantIcon			icon;
	
	// max icon ����
	if(enchantidx >= MaxIcons)
		return;

	comp_idx = ID_ICONSTART + enchantidx;
	Components.Insert(comp_idx, 1);

	// get enchant info
	inst = OwnerController.EnchantBox.EnchantInfoMap[enchantidx];
	if(inst == None)
		return;
	info = inst.Info;
	icon = inst.Info.Icon;
	if(info == None || icon == None)
		return;


	// icon position
	uiicon_idx = enchantidx;

	// set component basics
	Components[comp_idx].Id			= comp_idx;
	Components[comp_idx].Type		= RES_Image;

	if(!bStackLeftUp)
	{
		Components[comp_idx].OffsetXL	= UI_ICON_OFFSETX + (uiicon_idx % ColumnCount) * UI_ICON_SPACEX;
		Components[comp_idx].OffsetYL	= UI_ICON_OFFSETY + (uiicon_idx / ColumnCount) * UI_ICON_SPACEY;
	}
	else
	{
		Components[comp_idx].OffsetXL	= UI_ICON_OFFSETX + (ColumnCount - (uiicon_idx % ColumnCount)-1) * UI_ICON_SPACEX;
		Components[comp_idx].OffsetYL	= UI_ICON_OFFSETY + (MaxIcons/ColumnCount - (uiicon_idx / ColumnCount)-1) * UI_ICON_SPACEY;
	}

	Components[comp_idx].XL			= UI_ICON_SIZE;
	Components[comp_idx].YL			= UI_ICON_SIZE;
	Components[comp_idx].PivotDir	= PVT_Copy;
	Components[comp_idx].PivotId	= 0;

	InitComponent(Components[comp_idx]);

	// icon texture
	Components[comp_idx].Texture	= icon.IconTexture.Texture;
	Components[comp_idx].U			= icon.IconTexture.U;
	Components[comp_idx].V			= icon.IconTexture.V;
	Components[comp_idx].UL			= icon.IconTexture.UL;
	Components[comp_idx].VL			= icon.IconTexture.VL;
	Components[comp_idx].RenderStyle= STY_Alpha;
	Components[comp_idx].ScaleX		= icon.IconTexture.ScaleX;
	Components[comp_idx].ScaleY		= icon.IconTexture.ScaleY;

	// setup tooltip
	Components[comp_idx].Tooltip			= info.Tooltip;
	Components[comp_idx].bNoLocalizeTooltip = true;

//	//Log("component="@comp_idx$"TEXTURE="$Components[comp_idx].Texture);
}

// EnchantBox�� ���� ����� ��� ȣ��
event OnUpdate()
{
	local int i, len;

	// ui���� icon clear
	ClearIcons();

	if(OwnerController.EnchantBox.EnchantInfoMap.Length <= 0)
	{
		return ;
	}

	// iconbox�� icon�� UI�� �߰��Ѵ�.
	len = OwnerController.EnchantBox.EnchantInfoMap.Length;

	//Log("count="$len);

	for(i = 0 ; i < len ; i++)
	{
		AddEnchant(i);
	}
}


/*-------------------------*/
/* RENDERING		       */
/*-------------------------*/
function OnPostRender(HUD H, Canvas C)
{
	Super.OnPostRender(H, C);
}

/*-------------------------*/
/* TICK EVENT		       */
/*-------------------------*/
event Tick(float delta)
{
	local int i, len;
	local float curTime, timeLeft;

	local EnchantInfoInstance inst;
	local EnchantInfo info;
	local EnchantIcon icon;

	local bool blinkNow;
	
	curTime = OwnerController.Level.TimeSeconds;

	blinkNow = false;

	// ������ üũ
	if(BlinkLastTime == 0)
		BlinkLastTime = curTime;

	if(curTime - BlinkLastTime > BlinkInterval)
	{
		BlinkLastTime = curTime;
		blinkNow = false;
	} 
	else if(curTime - BlinkLastTime > BlinkInterval / 2)
	{
		blinkNow = true;
	}



	// update tooltips for time left
	len = OwnerController.EnchantBox.EnchantInfoMap.Length;

	for(i = 0 ; i < len; i++)
	{
		inst = OwnerController.EnchantBox.EnchantInfoMap[i];
		info = inst.Info;
		icon = info.Icon;

		timeLeft = inst.DisenchantTime - curTime;
		if(timeLeft < 0)
			timeLeft = 0;		// timeLeft�� 0�̻����� �����Ѵ�.


		// ������ ó��
		if(inst.DisenchantTime != 0 && timeLeft < BlinkDuration)
		{
			if(blinkNow)
				Components[ID_ICONSTART+i].bVisible = false;
			else
				Components[ID_ICONSTART+i].bVisible = true;
		}


		if( IsCursorInsideComponent(Components[ID_ICONSTART+i]) )
		{
			if(inst.DisenchantTime == 0)
			{
				Components[ID_ICONSTART+i].Tooltip = info.Tooltip;
			}
			else
			{
				Components[ID_ICONSTART+i].Tooltip = 
					info.Tooltip
					@ "\\n"
					$ Localize("Terms", "TimeLeft", "Sephiroth") @ ":" 
					@ int(timeLeft) @ Localize("Terms", "Second", "Sephiroth");
			}
		}
	}
}



/*-------------------------*/
/* defaultpropertices      */
/*-------------------------*/

defaultproperties
{
     ColumnCount=4
     MaxIcons=8
     IconScale=1.000000
     bStackLeftUp=True
     BlinkInterval=1.000000
     BlinkDuration=30.000000
     WinX=-1.000000
     WinY=-1.000000
     WinWidth=240.000000
     WinHeight=200.000000
     bIgnoreKeyEvents=True
}
