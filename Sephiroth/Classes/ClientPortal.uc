class ClientPortal extends Actor
	config(Portal);

struct Portal
{
	var() name Zone;
	var() string Desc;
	var() int X;
	var() int Y;
};

var config array<Portal> Portals;
var ClientController PortalOwner;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (ClientController(Owner) == None)
		Destroy();
	else
		PortalOwner = ClientController(Owner);
}

function AddPortal(name P,int X,int Y)
{
	local Portal Portal;
	local int i;
	local string sPre,sAft;

	for (i=0;i<Portals.Length;i++)
		if (Portals[i].Zone == P) {
			Portals[i].X = X;
			Portals[i].Y = Y;

			sPre = Localize("PotalUI","InPre","SephirothUI");
			sAft = Localize("PotalUI","InAft","SephirothUI");
			PortalOwner.myHud.AddMessage(2, sPre $ " "$P$" "$X$" "$Y$" "$"" $ sAft,class'Canvas'.static.MakeColor(211,158,112));
			SaveConfig();
			return;
		}
	Portal.Zone = P;
	Portal.X = X;
	Portal.Y = Y;
	Portals[Portals.Length] = Portal;

	sPre = Localize("PotalUI","InPre","SephirothUI");
	sAft = Localize("PotalUI","InAftB","SephirothUI");

	PortalOwner.myHud.AddMessage(2, sPre $ " "$P$" "$X$" "$Y$" "$"" $ sAft ,class'Canvas'.static.MakeColor(211,158,112));
	SaveConfig();
}

function bool CheckPortal(name Portal)
{
	local int i;

	for (i=0;i<Portals.Length;i++)
		if (Portal == Portals[i].Zone) {
			PortalOwner.Net.NotiTell(1, "\\\\MoveAbs "$Portals[i].X$" "$Portals[i].Y);
			return true;
		}
	return false;
}

function bool CheckFriendly(string Name)
{
	local int i;
	for (i=0;i<Portals.Length;i++)
		if (Name == Portals[i].Desc) {
			PortalOwner.Net.NotiTell(1, "\\\\MoveAbs "$Portals[i].X$" "$Portals[i].Y);
			return true;
		}
	return false;
}

defaultproperties
{
}
