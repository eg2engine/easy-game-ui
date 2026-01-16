class AnimAction extends Object
	native
	hidecategories(Object)
	collapsecategories;

enum EActionClass
{
	AC_Combo,
	AC_Finish,
	AC_Magic,
	AC_Pain,
	AC_Knockback,
	AC_Idle,
	AC_Standup,
	AC_Walk,
	AC_Run,
	AC_Jump,
	AC_Threaten
};

struct native Action 
{
	var() name Sequence;
	var() int Frames;
	var() EActionClass ActionClass;
	var() float	AnimTime;
	var() array<float> ActionTime;
	var() float MoveRate;
	var() name PreparePivot;
	var() name CleanupPivot;
};

var() array<Action> Actions;

defaultproperties
{
}
