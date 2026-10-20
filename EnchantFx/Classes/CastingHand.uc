class CastingHand extends EnchantType;


var class<Actor> RingAttachClass;
var Actor RingAttacher;

function PostBeginPlay()
{
	local vector    BoneLocation;
	Super.PostBeginPlay();

	if (Owner != None) {
		if(RingAttacher == None && RingAttachClass != None) {
			BoneLocation = Owner.GetBoneCoords('Bip01 R Hand').Origin;
			RingAttacher = Spawn(RingAttachClass,self,,BoneLocation,Owner.Rotation);
		}
	}
}

event Tick(FLOAT DeltaTime)
{
	local vector    BoneLocation;

	Super(EnchantType).Tick(DeltaTime);

	if (Owner != None) {
		if (RingAttacher != None)
            BoneLocation = Owner.GetBoneCoords('Bip01 R Hand').Origin;
		if(RingAttacher != None)
			RingAttacher.SetLocation(BoneLocation);
	}
}


event LostChild (Actor Child)
{
	if(Child == RingAttacher)
		RingAttacher = None;
	else
		Super.LostChild(Child);
}


event Destroyed()
{
	Super.Destroyed();

	if(RingAttacher != None){
		RingAttacher.Destroy();
		RingAttacher = None;
	}
}

defaultproperties
{
     RingAttachClass=Class'EnchantFx.CastingHand_Emitter'
     EnchantDesc="CastingHand_Emitter"
     bAutoCalcOffset=True
}
