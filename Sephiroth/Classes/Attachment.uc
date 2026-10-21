// 维护装备挂件及关联效果，销毁前先停止黑金辅助对象。
class Attachment extends Actor
	native
	placeable;

/* Animation */
var(Animation) name BaseAnim;
var(Animation) bool bAnimate;

/* Attachment */
struct native AttachmentSlot
	{
	var() name Bone;
	var() vector Scale;
	var() vector Location;
	var() rotator Rotation;
};

var() SephirothItem Info;
var(Effect) Emitter GroundEffect;
var(Attachment) array<AttachmentSlot> AttachmentSlots;
var(Display) array<string> SkinNames;
var(Display) array<Material> SkinMaterials;
var(Collision) vector HitPoint;
var(Collision) vector HitExtent;

var(Effect) bool bTrackLocation;
var(Effect) class<MotionTrace> MTClass;
var(Effect) MotionTrace MotionTrace;
var(Effect) Material TraceMaterial;

var(Effect) class<Actor> DivineClass;
var(Effect) Actor DivineEffect;
var(Effect) Actor AuraEffect;
var(Effect) Actor ForceEffect;
var(Effect) Actor SpecialForceEffect;
var(Effect) Actor FourthEffect;
var(Effect) Actor FivethEffect;
var(Effect) float DivineEffectDrawScale;
var(Effect) vector DivineEffectDrawScale3D;

var(Effect) bool bShowGlow;
var(Effect) color GlowColor;
var(Effect) float GlowAlphaLimit;

// Į���߰� Xelloss
var	color	SkinColor;			// ������ �ܰ� ��

native function AttachToSlot(Pawn Owner, AttachmentSlot Slot);
native function SetSkin(int Index);
native function int GetAttachmentSlotCount();
//native function Material GetDefaultSkin(int Index);


// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( bAnimate )
		LoopAnim(BaseAnim,1,0);
	if ( bTrackLocation && MTClass != None && MotionTrace == None )
		MotionTrace = new(Self) MTClass;

	AppClassTag = 'Attachment';
	if (Level.NetMode != NM_DedicatedServer)
		Spawn(class'BlackGoldWeaponFxLink', Self);
}
 
function ChangeDrawScale(float NewScale)
{
	SetDrawScale(NewScale);
}

function SpawnActionEffect()
{
	bShowAfterImage = True;
	//if ( DivineEffect != None )
	//	DivineEffect.SetDrawScale(DivineClass.Default.DrawScale);
}

function DestroyActionEffect()
{
	bShowAfterImage = False;
	//if ( DivineEffect != None )
	//	DivineEffect.SetDrawScale(DivineClass.Default.DrawScale);
}

// 挂件销毁前停止并销毁黑金 Link，随后执行原清理。
event Destroyed()
{
    local BlackGoldWeaponFxLink Link;
    local array<BlackGoldWeaponFxLink> Links;
    local int I;
    local Actor Fx;
    foreach ChildActors(class'BlackGoldWeaponFxLink', Link)
    {
        Links.Length = Links.Length + 1;
        Links[Links.Length - 1] = Link;
    }
    for (I = 0; I < Links.Length; I++)
    {
        Link = Links[I];
        if (Link != None && !Link.bDeleteMe)
        {
            Link.StopWork();
            if (!Link.bDeleteMe) Link.Destroy();
        }
    }
    Super.Destroyed();
    Fx = DivineEffect;
    DivineEffect = None;
    if (Fx != None && !Fx.bDeleteMe) Fx.Destroy();
    Fx = AuraEffect;
    AuraEffect = None;
    if (Fx != None && !Fx.bDeleteMe) Fx.Destroy();
    Fx = ForceEffect;
    ForceEffect = None;
    if (Fx != None && !Fx.bDeleteMe) Fx.Destroy();
    Fx = SpecialForceEffect;
    SpecialForceEffect = None;
    if (Fx != None && !Fx.bDeleteMe) Fx.Destroy();
    Fx = FourthEffect;
    FourthEffect = None;
    if (Fx != None && !Fx.bDeleteMe) Fx.Destroy();
    Fx = FivethEffect;
    FivethEffect = None;
    if (Fx != None && !Fx.bDeleteMe) Fx.Destroy();
    Fx = GroundEffect;
    GroundEffect = None;
    if (Fx != None && !Fx.bDeleteMe) Fx.Destroy();
}

event LostChild(Actor Child)
{
    if (Child == DivineEffect) DivineEffect = None;
    if (Child == AuraEffect) AuraEffect = None;
    if (Child == ForceEffect) ForceEffect = None;
    if (Child == SpecialForceEffect) SpecialForceEffect = None;
    if (Child == FourthEffect) FourthEffect = None;
    if (Child == FivethEffect) FivethEffect = None;
    if (Child == GroundEffect) GroundEffect = None;
    Super.LostChild(Child);
}

event DisArmed(Pawn Owner)
{
	if ( Owner != None && AttachmentSlots.Length > 0 && AttachmentSlots[0].Bone != '' )
		AttachToSlot(Owner, AttachmentSlots[0]);

	/*
	if ( DivineEffect != None ) 
	{
		DivineEffect.Destroy();
		DivineEffect = None;
	}*/
	
}

event Armed(Pawn Owner)
{
	if ( Owner != None && AttachmentSlots.Length > 1 && AttachmentSlots[1].Bone != '' )
		AttachToSlot(Owner, AttachmentSlots[1]);
	else if (Owner != None && AttachmentSlots.Length == 1)
		AttachToSlot(Owner, AttachmentSlots[0]);

	/*
	if ( DivineClass != None && DivineEffect == None ) 
	{
		DivineEffect = Spawn(DivineClass);
		//DivineEffect.SetBase(Self,vect(0,0,1));
		//DivineEffect.SetDrawScale(DivineEffectDrawScale);
		//DivineEffect.SetDrawScale3D(DivineEffectDrawScale3D);
	}*/
}

function string GetDebugString()
{
	local string DebugString;
	DebugString = string(Self);
	return DebugString;
}

/*
event Attach(Actor Child)
{
	Super.Attach(Child);
	Child.SetRelativeLocation(vect(0,0,0));
	Child.SetRotation(Rotation);
}
*/

simulated final function RandSpin(float spinRate)
{
	DesiredRotation = RotRand();
	RotationRate.Yaw = spinRate * 2 * FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 * FRand() - spinRate;
	RotationRate.Roll = spinRate * 2 * FRand() - spinRate;	
}

event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	if ( bShowGlow ) 
	{
		if ( !bStyleCreated ) 
		{
			CreateStyle();
			AdjustColorStyle(GlowColor);
		}
		if ( bStyleCreated )
			AdjustAlphaFade(byte(255 - 255 * GlowAlphaLimit));
	}
}


/*
event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	//Log(Self@"Tick"@DeltaTime@DivineEffect);
	if (DivineEffect != None) {
		DivineEffect.SetRelativeLocation(vect(0,0,0));
		DivineEffect.SetRotation(Rotation);
	}
}
*/

/*
	bCollideWorld=true
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
*/
/*
	DivineClass=class'AcainSwordEF.AcainSwordEF'
	DivineEffectDrawScale=1.0
	DivineEffectDrawScale3D=(X=1.0,Y=1.0,Z=1.0)
*/

defaultproperties
{
	MTClass=Class'Sephiroth.MotionTrace'
	GlowAlphaLimit=0.600000
	SkinColor=(B=255,G=255,R=255)
	DrawType=DT_Mesh
	AppClassTag="Attachment"
	bUseCylinderCollision=True
}
