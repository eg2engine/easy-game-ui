class SephirothOption extends ClientOption
	native
	noexport;

var(Screen) string Resolution;
var(Screen) int bRenderSky;
var(Screen) int bRenderShadow;
var(Screen) int ShadowType;
var(Screen) float ShadowDist;
var(Screen) int bFullscreen;
var(Screen) int bUseGraphicCursor;
var(Screen) float FogRatio;
var(Screen) float FilterDistance;
var(Screen) int bShowDeadEffect;

var(Sound) int bListenMusic;
var(Sound) float MusicVolume;
var(Sound) int bListenSound;
var(Sound) float SoundVolume;

var(Game) int bArmHelmet;
var(Game) int bPinMinimap;
var(Game) int bShowTooltip;
var(Game) int bTraceCamera;
var(Game) int ViewType;
var(Game) int bShowNameAlways;
var(Game) int bListenPartyInvite;
var(Game) int bListenPartyJoin;
var(Game) int bListenClanInvite;
var(Game) int bListenClanJoin;
var(Game) int bListenExchangeRequest;
var(Game) int bShowNpcName;
var(Game) int bShowMonsterName;
var(Game) int bShowItemName;

var(Chatting) int bListenMessage;
var(Chatting) int bListenShout;
var(Chatting) int bListenYell;
var(Chatting) int bListenWhisper;
var(Chatting) int bEraseMessage;
var(Chatting) int bListenTip;

var(Interface) int Turn180;
var(Interface) int bTurn180KeyOnly;
var(Interface) int RotateView;
var(Interface) float CameraTurnSpeed;
var(Interface) int bUseEdgeTurn;

defaultproperties
{
     Resolution="1024x768"
     ShadowType=2
     ShadowDist=1000.000000
     MusicVolume=1.000000
     SoundVolume=1.000000
}
