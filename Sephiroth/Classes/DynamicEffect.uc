class DynamicEffect extends Effects;

var string	EffectName;
var string	ShaderName;
var float	ScaleRatio;
var float	LocRatio;
var StaticMesh effectMesh;

function SetEffectName(string effectName_)
{
	if(effectName_ == EffectName)
		return ;

	if(effectName_ == "")
	{
		SetStaticMesh(None);
		effectMesh = None;
	}
	else
	{
		effectMesh = StaticMesh(DynamicLoadObject(effectName_, class'StaticMesh'));
		SetStaticMesh(effectMesh);
		Owner.AttachToBone(Self, Character(Owner).BoneSpine);
	}

	EffectName = effectName_;

	Update();
}

function SetShaderName(string shaderName_)
{
	if(shaderName_ == ShaderName)
		return ;

	if(shaderName_ == "")
	{
		Skins[0] = None;
	}
	else
	{
		Skins[0] = Material(DynamicLoadObject(shaderName_, class'Shader'));
	}

	ShaderName = shaderName_;

	Update();
}

function Update()
{
	local vector loc;

	loc = vect(0,0,0);
	loc.X = LocRatio * Owner.CollisionHeight;

	SetRelativeLocation(loc);
	SetDrawScale(ScaleRatio);
}

event Destroyed()
{
	Skins[0] = None;
	SetStaticMesh(None);
	SetBase(None);

	effectMesh = None;

	Super.Destroyed();
}

defaultproperties
{
     ScaleRatio=1.000000
     LocRatio=0.600000
     DrawType=DT_StaticMesh
}
