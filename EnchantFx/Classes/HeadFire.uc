class HeadFire extends EnchantType;

var class<Actor> GlowEffectClass;
var Actor GloweEffect;

function PostBeginPlay()
{
	local float		scaleVec;
	scaleVec = 1.0f;
	Super.PostBeginPlay();

	if(GlowEffectClass != None) {
		GloweEffect = Spawn(GlowEffectClass,self,,Owner.Location,Owner.Rotation);
	    GloweEffect.SetDrawScale(scaleVec);
	}
}

event Tick(FLOAT DeltaTime)
{
	local vector    BoneLocation;

    // No bone lookup is needed when all child effects are absent.
    if (GloweEffect != None)
    {

	BoneLocation = Owner.GetBoneCoords('Bip01 Head').Origin;

	if(GloweEffect != None)
		GloweEffect.SetLocation(BoneLocation);


    }
    Super(EnchantType).Tick(DeltaTime);
}


event LostChild (Actor Child)
{
	if(Child == GloweEffect) {
		GloweEffect = None;
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
}

defaultproperties
{
     GlowEffectClass=Class'EnchantFx.HeadFire_Emitter'
}
