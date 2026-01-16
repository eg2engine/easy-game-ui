class TeamBattleMessage extends CMessageBox;

//=============================================================================
// modified by yj
// CMessageBox 기능 + 남은 시간 rendering을 위한 class
//=============================================================================

var int RemainingSec;
var int RemainingSec_UpdatedTime;
var string MatchName;


static function CMessageBox MessageBox(CMultiInterface Parent,coerce string Title,coerce string Message,EMessageBoxType Type,optional int NotifyId,optional bool bNoHotkey, optional EMessageBoxPos Pos, optional bool bNoBlockParentKeyEvent)
{
	local CMessageBox MsgBox;
	MsgBox = CMessageBox(Parent.Controller.HudInterface.AddInterface("SephirothUI.TeamBattleMessage",!bNoBlockParentKeyEvent));

	if (MsgBox != None) {
		MsgBox.PosMode = Pos;		//modified by yj

		MsgBox.NotifyValue = NotifyId;
		MsgBox.bNoHotkey = bNoHotkey;
		MsgBox.BoxType = Type;
		MsgBox.Title=Title;
		MsgBox.ShowInterface();
		MsgBox.SetMessage(Message);
		MsgBox.NotifyTarget = Parent;
		Parent.bIgnoreKeyEvents = !bNoBlockParentKeyEvent;
	}
	return MsgBox;
}

function UpdateRemain_sec(int remaining_sec)
{
	RemainingSec = remaining_sec;
	RemainingSec_UpdatedTime = Level.TimeSeconds;
}

function OnPostRender(HUD H, Canvas C)
{
	local int PassedSec_SinceUpdated;
	local int RemainingTime;

	PassedSec_SinceUpdated = Level.TimeSeconds - RemainingSec_UpdatedTime;

	RemainingTime = RemainingSec-PassedSec_SinceUpdated;

	if( RemainingTime <= 0 )		//서버로부터 종료메시지를 전달받지 못해도 꺼지도록.
		CloseBox(-1*NotifyValue);

	Super.OnPostRender(H,C);
	C.DrawKoreanText("남은 시간 : "$RemainingTime/60$"분 "$int(RemainingTime%60)$"초",Components[2].X,Components[2].Y+TextLines*14,Components[2].XL,18);	
}

function ResetDefaultPosition()
{
	bNeedLayoutUpdate = true;
}

defaultproperties
{
}
