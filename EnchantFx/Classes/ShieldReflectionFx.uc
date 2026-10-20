class ShieldReflectionFx extends EnchantType;


var class<Actor> GlowEffectClassL;
var Actor GloweEffectL;

function PostBeginPlay()
{
	local float		scaleVec;
	Super.PostBeginPlay();

	if(GlowEffectClassL != None) {
		GloweEffectL = Spawn(GlowEffectClassL,self,,Owner.Location,Owner.Rotation);
	    GloweEffectL.SetDrawScale(scaleVec);
	}
}

event Tick(FLOAT DeltaTime)
{
	local vector    BoneLocation;

    // No bone lookup is needed when all child effects are absent.
    if (GloweEffectL != None)
    {

	BoneLocation = Owner.GetBoneCoords('Bip01 L Hand').Origin;

	if(GloweEffectL != None)
		GloweEffectL.SetLocation(BoneLocation);


    }
    Super(EnchantType).Tick(DeltaTime);
}


event LostChild (Actor Child)
{
	if(Child == GloweEffectL) {
		GloweEffectL = None;
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
}

defaultproperties
{
     GlowEffectClassL=Class'EnchantFx.ShieldReflectionEmitter'
}
