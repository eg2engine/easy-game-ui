#exec OBJ LOAD FILE=Sephiroth.u
#exec OBJ LOAD FILE=SephirothUI.u
class PageGameVisibility extends PageGame;
var bool bShowMinimapUI;
var bool bShowChatUI;
const CB_ShowMinimapUI = 18;
const CB_ShowChatUI = 19;

function SephirothInterface GetVisibilityHUD()
{
    if (PlayerOwner == None || PlayerOwner.bDeleteMe)
        return None;
    if (PlayerOwner.myHUD == None || PlayerOwner.myHUD.bDeleteMe)
        return None;
    return SephirothInterface(PlayerOwner.myHUD);
}

// Reflect the current HUD, including visibility changes made by hotkeys.
function LoadUIVisibility()
{
    local SephirothInterface UI;
    UI = GetVisibilityHUD();
    bShowMinimapUI = false;
    bShowChatUI = false;
    if (UI == None)
        return;
    if (UI.m_MiniMap != None && !UI.m_MiniMap.bDeleteMe)
        bShowMinimapUI = UI.m_MiniMap.bVisible;
    if (UI.ChannelMgr != None && !UI.ChannelMgr.bDeleteMe)
        bShowChatUI = !UI.ChannelMgr.IsInvisible();
}

function ApplyUIVisibility(int NotifyId, bool bChecked)
{
    local SephirothInterface UI;
    local SephirothPlayer P;
    UI = GetVisibilityHUD();
    P = SephirothPlayer(PlayerOwner);
    if (UI == None || P == None || P.bDeleteMe)
        return;
    if (NotifyId == CB_ShowMinimapUI)
    {
        if (bChecked)
        {
            // Keep the same zone restrictions as Ctrl+M.
            if (P.ZSI == None || P.ZSI.bDeleteMe)
                return;
            if (P.ZSI.bUnderSiege || P.ZSI.bNoMinimap)
            {
                UI.AddMessage(1, Localize("Information", "CannotUseRadarUnderSiege", "Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
                return;
            }
            if (UI.m_MiniMap != None && UI.m_MiniMap.bDeleteMe)
                UI.m_MiniMap = None;
            UI.ShowMinimap();
        }
        else if (UI.m_MiniMap != None && !UI.m_MiniMap.bDeleteMe)
            UI.HideMinimap();
    }
    else if (NotifyId == CB_ShowChatUI)
    {
        if (bChecked)
        {
            if (UI.ChannelMgr == None || UI.ChannelMgr.bDeleteMe)
            {
                UI.ChannelMgr = None;
                UI.ShowChannelManager();
            }
            UI.MakeVisibleChannelManager();
        }
        else if (UI.ChannelMgr != None && !UI.ChannelMgr.bDeleteMe)
            UI.MakeInvisibleChannelManager();
    }
}


function LoadOption()
{
    Super.LoadOption();
    LoadUIVisibility();
}
function OnInit()
{
    Super.OnInit();
    SetComponentNotify(Components[18], CB_ShowMinimapUI, Self);
    SetComponentNotify(Components[19], CB_ShowChatUI, Self);
}
function UpdateComponents()
{
    Super.UpdateComponents();
    Components[18].bDisabled = (GetVisibilityHUD() == None);
    Components[19].bDisabled = (GetVisibilityHUD() == None);
}
function bool PushComponentBool(int CmpId)
{
    if (CmpId == CB_ShowMinimapUI) return bShowMinimapUI;
    if (CmpId == CB_ShowChatUI) return bShowChatUI;
    return Super.PushComponentBool(CmpId);
}
function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
    if (NotifyId == CB_ShowMinimapUI || NotifyId == CB_ShowChatUI)
    {
        if (GetVisibilityHUD() == None) return;
        ApplyUIVisibility(NotifyId, Command == "Checked");
        LoadUIVisibility();
        // Save the actual result, including a rejected minimap request.
        if (NotifyId == CB_ShowMinimapUI)
            class'VisibilitySettings'.static.SaveVisibility(NotifyId, bShowMinimapUI);
        else
            class'VisibilitySettings'.static.SaveVisibility(NotifyId, bShowChatUI);
        UpdateComponents();
        return;
    }
    Super.NotifyComponent(CmpId,NotifyId,Command);
}

defaultproperties
{
     Components(18)=(Id=18,Caption="显示小地图",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=342.000000,TextAlign=TA_MiddleCenter)
     Components(19)=(Id=19,Caption="显示聊天栏",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=207.000000,OffsetYL=207.000000,TextAlign=TA_MiddleCenter)
}
