class RiotFx extends EnchantType;


var class<Actor> GlowEffectClassL;
var Actor GloweEffectL;
var class<Actor> GlowEffectClassR;
var Actor GloweEffectR;



function PostBeginPlay()
{
	//local vector    BoneLocation;
	local float		scaleVec;
	Super.PostBeginPlay();

	if(GlowEffectClassL != None) {
		GloweEffectL = Spawn(GlowEffectClassL,self,,Owner.Location,Owner.Rotation);
	    GloweEffectL.SetDrawScale(scaleVec);
	}
	if(GlowEffectClassR != None) {
		GloweEffectR = Spawn(GlowEffectClassR,self, , Owner.Location, Owner.Rotation);
		GloweEffectR.SetDrawScale(scaleVec);
	}
}

event Tick(FLOAT DeltaTime)
{


	local vector    BoneLocation, BoneLocation1;

    // No bone lookup is needed when all child effects are absent.
    if (GloweEffectL != None || GloweEffectR != None)
    {

    if (GloweEffectL != None)
        BoneLocation = Owner.GetBoneCoords('Bip01 L Hand').Origin;

    if (GloweEffectR != None)
        BoneLocation1 = Owner.GetBoneCoords('Bip01 R Hand').Origin;
	if(GloweEffectL != None)
		GloweEffectL.SetLocation(BoneLocation);
	if(GloweEffectR != None)
		GloweEffectR.SetLocation(BoneLocation1);


    }
    Super(EnchantType).Tick(DeltaTime);
}


event LostChild (Actor Child)
{
	if(Child == GloweEffectL) {
		GloweEffectL = None;
	}
    else if(Child == GloweEffectR) {
		GloweEffectR = None;
	}
	else
		Super.LostChild(Child);
}


event Destroyed()
{
	Super.Destroyed();

	if(GlowEffectClassL != None){
		GloweEffectL.Destroy();
		GlowEffectClassL = None;
	}
	if(GlowEffectClassR != None){
		GloweEffectR.Destroy();
		GlowEffectClassR = None;
	}
}

defaultproperties
{
     GlowEffectClassL=Class'EnchantFx.RiotFxEmitter'
     GlowEffectClassR=Class'EnchantFx.RiotFxEmitter'
}
