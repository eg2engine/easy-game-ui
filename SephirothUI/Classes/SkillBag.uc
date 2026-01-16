class SkillBag extends CMultiInterface;

var CSkillTree SkillTree;
//var SkillInfo SkillInfo;

function OnInit()
{
//	SkillInfo = SkillInfo(AddInterface("SephirothUI.SkillInfo"));
//	if (SkillInfo != None)
//		SkillInfo.ShowInterface();
	SkillTree = CSkillTree(AddInterface("SephirothUI.CSkillTree"));
	if (SkillTree != None)
		SkillTree.ShowInterface();
}

function OnFlush()
{
	if (SkillTree != None) {
		SkillTree.HideInterface();
		RemoveInterface(SkillTree);
		SkillTree = None;
	}
//	if (SkillInfo != None) {
//		SkillInfo.HideInterface();
//		RemoveInterface(SkillInfo);
//		SkillInfo = None;
//	}
}

//function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
//{
//	if (Interface == SkillInfo && NotifyType == INT_Close)
//		Parent.NotifyInterface(Self, INT_Close);
//}

defaultproperties
{
     bIgnoreKeyEvents=True
}
