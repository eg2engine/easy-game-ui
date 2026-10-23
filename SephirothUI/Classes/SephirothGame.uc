// 管理游戏环境和换线配置；线路名称仅用于显示，连接目标仍由地址列表确定。
class SephirothGame extends GameManager
	config;

var globalconfig string ServerGroupName;
var globalconfig int ServerSetId;
var globalconfig string ServerSetInfo;
// 线路名称资源键，以 | 分隔并与 ServerSetInfo 对齐；实际文字由 SephirothUI 的语言资源提供。
var globalconfig string ServerSetName;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Environments[0] = Spawn(class'HumanEnvironment');
	Environments[1] = Spawn(class'NephilimEnvironment');
	Environments[2] = Spawn(class'TitaanEnvironment');
	Environments[3] = Spawn(class'IceLandEnvironment');
	Environments[4] = Spawn(class'GhostTownEnvironment');
}

event Destroyed()
{
	Super.Destroyed();
	Environments[0].Destroy();
	Environments[1].Destroy();
	Environments[2].Destroy();
	Environments[3].Destroy();
}

function GetServerId(out string Sg, out int Si)
{
	local string LocalServerGroup;
	local int ServerIndex;
	LocalServerGroup = ConsoleCommand("ServerSetName");
	ServerIndex = int(ConsoleCommand("ServerSetID"));
	Sg = LocalServerGroup;
	Si = ServerIndex;
}

// 在 UI 线程读取线路地址和原生线路标识；有效下标从 0 开始，无法对应列表时返回 -1。
// 保留原生 ServerSetID - 1 的对应规则，不将越界线路号猜测为某个菜单位置。
function GetServerInfoEx(out string outServerGroup, out int ServerIndex, out array<string> IpList)
{
	IpList.Remove(0,IpList.Length);
	if (ServerSetInfo != "")
		class'CNativeInterface'.static.WrapStringToArray(ServerSetInfo, IpList, 10000, "|");
	ServerGroupName = ConsoleCommand("ServerSetName");
	ServerSetId = int(ConsoleCommand("ServerSetID"));
	outServerGroup = ServerGroupName;
	ServerIndex = ServerSetId - 1;

	if (ServerIndex < 0)
	{
		ServerIndex = -1;
		return;
	}
	if (ServerIndex >= IpList.Length)
		ServerIndex = -1;
}

// 在 UI 线程构造换线列表；地址、名称保持同一顺序，当前下标未知时不追加当前线路标记。
// 未配置键或数量不匹配时保留旧显示；空键、缺失翻译仅回退对应位置。
function GetServerSelectionInfo(out int ServerIndex, out array<string> IpList, out array<string> DisplayNames)
{
	local string LocalServerGroup;
	local string DisplayName;
	local array<string> NameKeys;
	local int i;

	GetServerInfoEx(LocalServerGroup, ServerIndex, IpList);
	DisplayNames.Remove(0, DisplayNames.Length);

	// 配置保存资源键，原生 ConsoleCommand("ServerSetName") 仍返回组名，二者分别读取。
	if (ServerSetName != "")
	{
		ParseServerSetNameKeys(NameKeys);
		if (NameKeys.Length != IpList.Length)
		{
			// 数量不一致时整组回退，避免缺项使后续名称与连接地址错配。
			Log("[ServerSelection] ServerSetName key count=" $ NameKeys.Length $ " does not match ServerSetInfo count=" $ IpList.Length $ "; using legacy names.");
			NameKeys.Remove(0, NameKeys.Length);
		}
	}

	for (i = 0; i < IpList.Length; i++)
	{
		DisplayName = "";
		if (i < NameKeys.Length)
			DisplayName = ResolveServerSetName(NameKeys[i]);
		if (DisplayName == "")
			DisplayName = LocalServerGroup@Localize("Terms", "Server", "Sephiroth")$"-"$(i + 1);
		if (i == ServerIndex)
			DisplayName = DisplayName@"("$Localize("Terms", "CurrentServerSet", "Sephiroth")$")";
		DisplayNames[i] = DisplayName;
	}
}

// 只按 | 拆分资源键并保留首部、连续和尾部空项，避免空键丢失改变菜单槽位。
private function ParseServerSetNameKeys(out array<string> Names)
{
	local string Remaining;
	local int Separator;

	Names.Remove(0, Names.Length);
	Remaining = ServerSetName;
	while (True)
	{
		Separator = InStr(Remaining, "|");
		if (Separator < 0)
		{
			Names[Names.Length] = Remaining;
			return;
		}
		Names[Names.Length] = Left(Remaining, Separator);
		Remaining = Mid(Remaining, Separator + 1);
	}
}

// 通过既有 Localize 读取当前语言及引擎的基础语言回退；返回空串表示该项须用旧名称。
// 缺失资源在 SHOWLANGERROR 下会返回明确错误标记，该标记不能作为线路名显示。
private static function string ResolveServerSetName(string NameKey)
{
	local string DisplayName;
	local string MissingSuffix;

	if (NameKey == "")
		return "";
	DisplayName = Localize("ServerSetNames", NameKey, "SephirothUI");
	if (DisplayName == "")
	{
		Log("[ServerSelection] No usable translation for ServerSetName key=" $ NameKey $ "; using legacy name.");
		return "";
	}

	// 仅识别引擎针对同一包、节和键生成的缺失标记，不根据字符范围或内容猜测编码。
	MissingSuffix = "?SephirothUI.ServerSetNames."$NameKey$"?>";
	if (Left(DisplayName, 2) == "<?" && Caps(Right(DisplayName, Len(MissingSuffix))) == Caps(MissingSuffix))
	{
		Log("[ServerSelection] Missing localization for ServerSetName key=" $ NameKey $ "; using legacy name.");
		return "";
	}
	return DisplayName;
}

defaultproperties
{
     HUDType="SephirothUI.SephirothInterface"
     PlayerControllerClass=Class'SephirothUI.SephirothPlayer'
}
