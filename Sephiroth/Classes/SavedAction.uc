class SavedAction extends Info;

var bool bIsValid;
var SavedAction NextAction;	// linked list for next action, maximally 2 actions can be pushed
var name Sequence;			// saved action sequence
var byte ActionClass;		// saved action class (combo, finish, ...)
var int ComboCount;			// starting from ZERO to MaxComboCount - 1
var int MaxComboCount;		// allowed combo count
var float AnimRate;
var float AnimTweenTime;
var Controller TargetController;

function Valid() { bIsValid = True; }
function Invalid() { bIsValid = False; }
function bool IsValid() { return bIsValid; }

function SetAction(name AnimSeq,byte ActClass,int Step,int MaxCC,Controller Target,optional float Rate,optional float Tween)
{
	if (Rate == 0) Rate = 1.0;
	if (Tween == 0) Tween = 0.3;
	Sequence = AnimSeq;
	ActionClass = ActClass;
	ComboCount = Step;
	MaxComboCount = MaxCC;
	TargetController = Target;
	AnimRate = Rate;
	AnimTweenTime = Tween;
	NextAction = None;
}

function AddAction(name Sequence, byte ActionClass, int Step, int MaxCC, optional float Rate, optional float Tween)
{
	local SavedAction Action, ThisAction;
	
	if (Rate == 0) Rate = 1.0;
	if (Tween == 0) Tween = 0.3;

	Action = spawn(class'SavedAction');
	Action.Sequence = Sequence;
	Action.ActionClass = ActionClass;
	Action.ComboCount = Step;
	Action.MaxComboCount = MaxCC;
	Action.AnimRate = Rate;
	Action.AnimTweenTime = Tween;
	Action.NextAction = None;

	for (ThisAction = Self;ThisAction.NextAction != None;ThisAction = ThisAction.NextAction) ;
	ThisAction.NextAction = Action;
}

function RemoveAction()
{
	local SavedAction ThisAction;
	ThisAction = NextAction;
	if (ThisAction != None) {
		NextAction = ThisAction.NextAction;
		ThisAction.Destroy();
	}
}

function int GetActionCount()
{
	if (NextAction == None) return 1;
	return NextAction.GetActionCount() + 1;
}

function PlayAction(Character Character, int ActionStep)
{
	local SavedAction ThisAction;
	ThisAction = NextAction;
	if (ThisAction != None) {
		if (ThisAction.AnimRate == 0.0) ThisAction.AnimRate = 1.0;
		if (ThisAction.AnimTweenTime == 0.0) ThisAction.AnimTweenTime = 0.0;
//		//Log(ThisAction.Sequence@ActionStep);
		Character.PlayAnimAction(ThisAction.Sequence, ActionStep, ThisAction.AnimRate, ThisAction.AnimTweenTime);
//		Character.LastAction.Sequence = ThisAction.Sequence;
//		Character.LastAction.ComboCount = ActionStep+1;
	}
}

defaultproperties
{
}
