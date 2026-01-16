class ClientCheat extends CheatManager within ClientController;

exec function OffsetCamera(int offset)
{
	if (ZSI != None && !ZSI.bUnderSiege) {
	CameraHeight = clamp(CameraHeight + offset, -300, 300);
	}
}

exec function BiasCamera(int offset)
{
	if (ZSI != None && !ZSI.bUnderSiege) {
	CameraBias = clamp(CameraBias + offset, -300, 300);
	}
}

exec function ResetCamera()
{
	CameraHeight = 44;
	CameraBias = 0;
}

exec function ZoomCamera(int zoom)
{
	local Rotator rot;
	
//	//Log("ZoomCamera"@zoom@ViewType);

	if (ViewType != FirstPerson) {
		CameraDist = clamp(CameraDist + zoom, MinCameraDist, MaxCameraDist);
		// chkim for camera ....
		if( ViewType == QuaterView ) {
			rot = Rotation;
			rot.Pitch = -8192.0 * (CameraDist-MinCameraDist)/(MaxCameraDist-MinCameraDist);
			SetRotation(rot);
		}
	}
	//Log("CameraDist"@CameraDist);
}

exec function SetCameraRange(int Min, int Max)
{
	local int Temp;

	if (Min < 0)
		Min = 0;
	if (Min > Max) {
		Temp = Min;
		Min = Max;
		Max = Temp;
	}
	MinCameraDist = Min;
	MaxCameraDist = Max;
}

exec function NewCharacter(string CharName)
{
	local class<Character> CharClass;
	local Character Char;
	local rotator rot;

	rot = Rotation;
	rot.Yaw += 32768;
	CharClass = class<Character>(DynamicLoadObject(CharName, class'Class'));
	Char = Spawn(CharClass,,,Pawn.Location + (1000 * vect(1, 0, 0) >> Pawn.Rotation), rot);
	Char.NetRecv_BeginPlay();
}

exec function Anim(name Name, name AnimName)
{
	local actor Actor;
	if (Name == 'Self') Actor = Pawn;
	else Actor = FindActor(Name);
	if (Pawn(Actor) != None) {
		Pawn(Actor).PlayAnim(AnimName);
		Pawn(Actor).SetAnimFrame(0.5);
	}
}

exec function Arm(name Name)
{
	local actor Actor;
	if (Name == 'Self') Actor = Pawn;
	else Actor = FindActor(Name);
	if (Hero(Actor) != None) {
		Hero(Actor).Arm();
	}
}

exec function DisArm(name Name)
{
	local actor Actor;
	if (Name == 'Self') Actor = Pawn;
	else Actor = FindActor(Name);
	if (Hero(Actor) != None) {
		Hero(Actor).DisArm();
	}
}

exec function Server()
{
	ConsoleCommand("connect host=im09 port=2246");
	ConsoleCommand("login id=hanullo password=hanullo");
}

exec function SetFOV(float fov)
{
	FOVAngle = fov;
	DesiredFOV = fov;
	DefaultFOV = fov;
}

exec function MoneyString(int Money)
{
	local string Result;
	local int D, R;

	D = Money;
	while (D > 1000) {
		R = D % 1000;
		D = D / 1000;
		if (D > 1000)
			Result = ","$R$Result;
		else
			Result = string(R)$Result;
	}
	Result = string(D)$Result;
}

exec function ComboSkill(string Skill)
{
	SetHotSkill(0,Skill);
}

exec function FinishSkill(string Skill)
{
	SetHotSkill(1,Skill);
}

exec function MagicSkill(string Skill)
{
	SetHotSkill(2,Skill);
}

exec function ScriptActionTest()
{
	NewCharacter("Heroes.HumanMale");
	ComboSkill("ComboSplash");
	FinishSkill("OH_Concentration");
	MagicSkill("FireArrow");
	Hero(Pawn).SetSword("AcainSword");
	Arm('Self');
}

exec function BlockFlag(name target)
{
	local int Flag;
	if (target == 'Message') Flag = BLOCK_Message;
	if (target == 'Tell') Flag = BLOCK_Tell;
	if (target == 'Shout') Flag = BLOCK_Shout;
	if (target == 'Yell') Flag = BLOCK_Yell;
	if (target == 'Whisper') Flag = BLOCK_Whisper;
	if (target == 'BGM') Flag = BLOCK_BGM;
	if (target == 'Sound') Flag = BLOCK_Sound;
	Block(Flag);
}

exec function UnblockFlag(name target)
{
	local int Flag;
	if (target == 'Message') Flag = BLOCK_Message;
	if (target == 'Tell') Flag = BLOCK_Tell;
	if (target == 'Shout') Flag = BLOCK_Shout;
	if (target == 'Yell') Flag = BLOCK_Yell;
	if (target == 'Whisper') Flag = BLOCK_Whisper;
	if (target == 'BGM') Flag = BLOCK_BGM;
	if (target == 'Sound') Flag = BLOCK_Sound;
	Unblock(Flag);
}

exec function SU( string ClassName )	// switch user
{
	local class<Pawn> PawnClass;
	local Pawn PawnActor;
	local vector PawnLoc;

	PawnClass = class<Pawn>( DynamicLoadObject( ClassName, class'Class' ) );
	if( PawnClass == None ) return;


	if ( Pawn != None ) {
		PawnLoc = Pawn.Location;
		PawnActor = Pawn;
		UnPossess();
		PawnActor.Destroy();
	}
	else PawnLoc = Location;
	
	PawnActor = Spawn( PawnClass,,,PawnLoc + vect(0,0,1) * 50 );
	Possess(PawnActor);
}

exec function Land()
{
	Pawn.SetPhysics(PHYS_Walking);
	Pawn.DoJump(true);
}

exec function DoAct(name Anim)
{
	Pawn.GotoState('ActingAttack');
	Character(Pawn).CHAR_PlayAnim(Anim);
}

exec function Resurrect(int place,int bDead) { Net.NotiResurrectAt(place,bDead); }
exec function BGM(string song) { Outer.PlayMusic( song , 10.0 ); }

exec function OtherCombo(name Other, string SkillName, int No)
{
	local Pawn Pawn;
	local ClientController Controller;
	Pawn = Pawn(FindActor(Other));
	if (Pawn != None) {
		Controller = ClientController(Pawn.Controller);
		if (Controller != None && Controller.PSI != None)
			Controller.NetRecv_ActMeleeCombo(SkillName,None,vect(0,0,0),1.0,No);
	}
}

exec function OtherFinish(name Other, string SkillName)
{
	local Pawn Pawn;
	local ClientController Controller;
	Pawn = Pawn(FindActor(Other));
	if (Pawn != None) {
		Controller = ClientController(Pawn.Controller);
		if (Controller != None && Controller.PSI != None)
			Controller.NetRecv_ActMeleeFinish(SkillName,None,vect(0,0,0),1.0);
	}
}

exec function SaveEnv()
{
	GameManager(Level.Game).Environment.SaveToINI();
}

exec function ChangeInfoDisplayMode()
{
	ConsoleCommand("NameDisplayChange");
}

exec function AddPortal(name Zone,int X,int Y)
{
	local ClientPortal Portal;
	if (Zone == '')
		return;
	if (X == 0 || Y == 0) {
		X = Pawn.Location.X;
		Y = Pawn.Location.Y;
	}
	Portal = Outer.Spawn(class'ClientPortal', Outer);
	if (Portal != None) {
		Portal.AddPortal(Zone, X, Y);
		Portal.Destroy();
		Portal = None;
	}
}

exec function ShowMe()
{
	PSI.PlayMode = 0;
	PlayModeChanged();
}

exec function HideMe()
{
	PSI.PlayMode = 1;
	PlayModeChanged();
}

exec function Animate(name Seq,int Index)
{
	Character(Pawn).PlayAnimAction(Seq,Index,1.0,0.3);
}

exec function AnimateSolo(name Seq)
{
	Pawn.PlayAnim(Seq);
}

exec function TestAddInt64()
{
	local string c;
	c = AddInt64("1000000000000", "2000000000000");
	//Log(c);
}
exec function TestSubInt64()
{
	local string c;
	c = SubInt64("1000000000000", "2000000000000");
	//Log(c);
}
exec function TestMulInt64()
{
	local string c;
	c = MulInt64("10000000000", "2000000");
	//Log(c);
}

exec function SetSpeed( float F )
{
	Pawn.GroundSpeed = Pawn.GroundSpeed * f;
	Pawn.WaterSpeed = Pawn.WaterSpeed * f;
}

exec function SetBaseSpeed( float F )
{
	Pawn.GroundSpeed = Pawn.Default.GroundSpeed * f;
	Pawn.WaterSpeed = Pawn.Default.WaterSpeed * f;
}

defaultproperties
{
}
