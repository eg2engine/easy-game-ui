class MotionTrace extends Object
	native;

struct native MotionShot {
	var vector Location;
	var rotator Rotation;
};
var array<MotionShot> Traces;
var int TraceLength;

enum EMotionTracing {
	EMT_Actor,
	EMT_Bone
};

enum EMotionDisplay {
	MD_AfterImage
};

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
}
