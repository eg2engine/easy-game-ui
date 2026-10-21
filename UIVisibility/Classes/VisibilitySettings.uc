#exec OBJ LOAD FILE=Sephiroth.u
#exec OBJ LOAD FILE=SephirothUI.u
class VisibilitySettings extends Object config(SephirothUI);
var config bool bHideMinimap;
var config bool bHideChat;
var config bool bHidePetUI;
var config bool bHideShortcutUI;
var config bool bHideBuffUI;

static function SaveVisibility(int ControlId, bool bShow)
{
    if (ControlId == 18) Default.bHideMinimap = !bShow;
    else if (ControlId == 19) Default.bHideChat = !bShow;
    else if (ControlId == 20) Default.bHideShortcutUI = !bShow;
    else if (ControlId == 21) Default.bHideBuffUI = !bShow;
    else if (ControlId == 100) Default.bHidePetUI = !bShow;
    else return;
    StaticSaveConfig();
}

static function ApplyShortcutUI(SephirothInterface UI)
{
    if (UI == None || UI.bDeleteMe) return;
    UI.HideMiniShortcut();
    UI.HideSimpleInterface();
    if (Default.bHideShortcutUI)
    {
        UI.HideMainInterface();
        UI.HideGaugeInterface();
    }
    else
    {
        // These functions select Type1/Type2 from the existing UIType.
        UI.ShowMainInterface();
        UI.ShowGaugeInterface();
        UI.MoveGaugeInterface(0,4);
    }
}

static function ToggleShortcutUI(SephirothInterface UI)
{
    if (UI == None || UI.bDeleteMe) return;
    SaveVisibility(20,Default.bHideShortcutUI);
    ApplyShortcutUI(UI);
}

static function InstallBuffUI(SephirothInterface UI)
{
    if (UI == None || UI.bDeleteMe) return;
    if (UI.Buff != None && !UI.Buff.bDeleteMe)
        UI.RemoveInterface(UI.Buff);
    UI.Buff = BuffIcon(UI.AddInterface("UIVisibility.BuffIconVisibility"));
    if (UI.Buff != None && !UI.Buff.bDeleteMe)
        UI.Buff.ShowInterface();
}

static function RestoreUI(SephirothInterface UI)
{
    local SephirothPlayer P;
    if (UI == None || UI.bDeleteMe) return;
    P = SephirothPlayer(UI.PlayerOwner);
    if (Default.bHideMinimap)
        UI.HideMinimap();
    else if (P != None && !P.bDeleteMe && P.ZSI != None && !P.ZSI.bDeleteMe)
    {
        if (P.ZSI.bUnderSiege || P.ZSI.bNoMinimap) UI.HideMinimap();
        else UI.ShowMinimap();
    }
    if (Default.bHideChat)
        UI.MakeInvisibleChannelManager();
    else
        UI.MakeVisibleChannelManager();
    ApplyShortcutUI(UI);
    class'DisplaySettings'.static.RestoreSliders(UI.PlayerOwner);
}

defaultproperties
{
}
