class Spirit_Alseide extends EnchantTypeEx;


var class<Actor> BirdEffectClass;
var class<Actor> GlowEffectClass;
var Actor  BirdEffect;
var Actor GloweEffect;


function PostBeginPlay()
{
	local float		scaleVec;
	Super.PostBeginPlay();

	if(BirdEffectClass != None){
		BirdEffect = Spawn(BirdEffectClass,self,,Owner.Location,Owner.Rotation);
	}
	if(GlowEffectClass != None){
		GloweEffect = Spawn(GlowEffectClass,self,,BirdEffect.Location,BirdEffect.Rotation);
		scaleVec = 5.0f;
	    GloweEffect.SetDrawScale(scaleVec);
	}
}

event Tick(FLOAT DeltaTime)
{
	//local int       flag, i;
	local vector    BoneLocation, BirdLocation;


	if(BirdEffect != None) {
		BirdEffect.SetRotation(Owner.Rotation);
		BirdLocation.Z = Owner.Location.Z - 100;
		BirdLocation.X = Owner.Location.X;
		BirdLocation.Y = Owner.Location.Y;
		BirdEffect.SetLocation(BirdLocation);
		if (GloweEffect != None) BoneLocation = BirdEffect.GetBoneCoords('Bone11').Origin;
	}
	if(GloweEffect != None)

		GloweEffect.SetLocation(BoneLocation);

	Super(EnchantType).Tick(DeltaTime);
}


event LostChild (Actor Child)
{
	if(Child == BirdEffect) {
		BirdEffect = None;
	}
	else if(Child == GloweEffect) {
		GloweEffect = None;
	}
	else
		Super.LostChild(Child);
}


event Destroyed()
{
	Super.Destroyed();

	if (BirdEffectClass != None) {
		BirdEffect.Destroy();
		BirdEffectClass = None;
	}
	if(GlowEffectClass != None){
		GloweEffect.Destroy();
		GlowEffectClass = None;

	}
}

defaultproperties
{
     BirdEffectClass=Class'EnchantFx.Spirit_Alseide_Effect'
     GlowEffectClass=Class'EnchantFx.Spirit_Alseide_Glow'
     EnchantDesc="Alseide"
     bAutoCalcOffset=True
}
