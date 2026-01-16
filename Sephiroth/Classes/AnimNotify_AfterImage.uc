class AnimNotify_AfterImage extends AnimNotify
	native;

// Effect parameter
var() Material Material;

// if false, the effect keeps tracking of given actor's location.
// if true, the effect keeps tracking of given bone's location.
var() int TraceNum;
var() int EffectSizeUp, EffectSizeDown;

// Bone parameter
var() Name TraceBone;

// Transient parameter
var bool bTraceBone;
var private transient Actor TraceActor;
var private transient AfterImageEffect EffectActor;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
     Material=Texture'HitEffect.zansang'
     TraceNum=5
     EffectSizeUp=10
     EffectSizeDown=10
     bTraceBone=True
}
