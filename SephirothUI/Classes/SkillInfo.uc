class SkillInfo extends CInterface;

const BN_Exit = 1;

var Skill Skill;

function OnInit()
{
	SetComponentTextureId(Components[5],4,0,0,5);
	SetComponentNotify(Components[5],BN_Exit,Self);
}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0,true,C.ClipX-Components[0].XL*Components[0].ScaleX,0);
	for (i=0;i<Components.Length;i++)
		MoveComponentId(i);
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch (NotifyId) {
	case BN_Exit:
		Parent.NotifyInterface(Self,INT_Close);
		break;
	}
}

function SetSkill(Skill S)
{
	if (Skill(Controller.DragObject) != None)
		Skill = Skill(Controller.DragObject);
	else
		Skill = S;
}

function OnPreRender(Canvas C)
{
	Components[6].bVisible = Skill != None && Skill.bHasSkillPoint;
	Components[7].bVisible = Skill != None;
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y;
	local int i,ReqSkillIndex,Value;
	local Skill ReqSkill;

//	if (Skill == None)
//		return;

	X = Components[0].X;
	Y = Components[0].Y;

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.DrawKoreanText(Localize("Terms","SkillPoint","Sephiroth"),X+31,Y+74,103,12);
	C.DrawKoreanText(Localize("Terms","SkillLevel","Sephiroth"),X+31,Y+94,103,12);
	C.DrawKoreanText(Localize("Terms","SkillComboCount","Sephiroth"),X+31,Y+114,103,12);
	C.DrawKoreanText(Localize("Terms","SkillAttackRange","Sephiroth"),X+31,Y+134,103,12);
	C.DrawKoreanText(Localize("Terms","SkillRequirement","Sephiroth"),X+50,Y+165,173,12);
	C.DrawKoreanText(Localize("Terms","StrStat","Sephiroth"),X+50,Y+185,38,16);
	C.DrawKoreanText(Localize("Terms","DexStat","Sephiroth"),X+91,Y+185,38,16);
	C.DrawKoreanText(Localize("Terms","VigorStat","Sephiroth"),X+132,Y+185,38,16);
	C.DrawKoreanText(Localize("Terms","MagicPowerStat","Sephiroth"),X+173,Y+185,50,16);
	C.DrawKoreanText(Localize("Terms","WhiteStat","Sephiroth"),X+34,Y+229,38,16);
	C.DrawKoreanText(Localize("Terms","RedStat","Sephiroth"),X+75,Y+229,38,16);
	C.DrawKoreanText(Localize("Terms","BlueStat","Sephiroth"),X+116,Y+229,38,16);
	C.DrawKoreanText(Localize("Terms","YellowStat","Sephiroth"),X+157,Y+229,38,16);
	C.DrawKoreanText(Localize("Terms","BlackStat","Sephiroth"),X+198,Y+229,38,16);
	C.DrawKoreanText(Localize("Terms","SkillPrevSkills","Sephiroth"),X+54,Y+274,162,13);

	if (Skill == None)
		return;

	if (Skill.bHasSkillPoint)
	{
		//ksshim ... 2003.11.6 SkillPoint -1%
		if( Skill.SkillPoint >= 0 )
			C.DrawKoreanText("0%",X+143,Y+74,95,12);
		else
		C.DrawKoreanText(Skill.SkillPoint $ "%",X+143,Y+74,95,12);
	}
	else
		C.DrawKoreanText(Localize("Information","Unlimited","Sephiroth"),X+143,Y+74,95,12);
	C.DrawKoreanText(Skill.SkillLevel,X+143,Y+94,95,12);
	if (Skill.IsCombo() && Skill.ComboCount >= 0)
		C.DrawKoreanText(Skill.ComboCount,X+143,Y+114,95,12);
	if (Skill.IsMagic())
		C.DrawKoreanText(Skill.AttackRange,X+143,Y+134,95,12);

	for (i=0;i<Skill.RequirementSize;i++) {
		Value = Skill.RequirementMap[i].Value;
		switch (Skill.RequirementMap[i].Type) {
		case 1: // Str
			C.DrawKoreanText(Value,X+50,Y+204,38,18);
			break;
		case 2: // Dex
			C.DrawKoreanText(Value,X+91,Y+204,38,18);
			break;
		case 3: // Vigor
			C.DrawKoreanText(Value,X+132,Y+204,38,18);
			break;
		case 4: // MP
			C.DrawKoreanText(Value,X+173,Y+204,50,18);
			break;
		case 5: // White
			C.DrawKoreanText(Value,X+34,Y+248,38,18);
			break;
		case 6: // Red
			C.DrawKoreanText(Value,X+75,Y+248,38,18);
			break;
		case 7: // Blue
			C.DrawKoreanText(Value,X+116,Y+248,38,18);
			break;
		case 8: // Yellow
			C.DrawKoreanText(Value,X+157,Y+248,38,18);
			break;
		case 9: // Black
			C.DrawKoreanText(Value,X+198,Y+248,38,18);
			break;
		case 10: // Skill
			ReqSkill = SephirothPlayer(PlayerOwner).QuerySkillByName(Skill.RequirementMap[i].SkillName);
			C.DrawKoreanText(ReqSkill.FullName,X+31,Y+294+ReqSkillIndex*20,121,12);
			C.DrawKoreanText(Value,X+160,Y+294+ReqSkillIndex*20,79,12);
			ReqSkillIndex++;
			break;
		}
	}

	C.SetDrawColor(255,255,163);
	C.DrawKoreanText(Skill.FullName,X+70,Y+24,125,17);
}

function OnRenderDragObject(Canvas C)
{
	local Skill S;
	local Texture Sprite;
	S = Skill(Controller.DragObject);
	if (S != None) {
//		Sprite = Texture(DynamicLoadObject("SepSkill.SkillIcon."$S.SkillName$"N",class'Texture'));
		Sprite = Texture(DynamicLoadObject("SkillSprites." $ Skill.BookName $ "." $ Skill.SkillName $ "N", class'Texture'));
		if (Sprite != None) {
			C.SetPos(Controller.MouseX-16,Controller.MouseY-16);
			C.DrawTile(Sprite,32,32,0,0,32,32);
		}
	}
}

function vector PushComponentVector(int CmpId)
{
	local vector V;
	switch (CmpId) {
	case 6:
		if (Skill != None && Skill.bHasSkillPoint) {
			V.Y = Skill.SkillPoint;
			V.Z = 100.0;
		}
		break;
	case 7:
		if (Skill != None) {
			V.Y = Skill.SkillLevel;
			V.Z = 100.0;
		}
		break;
	}
	return V;
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;
}

defaultproperties
{
     Components(0)=(XL=272.000000,YL=402.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=256.000000,YL=256.000000,PivotDir=PVT_Copy)
     Components(2)=(Id=2,ResId=1,Type=RES_Image,XL=16.000000,YL=256.000000,PivotId=1,PivotDir=PVT_Right)
     Components(3)=(Id=3,ResId=2,Type=RES_Image,XL=256.000000,YL=146.000000,PivotId=1,PivotDir=PVT_Down)
     Components(4)=(Id=4,ResId=3,Type=RES_Image,XL=16.000000,YL=146.000000,PivotId=1,PivotDir=PVT_DownRight)
     Components(5)=(Id=5,Type=RES_PushButton,XL=31.000000,YL=31.000000,PivotDir=PVT_Copy,OffsetXL=223.000000,OffsetYL=17.000000,HotKey=IK_Escape)
     Components(6)=(Id=6,ResId=6,Type=RES_Gauge,XL=95.000000,YL=12.000000,PivotDir=PVT_Copy,OffsetXL=143.000000,OffsetYL=74.000000,GaugeDir=GDT_Right)
     Components(7)=(Id=7,ResId=7,Type=RES_Gauge,XL=95.000000,YL=12.000000,PivotDir=PVT_Copy,OffsetXL=143.000000,OffsetYL=94.000000,GaugeDir=GDT_Right)
     TextureResources(0)=(Package="UI",Path="Skill.SkillInfoFrame_S00",Style=STY_Alpha)
     TextureResources(1)=(Package="UI",Path="Skill.SkillInfoFrame_S01",Style=STY_Alpha)
     TextureResources(2)=(Package="UI",Path="Skill.SkillInfoFrame_S02",Style=STY_Alpha)
     TextureResources(3)=(Package="UI",Path="Skill.SkillInfoFrame_S03",Style=STY_Alpha)
     TextureResources(4)=(Package="UI",Path="Common.ExitNormal",Style=STY_Alpha)
     TextureResources(5)=(Package="UI",Path="Common.ExitOver",Style=STY_Alpha)
     TextureResources(6)=(Package="UI",Path="Skill.SkillPointBar",U=1.000000,V=1.000000,UL=95.000000,VL=12.000000,Style=STY_Alpha)
     TextureResources(7)=(Package="UI",Path="Skill.SkillLevelBar",U=1.000000,V=1.000000,UL=97.000000,VL=12.000000,Style=STY_Alpha)
     bDragAndDrop=True
}
