class AfterImageEffect extends Actor
	native;

var class<MotionTrace> MTClass;
var MotionTrace MotionTrace;

// Effect parameter
var Material Material;

// if false, the effect keeps tracking of given actor's location.
// if true, the effect keeps tracking of given bone's location.
var bool bTraceBone;
var int TraceNum;
var int EffectSizeUp, EffectSizeDown;

// Bone parameter
var Name TraceBone;

// Actor parameter
var Actor TraceActor;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (MTClass != None)
		MotionTrace = new(None) MTClass;
}

defaultproperties
{
     MTClass=Class'Sephiroth.MotionTrace'
     Material=Texture'HitEffect.zansang'
     bTraceBone=True
     TraceNum=5
     EffectSizeUp=10
     EffectSizeDown=10
}
