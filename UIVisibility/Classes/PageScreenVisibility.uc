class PageScreenVisibility extends PageScreen;
const CB_ShowShortcutUI = 120;
const CB_ShowBuffUI = 121;
function SephirothInterface GetVisibilityHUD()
{
    if (PlayerOwner == None || PlayerOwner.bDeleteMe) return None;
    if (PlayerOwner.myHUD == None || PlayerOwner.myHUD.bDeleteMe) return None;
    return SephirothInterface(PlayerOwner.myHUD);
}
function LoadOption()
{
    class'DisplaySettings'.static.RestoreSliders(PlayerOwner);
    Super.LoadOption();
}
function SaveOption()
{
    Super.SaveOption();
    class'DisplaySettings'.static.SaveSliders(FogRatio,Distance);
}
function OnPreRender(Canvas C)
{
    local float PreviousFog;
    local int PreviousDistance;
    PreviousFog=FogRatio;
    PreviousDistance=Distance;
    Super.OnPreRender(C);
    if (FogRatio != PreviousFog || Distance != PreviousDistance)
        class'DisplaySettings'.static.SaveSliders(FogRatio,Distance);
}
function OnInit()
{
    Super.OnInit();
    SetComponentNotify(Components[40], CB_ShowShortcutUI, Self);
    SetComponentNotify(Components[41], CB_ShowBuffUI, Self);
}
function UpdateComponents()
{
    Super.UpdateComponents();
    Components[40].bDisabled = (GetVisibilityHUD() == None);
    Components[41].bDisabled = (GetVisibilityHUD() == None);
}
function bool PushComponentBool(int CmpId)
{
    if (CmpId == 41) return !class'VisibilitySettings'.default.bHideBuffUI;
    if (CmpId == 40) return !class'VisibilitySettings'.default.bHideShortcutUI;
    return Super.PushComponentBool(CmpId);
}
function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
    if (NotifyId == CB_ShowBuffUI)
    {
        if (GetVisibilityHUD() == None) return;
        if (Command != "Checked" && Command != "UnChecked") return;
        class'VisibilitySettings'.static.SaveVisibility(21,Command == "Checked");
        UpdateComponents();
        return;
    }
    if (NotifyId == CB_ShowShortcutUI)
    {
        if (GetVisibilityHUD() == None) return;
        if (Command != "Checked" && Command != "UnChecked") return;
        class'VisibilitySettings'.static.SaveVisibility(20,Command == "Checked");
        class'VisibilitySettings'.static.ApplyShortcutUI(GetVisibilityHUD());
        UpdateComponents();
        return;
    }
    Super.NotifyComponent(CmpId,NotifyId,Command);
}

defaultproperties
{
     DistanceData=(FMin=0.000000)
     FogRatioData=(FMin=0.000000)
     Components(40)=(Id=40,Caption="显示快捷键栏",Type=RES_CheckButton,XL=26.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=208.000000,OffsetYL=204.000000,TextAlign=TA_MiddleLeft)
     Components(41)=(Id=41,Caption="显示BUFF图标",Type=RES_CheckButton,XL=26.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=208.000000,OffsetYL=353.000000,TextAlign=TA_MiddleLeft)
}
