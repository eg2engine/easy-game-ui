class DamageInteractor extends Interaction;

const DT_NotUse     = 0;
const DT_Cri        = 2;
const DT_MagicCri   = 3;
const DT_Stun       = 4;
const DT_Miss       = 5;
const DT_Resist     = 6;
const DT_Immune     = 7;
const DT_Special    = 8;
const DT_Max        = 9;

const FontNumW = 36;
const FontNumH = 40;

struct DamageDisplayType
{
	var int   sX, sY;        // 初始屏幕坐标
	var int   X, Y;          // 当前屏幕坐标
	var float DX;            // 水平偏移（特殊类型使用）
	var int   Damage;        // 伤害数值
	var int   nDescType;     // 描述类型
	var color Color;         // 当前颜色（含透明度）
	var bool  bIsValid;      // 是否生效
	var float Age;           // 存活时间
	var float ScaleX, ScaleY;
	var bool  bSwing;
	var int   Count;         // 相同伤害的累积次数
	var Pawn  TargetPawn;    // 绑定的目标 Pawn，用于避免跨目标合并
};

const DamagePoolSize = 30;
const DamageMaxAge   = 2.0f;

var DamageDisplayType DamagePool[DamagePoolSize];
var int                ValidDamages;
var Font               Fonts[6];

var Texture NumberTexture;
var Texture CriticalTexture;
var Texture MagicCriticalTexture;
var Texture MissTexture;
var Texture ImmunTexture;
var Texture ResistTexture;
var Texture StunTexture;
var Texture SpecialTexture;
var Texture MaxTexture;

const FadeInTime                = 0.03f;    // 淡入时间
const NormalDamageMoveDistance  = 100.0f;   // 普通伤害统一水平位移
const SpecialDamageDXRange      = 3.0f;     // 特殊伤害的水平分散范围
const DamageMergeTime           = 0.2f;     // 伤害整合时间窗口

//=====================================================================
// 工具函数
//=====================================================================

function bool PointIsVisible(vector vecView, vector X, vector Point)
{
	local vector StartTrace, EndTrace;

	if ( (vecView Dot X) <= 0.70 )
		return False;

	StartTrace = ViewportOwner.Actor.Location;
	EndTrace = Point;

	if ( !ViewportOwner.Actor.FastTrace(EndTrace, StartTrace) )
		return False;

	return True;
}

/**
 * 计算水平偏移量（简化版本，不再使用动态频率调整）
 * 普通伤害使用统一方向移动（DX = 0），特殊伤害给一点随机散开。
 */
function float CalculateDX(int nDescType)
{
	if ( nDescType == DT_NotUse )
	{
        // 普通伤害：后续 DamageTick 统一处理位移
		return 0.0f;
	}

    // 特殊伤害类型（如 Max）：固定小范围随机分散
	return RandRange(-SpecialDamageDXRange, SpecialDamageDXRange);
}

/**
 * 统一失效一个伤害条目，安全地维护 ValidDamages，并清理 TargetPawn。
 */
function InvalidateDamage(int i)
{
	if ( DamagePool[i].bIsValid )
	{
		DamagePool[i].bIsValid = False;
		DamagePool[i].TargetPawn = None;

		if ( ValidDamages > 0 )
		{
			ValidDamages--;
		}
	}
}

//=====================================================================
// 伤害添加（支持合并）
//=====================================================================

/**
 * 添加伤害显示到伤害池中
 */
function AddDamage(Pawn Pawn, int nDamage, int nDescType, Color Clr)
{
	local ClientController PlayerOwner;
	local vector           V;
	local int              i;
	local bool             bMerged;

	if ( Pawn == None )
		return;

	if ( ViewportOwner == None || ViewportOwner.Actor == None )
		return;

	PlayerOwner = ClientController(ViewportOwner.Actor);
	if ( PlayerOwner == None )
		return;

    // 先尝试与同一目标、同类型、同数值、短时间内的条目合并
	bMerged = False;
	for ( i = 0; i < DamagePoolSize; i++ )
	{
		if ( DamagePool[i].bIsValid &&
			DamagePool[i].TargetPawn == Pawn &&
			DamagePool[i].nDescType == nDescType &&
			DamagePool[i].Damage == nDamage &&
			DamagePool[i].Age <= DamageMergeTime )
		{
			DamagePool[i].Count++;
			bMerged = True;
			break;
		}
	}

	if ( bMerged )
		return;

    // 找空槽位
	for ( i = 0; i < DamagePoolSize; i++ )
	{
		if ( !DamagePool[i].bIsValid )
		{
			if ( nDescType == DT_Miss )
				V = WorldToScreen(Pawn.Location + vect(0,0,1) * Pawn.CollisionHeight / 6,
					PlayerOwner.Location, PlayerOwner.Rotation);
			else
				V = WorldToScreen(Pawn.Location + vect(0,0,1) * Pawn.CollisionHeight / 2,
					PlayerOwner.Location, PlayerOwner.Rotation);

			DamagePool[i].sX = V.X;
			DamagePool[i].sY = V.Y;
			DamagePool[i].X = V.X;
			DamagePool[i].Y = V.Y;

			DamagePool[i].Damage = nDamage;
			DamagePool[i].nDescType = nDescType;
			DamagePool[i].Color = Clr;
			DamagePool[i].Color.A = 0;
			DamagePool[i].Age = 0.0f;
			DamagePool[i].bIsValid = True;
			DamagePool[i].Count = 1;
			DamagePool[i].DX = CalculateDX(nDescType);
			DamagePool[i].ScaleX = 2.0f;
			DamagePool[i].ScaleY = 2.0f;
			DamagePool[i].TargetPawn = Pawn;

			ValidDamages++;
			break;
		}
	}
}

function AddDamageB(Pawn Pawn, int nDamage, int nDescType, Color Clr, int Scale)
{
	local ClientController PlayerOwner;
	local vector           V;
	local int              i;
	local bool             bMerged;

	if ( Pawn == None )
		return;

	if ( ViewportOwner == None || ViewportOwner.Actor == None )
		return;

	PlayerOwner = ClientController(ViewportOwner.Actor);
	if ( PlayerOwner == None )
		return;

    // 合并逻辑同 AddDamage
	bMerged = False;
	for ( i = 0; i < DamagePoolSize; i++ )
	{
		if ( DamagePool[i].bIsValid &&
			DamagePool[i].TargetPawn == Pawn &&
			DamagePool[i].nDescType == nDescType &&
			DamagePool[i].Damage == nDamage &&
			DamagePool[i].Age <= DamageMergeTime )
		{
			DamagePool[i].Count++;
			bMerged = True;
			break;
		}
	}

	if ( bMerged )
		return;

	for ( i = 0; i < DamagePoolSize; i++ )
	{
		if ( !DamagePool[i].bIsValid )
		{
			if ( nDescType == DT_Miss )
				V = WorldToScreen(Pawn.Location + vect(0,0,1) * Pawn.CollisionHeight / 6,
					PlayerOwner.Location, PlayerOwner.Rotation);
			else
				V = WorldToScreen(Pawn.Location + vect(0,0,1) * Pawn.CollisionHeight / 2,
					PlayerOwner.Location, PlayerOwner.Rotation);

			DamagePool[i].sX = V.X;
			DamagePool[i].sY = V.Y;
			DamagePool[i].X = V.X;
			DamagePool[i].Y = V.Y;

			DamagePool[i].Damage = nDamage;
			DamagePool[i].nDescType = nDescType;
			DamagePool[i].Color = Clr;
			DamagePool[i].Color.A = 0;
			DamagePool[i].Age = 0.0f;
			DamagePool[i].bIsValid = True;
			DamagePool[i].Count = 1;
			DamagePool[i].DX = CalculateDX(nDescType);
			DamagePool[i].ScaleX = 2.0f;
			DamagePool[i].ScaleY = 2.0f;
			DamagePool[i].TargetPawn = Pawn;

			ValidDamages++;
			break;
		}
	}
}

//=====================================================================
// 各类型 Tick 动画
//=====================================================================

function DamageTick(float Delta, int i)
{
	local float fRate;

	if ( DamagePool[i].Age < FadeInTime )
	{
		fRate = DamagePool[i].Age / FadeInTime;

		DamagePool[i].ScaleX = 0.8f - (0.25 * fRate);
		DamagePool[i].ScaleY = 0.8f - (0.25 * fRate);
		DamagePool[i].Color.A = 255 * fRate;

		DamagePool[i].X = DamagePool[i].sX;
		DamagePool[i].Y = DamagePool[i].sY;
	}
	else if ( DamagePool[i].Age < (DamageMaxAge * 0.5f) )
	{
		fRate = (DamagePool[i].Age - FadeInTime) /
			((DamageMaxAge * 0.5f) - FadeInTime);

		DamagePool[i].X = DamagePool[i].sX - (NormalDamageMoveDistance * fRate);
		DamagePool[i].Y = DamagePool[i].sY - (100 * fRate);
		DamagePool[i].ScaleX = 0.6f;
		DamagePool[i].ScaleY = 0.6f;
		DamagePool[i].Color.A = 255 - (255 * fRate);
	}
	else
	{
		InvalidateDamage(i);
	}
}

function CriTick(float Delta, int i)
{
	local float fRate;

	if ( DamagePool[i].Age < 0.125f )
	{
		fRate = DamagePool[i].Age / 0.125f;

		DamagePool[i].ScaleX = 1.3f - (0.3 * fRate);
		DamagePool[i].ScaleY = 1.3f - (0.3 * fRate);
		DamagePool[i].Color.A = 255 * fRate;
	}
	else if ( DamagePool[i].Age < 0.25f )
	{
		DamagePool[i].ScaleX = 1.3f;
		DamagePool[i].ScaleY = 1.3f;
		DamagePool[i].Color.A = 255;
	}
	else if ( DamagePool[i].Age < 0.5f )
	{
		fRate = (DamagePool[i].Age - 0.25f) / (0.5f - 0.25f);

		DamagePool[i].Y = DamagePool[i].sY - (100 * fRate);
		DamagePool[i].Color.A = 255 - (255 * fRate);
	}
	else
	{
		InvalidateDamage(i);
	}
}

function SpecialTick(float Delta, int i)
{
	local float fRate;

	if ( DamagePool[i].Age < 0.125f )
	{
		fRate = DamagePool[i].Age / 0.125f;

		DamagePool[i].ScaleX = 1.2f - (0.3 * fRate);
		DamagePool[i].ScaleY = 1.2f - (0.3 * fRate);
		DamagePool[i].Color.A = 255 * fRate;
	}
	else if ( DamagePool[i].Age < 0.25f )
	{
		DamagePool[i].ScaleX = 1.1f;
		DamagePool[i].ScaleY = 1.1f;
		DamagePool[i].Color.A = 255;
	}
	else if ( DamagePool[i].Age < 0.5f )
	{
		fRate = (DamagePool[i].Age - 0.25f) / (0.5f - 0.25f);

		DamagePool[i].Y = DamagePool[i].sY - (100 * fRate);
		DamagePool[i].Color.A = 255 - (255 * fRate);
	}
	else
	{
		InvalidateDamage(i);
	}
}

function MaxTick(float Delta, int i)
{
	local float fRate;

	DamagePool[i].X += DamagePool[i].DX;

	if ( DamagePool[i].Age < 0.125f )
	{
		fRate = DamagePool[i].Age / 0.125f;

		DamagePool[i].ScaleX = 1.2f - (0.3 * fRate);
		DamagePool[i].ScaleY = 1.2f - (0.3 * fRate);
		DamagePool[i].Color.A = 255 * fRate;
	}
	else if ( DamagePool[i].Age < 0.25f )
	{
		DamagePool[i].ScaleX = 1.1f;
		DamagePool[i].ScaleY = 1.1f;
		DamagePool[i].Color.A = 255;
	}
	else if ( DamagePool[i].Age < 0.5f )
	{
		fRate = (DamagePool[i].Age - 0.25f) / (0.5f - 0.25f);

		DamagePool[i].Y = DamagePool[i].sY - (100 * fRate);
		DamagePool[i].Color.A = 255 - (255 * fRate);
	}
	else
	{
		InvalidateDamage(i);
	}
}

function StunTick(float Delta, int i)
{
	local float ScaleD;

	ScaleD = 0.1f;

	if ( DamagePool[i].Age > DamageMaxAge * 0.9f )
		DamagePool[i].Color.A = 255;
	else
		DamagePool[i].Color.A += DamageMaxAge * 50;

	if ( DamagePool[i].Color.A > 255 )
		DamagePool[i].Color.A = 255;

	DamagePool[i].ScaleX -= ScaleD * (Delta / 0.05f);
	DamagePool[i].ScaleY -= ScaleD * (Delta / 0.05f);

	if ( DamagePool[i].nDescType != DT_NotUse && DamagePool[i].ScaleX < 0.3f )
	{
		InvalidateDamage(i);
	}
}

function ImmuneTick(float Delta, int i)
{
	local float fRate;

	if ( DamagePool[i].Age < 0.125f )
	{
		fRate = DamagePool[i].Age / 0.125f;

		DamagePool[i].ScaleX = 1.3f - (0.3 * fRate);
		DamagePool[i].ScaleY = 1.3f - (0.3 * fRate);
		DamagePool[i].Color.A = 255 * fRate;
	}
	else if ( DamagePool[i].Age < 0.25f )
	{
		DamagePool[i].ScaleX = 1.3f;
		DamagePool[i].ScaleY = 1.3f;
		DamagePool[i].Color.A = 255;
	}
	else if ( DamagePool[i].Age < 0.5f )
	{
		fRate = (DamagePool[i].Age - 0.25f) / (0.5f - 0.25f);

		DamagePool[i].Y = DamagePool[i].sY - (100 * fRate);
		DamagePool[i].Color.A = 255 - (255 * fRate);
	}
	else
	{
		InvalidateDamage(i);
	}
}

function MissTick(float Delta, int i)
{
	local float fRate;

	if ( DamagePool[i].Age < FadeInTime )
	{
		fRate = DamagePool[i].Age / FadeInTime;

		DamagePool[i].ScaleX = 0.8f - (0.25 * fRate);
		DamagePool[i].ScaleY = 0.8f - (0.25 * fRate);
		DamagePool[i].Color.A = 255 * fRate;
	}
	else if ( DamagePool[i].Age < (DamageMaxAge * 0.5f) )
	{
		fRate = (DamagePool[i].Age - FadeInTime) /
			((DamageMaxAge * 0.5f) - FadeInTime);

		DamagePool[i].X = DamagePool[i].sX - (100 * fRate);
		DamagePool[i].Y = DamagePool[i].sY - (100 * fRate);
		DamagePool[i].ScaleX = 0.5f;
		DamagePool[i].ScaleY = 0.5f;
		DamagePool[i].Color.A = 255 - (255 * fRate);
	}
	else
	{
		InvalidateDamage(i);
	}
}

//=====================================================================
// Tick
//=====================================================================

event Tick(float Delta)
{
	local int i;

	if ( ValidDamages <= 0 )
		return;

	for ( i = 0; i < DamagePoolSize; i++ )
	{
		if ( DamagePool[i].bIsValid )
		{
			DamagePool[i].Age += Delta;

			if ( DamagePool[i].Age > DamageMaxAge )
			{
				InvalidateDamage(i);
			}
			else
			{
				switch ( DamagePool[i].nDescType )
				{
					case DT_NotUse:
						DamageTick(Delta, i);
						break;

					case DT_Cri:
					case DT_MagicCri:
						CriTick(Delta, i);
						break;

					case DT_Stun:
//                      StunTick(Delta, i);
//                      break;

					case DT_Miss:
						MissTick(Delta, i);
						break;

					case DT_Resist:
					case DT_Immune:
						ImmuneTick(Delta, i);
						break;

					case DT_Special:
						SpecialTick(Delta, i);
						break;

					case DT_Max:
						MaxTick(Delta, i);
						break;
				}
			}
		}
	}
}

//=====================================================================
// 绘制：主伤害数字 + 角标 xN
//=====================================================================

function RenderDamageDisplay(Canvas C, float X, float Y, int nDamage, float fScale,
	optional bool bTake, optional int Count)
{
	local int   i, n;
	local float fW;
	local string sTemp;

	local float BaseX;
	local float CurX;
	local float SupScale;
	local float SupX, SupY;
	local float TextWidth, TextHeight;

	local color OldColor;
	local Font  OldFont;
	local float OldFontScaleX, OldFontScaleY;

    // 保存 Canvas 状态
	OldColor = C.DrawColor;
	OldFont = C.Font;
	OldFontScaleX = C.FontScaleX;
	OldFontScaleY = C.FontScaleY;

    // Count > 1：合并伤害高亮颜色
	if ( Count > 1 )
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 210;
		C.DrawColor.B = 120;
		C.DrawColor.A = 255;
	}

    // 1. 主伤害数字（居中）
	sTemp = ""$nDamage;

	fW = Len(sTemp) * (FontNumW * fScale / 2);
	BaseX = X - fW;
	CurX = BaseX;

	for ( i = 0; i < Len(sTemp); i++ )
	{
		n = int(Mid(sTemp, i, 1));

		C.SetPos(CurX, Y);
		C.DrawTile(NumberTexture,
			FontNumW * fScale,
			FontNumH * fScale,
			n * FontNumW, 0,
			FontNumW, FontNumH);

		CurX += (FontNumW - 3) * fScale;
	}

    // 2. 角标形式的 xN（右上方、小一号）
	if ( Count > 1 )
	{
		SupScale = fScale * 0.6;

		SupX = CurX - FontNumW * SupScale * 0.2;
		SupY = Y - FontNumH * SupScale * 0.3;

		if ( Fonts[4] != None )
			C.Font = Fonts[4];
		else if ( Fonts[0] != None )
			C.Font = Fonts[0];

		C.FontScaleX = 0.5;
		C.FontScaleY = 0.5;

		C.TextSize("x", TextWidth, TextHeight);

		C.SetPos(SupX, SupY - TextHeight * 0.1);
		C.DrawText("x", False);

		SupX += TextWidth * 0.8;

		sTemp = ""$Count;

		for ( i = 0; i < Len(sTemp); i++ )
		{
			n = int(Mid(sTemp, i, 1));

			C.SetPos(SupX, SupY);
			C.DrawTile(NumberTexture,
				FontNumW * SupScale,
				FontNumH * SupScale,
				n * FontNumW, 0,
				FontNumW, FontNumH);

			SupX += (FontNumW - 3) * SupScale;
		}
	}

    // 恢复 Canvas 状态
	C.DrawColor = OldColor;
	C.Font = OldFont;
	C.FontScaleX = OldFontScaleX;
	C.FontScaleY = OldFontScaleY;
}

// 描述贴图（暴击/Miss/Immune 等）
function RenderDescDisplay(Canvas C, float X, float Y, int nDescType, float fScale)
{
	local Texture tmp;
	local float   fW, fH;

	switch ( nDescType )
	{
		case DT_NotUse:   return;
		case DT_Cri:      fW = 250; fH = 55; tmp = CriticalTexture;       break;
		case DT_MagicCri: fW = 250; fH = 55; tmp = MagicCriticalTexture;  break;
		case DT_Stun:     fW = 130; fH = 51; tmp = StunTexture;           break;
		case DT_Miss:     fW = 130; fH = 53; tmp = MissTexture;           break;
		case DT_Immune:   fW = 145; fH = 46; tmp = ImmunTexture;          break;
		case DT_Resist:   fW = 128; fH = 46; tmp = ResistTexture;         break;
		case DT_Special:  fW = 216; fH = 49; tmp = SpecialTexture;        break;
		case DT_Max:      fW = 244; fH = 49; tmp = MaxTexture;            break;
	}

	C.SetPos(X - (fW * fScale / 2), Y - (fH * fScale) - 2);
	C.DrawTile(tmp, fW * fScale, fH * fScale, 0, 0, fW, fH);
}

//=====================================================================
// PostRender
//=====================================================================

event PostRender(Canvas C)
{
	local int   i;
	local color OldColor;
	local float RenderScale;
	local byte  OldStyle;

	if ( ValidDamages <= 0 )
		return;

	OldColor = C.DrawColor;
	OldStyle = C.Style;

	C.Style = 5;   // alpha blend

	for ( i = 0; i < DamagePoolSize; i++ )
	{
		RenderScale = 1.0f;

		if ( DamagePool[i].bIsValid )
		{
			if ( DamagePool[i].nDescType != DT_NotUse )
			{
				if ( DamagePool[i].Damage != 0 )
				{
                    // 描述贴图
					C.SetDrawColor(255,255,255,255);
					RenderDescDisplay(C, DamagePool[i].X, DamagePool[i].Y - 20,
						DamagePool[i].nDescType, RenderScale);

					if ( DamagePool[i].Age > 0.125f )
					{
                        // 具体数值
						C.DrawColor = DamagePool[i].Color;
						RenderDamageDisplay(C,
							DamagePool[i].X,
							DamagePool[i].Y - 20,
							DamagePool[i].Damage,
							RenderScale,
							,
							DamagePool[i].Count);
					}
				}
				else
				{
                    // 没有数值的描述（Miss/Immune 等）
					RenderScale = DamagePool[i].ScaleX;
					C.DrawColor = DamagePool[i].Color;

					if ( DamagePool[i].nDescType == DT_Miss )
					{
						RenderDescDisplay(C, DamagePool[i].X, DamagePool[i].Y,
							DamagePool[i].nDescType, RenderScale);
					}
					else if ( DamagePool[i].nDescType != DT_Cri &&
						DamagePool[i].nDescType != DT_MagicCri &&
						DamagePool[i].nDescType != DT_Special &&
						DamagePool[i].nDescType != DT_Max )
					{
						RenderDescDisplay(C, DamagePool[i].X, DamagePool[i].Y,
							DamagePool[i].nDescType, RenderScale);
					}
				}
			}
			else if ( DamagePool[i].Damage != 0 )
			{
                // 普通伤害数字
				RenderScale = DamagePool[i].ScaleX;
				C.DrawColor = DamagePool[i].Color;

				RenderDamageDisplay(C,
					DamagePool[i].X,
					DamagePool[i].Y,
					DamagePool[i].Damage,
					RenderScale,
					,
					DamagePool[i].Count);
			}
		}
	}

	C.DrawColor = OldColor;
	C.Style = OldStyle;
}

defaultproperties
{
	Fonts(0)=Font'FontEx.ArialHuge'
	Fonts(1)=Font'FontEx.ArialLarge'
	Fonts(2)=Font'FontEx.TrebHuge'
	Fonts(3)=Font'FontEx.TrebLarge'
	Fonts(4)=Font'FontNumbers.ArialBlackSmoll'

	NumberTexture=Texture'Fontdisplay_Kor.text_effect_num'
	CriticalTexture=Texture'Fontdisplay_Kor.text_effect_cri'
	MissTexture=Texture'Fontdisplay_Kor.text_effect_miss'
	ImmunTexture=Texture'Fontdisplay_Kor.text_effect_immu'
	StunTexture=Texture'Fontdisplay_Kor.text_effect_stun'
	MaxTexture=Texture'Fontdisplay_Kor.text_effect_max'

	bVisible=True
	bRequiresTick=True
}
