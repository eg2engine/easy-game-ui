class CDecal extends Projector;

var Material DetectingMaterial;
var Material ReleasingMaterial;
var Material LockupMaterial;
var Material TrackMaterial;


function SetMaterial(string strMat)	{

	TrackMaterial = Material(DynamicLoadObject(strMat, class'Material'));
}

defaultproperties
{
     DetectingMaterial=Texture'Decal_T.SDecal'
     ReleasingMaterial=Texture'Decal_T.RDecal'
     LockupMaterial=Texture'Decal_T.LDecal_a00'
     FrameBufferBlendingOp=PB_AlphaBlend
     bProjectParticles=False
     bProjectActor=False
     bGradient=True
     bStatic=False
}
