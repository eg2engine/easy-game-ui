class DAMUP extends EnchantType;

var class<Actor> GlowEffectClass;
var Actor GloweEffect;
var class<Actor> GlowEffectClass1;
var Actor GloweEffect1;

function PostBeginPlay()
{
	local float		scaleVec;
	scaleVec = 1.0f;
	Super.PostBeginPlay();

	if(GlowEffectClass != None) {
		GloweEffect = Spawn(GlowEffectClass,self,,Owner.Location,Owner.Rotation);
	    GloweEffect.SetDrawScale(scaleVec);
	}
	if(GlowEffectClass1 != None) {
		GloweEffect1 = Spawn(GlowEffectClass1,self, , Owner.Location, Owner.Rotation);
		GloweEffect1.SetDrawScale(scaleVec);
	}
}

event Tick(FLOAT DeltaTime)
{
	local vector    BoneLocation, BoneLocation1;

    // No bone lookup is needed when all child effects are absent.
    if (GloweEffect != None || GloweEffect1 != None)
    {

    if (GloweEffect != None)
        BoneLocation = Owner.GetBoneCoords('Bip01 L Hand').Origin;

    if (GloweEffect1 != None)
        BoneLocation1= Owner.GetBoneCoords('Bip01 R Hand').Origin;
	if(GloweEffect != None)
		GloweEffect.SetLocation(BoneLocation);
	if(GloweEffect1 != None)
		GloweEffect1.SetLocation(BoneLocation1);


    }
    Super(EnchantType).Tick(DeltaTime);
}


event LostChild (Actor Child)
{
	if(Child == GloweEffect) {
		GloweEffect = None;
	}
    else if(Child == GloweEffect1) {
		GloweEffect1 = None;
	}
	else
		Super.LostChild(Child);
}


event Destroyed()
{
	Super.Destroyed();

	if(GlowEffectClass != None){
		GloweEffect.Destroy();
		GlowEffectClass = None;
	}
	if(GlowEffectClass1 != None){
		GloweEffect1.Destroy();
		GlowEffectClass1 = None;
	}
}

defaultproperties
{
     GlowEffectClass=Class'EnchantFx.DAMUP_Emitter'
     GlowEffectClass1=Class'EnchantFx.DAMUP_Emitter'
}
