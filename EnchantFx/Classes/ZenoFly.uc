class ZenoFly extends EnchantType;


var class<Actor> GlowEffectClassL;
var Actor GloweEffectR;


function PostBeginPlay()
{
	local float		scaleVec;
	scaleVec = 1.0f;
	Super.PostBeginPlay();

	if(GlowEffectClassL != None) {
		GloweEffectR = Spawn(GlowEffectClassL,self,,Owner.Location,Owner.Rotation);
	    GloweEffectR.SetDrawScale(scaleVec);
	}
}

event Tick(FLOAT DeltaTime)
{
	local vector    BoneLocation;

    // No bone lookup is needed when all child effects are absent.
    if (GloweEffectR != None)
    {

	BoneLocation = Owner.GetBoneCoords('Bip01 R Hand').Origin;

	if(GloweEffectR != None)
		GloweEffectR.SetLocation(BoneLocation);


    }
    Super(EnchantType).Tick(DeltaTime);
}


event LostChild (Actor Child)
{
	if(Child == GloweEffectR) {
		GloweEffectR = None;
	}
	else
		Super.LostChild(Child);
}


event Destroyed()
{
	Super.Destroyed();

	if(GlowEffectClassL != None){
		GloweEffectR.Destroy();
		GlowEffectClassL = None;
	}
}

defaultproperties
{
     GlowEffectClassL=Class'EnchantFx.ZenoFlyEmitter'
}
