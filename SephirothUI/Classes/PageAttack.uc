class PageAttack extends COptionPage
	config(Plugin);
//cs 
const CK_AutoAttack	    = 1;
const CK_AutoEnchant    = 2;
const CK_AutoEnchant1    = 3;
const CK_AutoEnchant2    = 4;

var config bool bPluginAutoAttack;
//var config array<bool> bPluginAutoEnchant;
var config bool bPluginAutoEnchant;
var config bool bPluginAutoEnchant1;
var config bool bPluginAutoEnchant2;

var int JobType;

var config array<string> Skills;
var config array<string> Skills1;
var config array<string> Skills2;
const JobBareIndex = 0;
const JobOneHandIndex = 1;
const JobBowIndex = 2;
const JobRedIndex = 3;
const JobBlueIndex = 4;
const JobMaxIndex = 5;


var SephirothPlayer Player;

/*

struct _SlideData
{
	var float fMin;
	var float fMax;
	var float fCur;
};

struct _item
{
	var string strLocaleName;
	var bool bSelected;
};




const _ListLine = 10;//12;
const _TEXT_H = 14;//16;
*/
//var float timeUpdateNearItemsDelay;
//var CTextScroll CurrentItems;
//var array<_item> arraySkills;
//var int nStartCurrentItem;
//var float VLine;


function LoadOption()
{

}

function ApplyEffect()
{

}

function SaveOption()
{
}

static function int GetJobTypeFromJobName(name JobName){

	if(JobName == 'Bare')
		return JobBareIndex;
	else if(JobName == 'OneHand')
		return JobOneHandIndex;
	else if(JobName == 'Bow')
		return JobBowIndex;
	else if(JobName == 'Red')
		return JobRedIndex;
	else if(JobName == 'Blue')
		return JobBlueIndex;
	else{
		//error
		return -1;
	}
}

function OnInit()
{

	Player = SephirothPlayer(PlayerOwner);
	JobType = GetJobTypeFromJobName(Player.PSI.JobName);
	if(JobType < 0){
		//todo:
		class'CMessageBox'.static.MessageBox(Self,"","",MB_Ok);
		return; //error
	}

	//auto Attack switch
	SetComponentNotify(Components[4],CK_AutoAttack,Self);
	SetComponentNotify(Components[7],CK_AutoEnchant,Self);
	SetComponentNotify(Components[9],CK_AutoEnchant1,Self);
	SetComponentNotify(Components[11],CK_AutoEnchant2,Self);


	/*	//@by wj(03/04)----------
	local Skill MagicSkill;
	local Skill ThisSkill;
	local SephirothPlayer CC;
	local SephirothPlayer OtherCC;
	local MonsterServerInfo MSI;
	local NpcServerInfo NSI;

	CC = SephirothPlayer(ViewportOwner.Actor);

	MagicSkill = SephirothPlayer(ViewportOwner.Actor).PSI.Magic;
	ThisSkill = SephirothPlayer(ViewportOwner.Actor).ThisSkill;

	if (Actor.IsA('Creature')) {
		MSI = MonsterServerInfo(ServerController(Creature(Actor).Controller).MSI);
		NSI = NpcServerInfo(ServerController(Creature(Actor).Controller).MSI);
	}

	if (Actor == ViewportOwner.Actor.Pawn && MagicSkill != None && MagicSkill.bSelf)
		return FR_Enchantable;
	//-----------------------
	if (Actor == ViewportOwner.Actor.Pawn)
		return FR_Self;	
	if (Actor.bWorldGeometry || Actor.IsA('TerrainInfo') || Actor.IsA('StaticMeshActor'))
		return FR_Movable;	

	if (MSI != None && ThisSkill != None && ThisSkill.bEnchant && !ThisSkill.bSelf)
		return FR_Enchantable;
	if (NSI != None)
		return FR_Talkable;

	//@by wj(04/15)------
	if (Actor.IsA('Hero') && ThisSkill != None && ThisSkill.bEnchant && !ThisSkill.bSelf)

		return FR_Enchantable;	*/

	if(JobType != JobRedIndex){
		bPluginAutoEnchant1 = false;
		bPluginAutoEnchant2 = false;
	}

	UpdateComboSkillsData();	
}

function OnFlush()
{


}


function Layout(Canvas C)
{
	Super.Layout(C);
}

function UpdateComponents()
{


}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{

	//combo get wrong for moving window
	if (Key == IK_LeftMouse){
		if(IsCursorInsideComponent(Components[8])||IsCursorInsideComponent(Components[10])||IsCursorInsideComponent(Components[12]))
		{
			return true;	
		}
	}
	super.OnKeyEvent(Key,Action,Delta);
}

function bool PushComponentBool(int CmpId)
{
	
	switch(CmpId)
	{
	case 4:
		return bPluginAutoAttack;   break;
	case 7:
		return bPluginAutoEnchant;   break;
	case 9:
		return bPluginAutoEnchant1;   break;
	case 11:
		return bPluginAutoEnchant2;   break;

	default:
		return false;
	}
}

function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{

}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	local bool bTemp;

	if(NotifyID == CK_AutoAttack){
		bPluginAutoAttack = !bPluginAutoAttack;
		SephirothController(Controller).bPluginAutoAttackEnabled = bPluginAutoAttack;
	}

	if(NotifyID == CK_AutoEnchant){
		bTemp = bPluginAutoEnchant;
		//PlayerOwner.myHud.AddMessage(1,"bTemp"@bTemp,class'Canvas'.static.MakeColor(200,100,200));
		bPluginAutoEnchant = !(bTemp);
		UpdateCurrentSkills(JobType,8);
		SephirothController(Controller).bPluginAutoEnChantEnabled = bPluginAutoEnchant;
		//UpdateCurrentSkills(JobType,8);
		//PlayerOwner.myHud.AddMessage(1,"CK_AutoEnchant"@string(bPluginAutoEnchant),class'Canvas'.static.MakeColor(200,100,200));
	}

	if(NotifyID == CK_AutoEnchant1){
		bTemp = bPluginAutoEnchant1;
		//PlayerOwner.myHud.AddMessage(1,"bTemp"@bTemp,class'Canvas'.static.MakeColor(200,100,200));
		bPluginAutoEnchant1 = !(bTemp);
		UpdateCurrentSkills(JobType,10);
		SephirothController(Controller).bPluginAutoEnChantEnabled1 = bPluginAutoEnchant1;
		//UpdateCurrentSkills(JobType,10);
		//PlayerOwner.myHud.AddMessage(1,"CK_AutoEnchant1"@string(bPluginAutoEnchant1),class'Canvas'.static.MakeColor(200,100,200));
	}

	if(NotifyID == CK_AutoEnchant2){
		bPluginAutoEnchant2 = !(bPluginAutoEnchant2);
		UpdateCurrentSkills(JobType,12);
		SephirothController(Controller).bPluginAutoEnChantEnabled2 = bPluginAutoEnchant2;
		//UpdateCurrentSkills(JobType,12);
		//PlayerOwner.myHud.AddMessage(1,"CK_AutoEnchant2"@string(bPluginAutoEnchant2),class'Canvas'.static.MakeColor(200,100,200));
	}

	SaveConfig();
}

function OnComboUpdate(int CmpId)
{

	//class'CMessageBox'.static.MessageBox(Self,"Disconnected",strTest,MB_Ok);
	switch(CmpId)
	{
	case 8:
		Skills[JobType] = Components[8].Caption;
		break;
	case 10:
		Skills1[JobType] = Components[10].Caption;
		break;
	case 12:
		Skills2[JobType] = Components[12].Caption;
		break;

	default:
		break;
	}
	SaveConfig();
}



function bool UpdateCurrentSkills(int JobType,int ComboComponentId)
{

	//local int ComboComponentId;
	local int i,j;
	local Skill CurSkill;
	local bool bPluginAutoEnchantSwitch;
	local array<string> CurSkills;


	if(ComboComponentId == 8) {CurSkills = Skills; bPluginAutoEnchantSwitch = bPluginAutoEnchant; }
	if(ComboComponentId == 10) {CurSkills = Skills1; bPluginAutoEnchantSwitch = bPluginAutoEnchant1; }
	if(ComboComponentId == 12) {CurSkills = Skills2; bPluginAutoEnchantSwitch = bPluginAutoEnchant2; }

	EmptyDropDownMenu(Components[ComboComponentId]);
	if(!bPluginAutoEnchantSwitch) return false;

	for (i=0;i<Player.PSI.SkillBooks.Length;++i) {
		for(j=0;j < Player.PSI.SkillBooks[i].Skills.Length;++j){
			CurSkill = Player.PSI.SkillBooks[i].Skills[j];
			if(CurSkill != none && CurSkill.bLearned &&( (CurSkill.bSelf && CurSkill.bEnchant) || CurSkill.IsA('SpiritSkill') ) ){ //所有已学到的且可以为自己使用的技能
				AddDropDownMenu(Components[ComboComponentId],CurSkill.FullName);
			}
		}
	}

	for(i=0;i<Components[ComboComponentId].ListBoxItems.Length;++i){
		if(Components[ComboComponentId].ListBoxItems[i] == CurSkills[JobType]){
			//EffectDetail = GetComboBoxIndex(Components[12]);
			//Components[12].Caption = EffectOptionList[EffectDetail];
			SetComboBoxCurrent(Components[ComboComponentId], i);
		}
	}
	CurSkills[JobType]=Components[ComboComponentId].Caption;
	SaveConfig();

	return true;

	/*
	switch(JobType){
	case SkillType:

		break;

	default:
		return false;
	}

	SaveConfig();*/
}

function bool UpdateComboSkillsData(){
	UpdateCurrentSkills(JobType,8);
	if(JobType == JobRedIndex){
		UpdateCurrentSkills(JobType,10);
		UpdateCurrentSkills(JobType,12);
	}
	return true;
}


function DrawComboBack(int CmpId,Canvas C,Texture txBack)
{
	C.SetPos(Components[CmpId].X-5, Components[CmpId].Y-5);
//	C.DrawTile(Texture(DynamicLoadObject("UI_2011.input_bg",class'Texture')),
//		Components[21].XL,Components[21].YL,0,0,Components[21].XL,Components[21].YL);
	C.DrawTile(txBack,Components[CmpId].XL,Components[CmpId].YL,0,0,Components[CmpId].XL,Components[CmpId].YL);
}

function OnPreRender(Canvas C)
{
//	local float X,Y,W,H;
//	local float fTemp;
	local int nTemp;
	local Texture txInputBack;

	C.SetRenderStyleAlpha();
	Super.OnPreRender(C);

	txInputBack = Texture(DynamicLoadObject("UI_2011.input_op_bg",class'Texture'));
	//if(JobType == JobRedIndex){
		DrawComboBack(8,C,txInputBack);
		DrawComboBack(10,C,txInputBack);
		DrawComboBack(12,C,txInputBack);
	//}

	if(JobType != JobRedIndex){
		Components[9].bDisabled = True;
		Components[10].bDisabled = True;
		Components[11].bDisabled = True;
		Components[12].bDisabled = True;
	}
	

}

function OnPostRender(HUD H, Canvas C)
{

}

function RePosition()
{
	SephirothInterface(SephirothPlayer(PlayerOwner).myHUD).SetDefaultUIPosition();
}

defaultproperties
{
     PageWidth=391.000000
     PageHeight=423.000000
     Components(0)=(XL=391.000000,YL=423.000000)
     Components(1)=(Id=1,Caption="PluginAutoAttack",Type=RES_Text,XL=60.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=15.000000,OffsetYL=68.000000,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(3)=(Id=3,Caption="PluginUse",Type=RES_Text,XL=100.000000,YL=20.000000,PivotId=1,PivotDir=PVT_Right,OffsetXL=60.000000,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(4)=(Id=4,Caption="PluginAutoAttack",Type=RES_CheckButton,XL=40.000000,YL=20.000000,PivotId=1,PivotDir=PVT_Down,OffsetYL=2.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
     Components(5)=(Id=5,Caption="PluginAutoAttckUse",Type=RES_Text,XL=280.000000,YL=20.000000,PivotId=3,PivotDir=PVT_Down,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(6)=(Id=6,Caption="PluginAutoCastUse",Type=RES_Text,XL=280.000000,YL=20.000000,PivotId=5,PivotDir=PVT_Down,TextAlign=TA_MiddleLeft,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(7)=(Id=7,Caption="PluginAutoEnchant",Type=RES_CheckButton,XL=40.000000,YL=20.000000,PivotId=4,PivotDir=PVT_Down,OffsetYL=22.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
     Components(8)=(Id=8,Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=6,PivotDir=PVT_Down,OffsetYL=8.000000)
     Components(9)=(Id=9,Caption="PluginAutoEnchant",Type=RES_CheckButton,XL=40.000000,YL=20.000000,PivotId=7,PivotDir=PVT_Down,OffsetYL=9.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
     Components(10)=(Id=10,Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=8,PivotDir=PVT_Down,OffsetYL=8.000000)
     Components(11)=(Id=11,Caption="PluginAutoEnchant",Type=RES_CheckButton,XL=40.000000,YL=20.000000,PivotId=9,PivotDir=PVT_Down,OffsetYL=9.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
     Components(12)=(Id=12,Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=10,PivotDir=PVT_Down,OffsetYL=8.000000)
     bNeedLayoutUpdate=False
}
