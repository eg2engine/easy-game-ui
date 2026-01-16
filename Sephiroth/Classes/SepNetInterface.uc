class SepNetInterface extends ClientNetInterface
	native
	noexport;

var int bCheckValidMove;
var int bLastValidMove;

//@by wj(05/22)
var bool bGameToLobby;

var float OldClientTime, NewClientTime;
var int OldServerTime, NewServerTime;
var int SpeedHackCounter;
var int TimeCounter;

var const int PanClient;
var const ClientController PlayerOwner;
var int LogFlags;

var name CharNameToDelete;
var name CharNameToCreate;
var vector StartPosition;
var const int MoveManager;
//var const int TimeCheckerManager;

var PlayerServerInfo CachedPlayerSI;
var PetServerInfo CachedPetSI;

// 参数: 无。
// 功能: 通知服务器角色拔出武器进入战斗姿态。
// 参数: 无。
native final function NotiArmed();
// 参数: 无。
// 功能: 通知服务器角色收起武器进入非战斗姿态。
// 参数: 无。
native final function NotiDisarmed();
// 参数: 无。
// 功能: 通知服务器角色切换为奔跑状态。
// 参数: 无。
native final function NotiRun();
// 参数: 无。
// 功能: 通知服务器角色切换为行走状态。
// 参数: 无。
native final function NotiWalk();
// 参数: 无。
// 功能: 通知服务器角色开启玩家对玩家（PK）模式。
// 参数: 无。
native final function NotiPK();
// 参数: 无。
// 功能: 通知服务器角色关闭玩家对玩家（PK）模式。
// 参数: 无。
native final function NotiNotPK();
// 参数:
//   byte Type, int Point: 调用时传入的参数。
// 功能: 扣除或使用指定类型的点数。
// 参数:
//   Type(byte): 点数类型或用途标识。
//   Point(int): 要消耗的点数数量。
native final function NotiUsePoint(byte Type, int Point);
// 参数:
//   byte Type, byte Type2: 调用时传入的参数。
// 功能: 请求在指定方式与位置复活。
// 参数:
//   Type(byte): 复活类别（例如城镇、当前地图等）。
//   Type2(byte): 复活的具体选项或子类型。
native final function NotiResurrectAt(byte Type, byte Type2);

// 参数:
//   Title(string): 调用时传入的参数。
// 功能: 修改角色当前称号。
// 参数:
//   Title(string): 要应用的新称号文本。
native final function NotiChangePlayerTitle(string Title);
// 参数:
//   string MatchName, int isAccept: 调用时传入的参数。
// 功能: 回应服务器的比赛进入邀请。
// 参数:
//   MatchName(string): 比赛或活动的名称。
//   isAccept(int): 是否接受（非零为接受）。
native final function NotiAnswerEnterMatch(string MatchName, int isAccept);
// 参数:
//   MatchName(string): 调用时传入的参数。
// 功能: 请求离开当前参加的比赛。
// 参数:
//   MatchName(string): 要退出的比赛名称。
native final function NotiMatchQuit(string MatchName);


// 参数:
//   byte Type, string Message: 调用时传入的参数。
// 功能: 发送指定类别的聊天消息。
// 参数:
//   Type(byte): 聊天频道类型。
//   Message(string): 要发送的聊天内容。
native final function NotiTell(byte Type, string Message);
// 参数:
//   string Receiver, string Message: 调用时传入的参数。
// 功能: 向单个玩家发送私聊消息。
// 参数:
//   Receiver(string): 接收者角色名。
//   Message(string): 要发送的私聊内容。
native final function NotiWhisper(string Receiver, string Message);
// 参数:
//   int Index, string Memo: 调用时传入的参数。
// 功能: 保存一条传送点记录。
// 参数:
//   Index(int): 传送点槽位。
//   Memo(string): 该传送点的备注文字。
native final function NotiPortalSave(int Index, string Memo);
// 参数:
//   int Index, string Memo: 调用时传入的参数。
// 功能: 更新已保存传送点的备注文本。
// 参数:
//   Index(int): 传送点槽位。
//   Memo(string): 新的备注内容。
native final function NotiPortalMemo(int Index, string Memo);
// 参数:
//   Index(int): 调用时传入的参数。
// 功能: 请求服务器返回指定传送点的详细信息。
// 参数:
//   Index(int): 传送点槽位。
native final function NotiPortalInfo(int Index);
// 参数:
//   Index(int): 调用时传入的参数。
// 功能: 请求通过已保存的传送点进行传送。
// 参数:
//   Index(int): 传送点槽位。
native final function NotiPortalMove(int Index);
// 参数:
//   Index(int): 调用时传入的参数。
// 功能: 移除已保存的传送点。
// 参数:
//   Index(int): 传送点槽位。
native final function NotiPortalRemove(int Index);
// 参数:
//   byte Index, string SkillName: 调用时传入的参数。
// 功能: 在快捷栏中指定技能。
// 参数:
//   Index(byte): 快捷栏序号。
//   SkillName(string): 技能资源名称。
native final function NotiSkillAssign(byte Index, string SkillName);

// 参数:
//   Item(int): 调用时传入的参数。
// 功能: 拾取地面物品放入背包。
// 参数:
//   Item(int): 地面物品的唯一标识。
native final function NotiPickUpItem(int Item);
// 参数:
//   int SrcIndex, int InvenX, int InvenY, byte EquipPlace: 调用时传入的参数。
// 功能: 将背包中的物品装备到指定部位。
// 参数:
//   SrcIndex(int): 背包容器索引。
//   InvenX(int): 背包格 X 坐标。
//   InvenY(int): 背包格 Y 坐标。
//   EquipPlace(byte): 目标装备槽位。
native final function NotiWearItem(int SrcIndex, int InvenX, int InvenY, byte EquipPlace);
// 参数:
//   byte EquipPlace, int DestIndex, int DestInvenX, int DestInvenY: 调用时传入的参数。
// 功能: 将穿戴的物品卸下并放入背包。
// 参数:
//   EquipPlace(byte): 当前装备槽位。
//   DestIndex(int): 目标背包索引。
//   DestInvenX(int): 目标格 X 坐标。
//   DestInvenY(int): 目标格 Y 坐标。
native final function NotiTakeOffItem(byte EquipPlace, int DestIndex, int DestInvenX, int DestInvenY);
// 参数:
//   byte EquipPlace, int DestIndex, int DestInvenX, int DestInvenY: 调用时传入的参数。
// 功能: 在装备槽与背包之间交换物品。
// 参数:
//   EquipPlace(byte): 需要交换的装备槽。
//   DestIndex(int): 背包索引。
//   DestInvenX(int): 背包目标 X 坐标。
//   DestInvenY(int): 背包目标 Y 坐标。
native final function NotiSwapEquipment(byte EquipPlace, int DestIndex, int DestInvenX, int DestInvenY);
// 参数:
//   byte EquipPlace, int PlayerHeight: 调用时传入的参数。
// 功能: 将正在穿戴的物品丢弃到地面。
// 参数:
//   EquipPlace(byte): 装备槽位。
//   PlayerHeight(int): 角色当前高度，用于掉落位置。
native final function NotiDropWornItem(byte EquipPlace, int PlayerHeight);
// 参数:
//   int InvenIndex, int InvenX, int InvenY, int PlayerHeight: 调用时传入的参数。
// 功能: 将背包中的物品丢弃到地面。
// 参数:
//   InvenIndex(int): 背包容器索引。
//   InvenX(int): 物品所在格 X 坐标。
//   InvenY(int): 物品所在格 Y 坐标。
//   PlayerHeight(int): 角色当前高度。
native final function NotiDropInvenItem(int InvenIndex, int InvenX, int InvenY, int PlayerHeight);
// 参数:
//   int InvenFromX, int InvenFromY, int InvenToX, int InvenToY: 调用时传入的参数。
// 功能: 在背包内移动物品到新的格子。
// 参数:
//   InvenFromX(int): 原位置 X 坐标。
//   InvenFromY(int): 原位置 Y 坐标。
//   InvenToX(int): 目标位置 X 坐标。
//   InvenToY(int): 目标位置 Y 坐标。
native final function NotiArrangeItem(int InvenFromX, int InvenFromY, int InvenToX, int InvenToY);
// 参数:
//   int Amount, vector PlayerLocation: 调用时传入的参数。
// 功能: 将一定金额的金币丢到地面。
// 参数:
//   Amount(int): 要丢弃的金币数量。
//   PlayerLocation(vector): 角色当前位置。
native final function NotiDropMoney(int Amount, vector PlayerLocation);
// 参数:
//   Item(int): 调用时传入的参数。
// 功能: 拾取地面上的金币。
// 参数:
//   Item(int): 金币掉落对象的标识。
native final function NotiPickUpMoney(int Item);
// 参数:
//   TypeName(string): 调用时传入的参数。
// 功能: 通过快捷栏使用物品或技能。
// 参数:
//   TypeName(string): 快捷栏绑定的资源名称。
native final function NotiItemUseShotcut(string TypeName);

// 参数:
//   int MaterialNo, int Amount: 调用时传入的参数。
// 功能: 请求服务器进行原材料合成。
// 参数:
//   MaterialNo(int): 配方或材料编号。
//   Amount(int): 要合成的数量。
native final function NotiMixRaw(int MaterialNo, int Amount);
// 参数:
//   int DetailType, int Amount: 调用时传入的参数。
// 功能: 请求服务器进行精炼合成。
// 参数:
//   DetailType(int): 精炼类别编号。
//   Amount(int): 要精炼的数量。
native final function NotiMixRefined(int DetailType, int Amount);

// 参数: 无。
// 功能: 保存当前的快捷栏配置。
// 参数: 无。
native final function NotiSaveShortcut();

// 参数:
//   int InvenX, int InvenY, string Channel: 调用时传入的参数。
// 功能: 为背包中的物品设置频道或附属信息。
// 参数:
//   InvenX(int): 物品所在格 X 坐标。
//   InvenY(int): 物品所在格 Y 坐标。
//   Channel(string): 要写入的频道或标记。
native final function NotiSetChannel(int InvenX, int InvenY, string Channel);
// 参数:
//   byte EquipPlace, string Channel: 调用时传入的参数。
// 功能: 为已装备的物品设置频道或附属信息。
// 参数:
//   EquipPlace(byte): 装备槽位。
//   Channel(string): 频道或标记字符串。
native final function NotiSetChannelWorn(byte EquipPlace, string Channel);
// 参数:
//   string Channel, string Message: 调用时传入的参数。
// 功能: 在自定义频道中发送聊天消息。
// 参数:
//   Channel(string): 频道名称。
//   Message(string): 聊天内容。
native final function NotiTellChannel(string Channel, string Message);

// 参数:
//   Other(int): 调用时传入的参数。
// 功能: 向目标玩家发起交易请求。
// 参数:
//   Other(int): 目标玩家标识。
native final function NotiXcngRequest(int Other);
// 参数:
//   Other(int): 调用时传入的参数。
// 功能: 接受他人的交易请求。
// 参数:
//   Other(int): 对方玩家标识。
native final function NotiXcngRequestAccept(int Other);
// 参数:
//   Other(int): 调用时传入的参数。
// 功能: 拒绝他人的交易请求。
// 参数:
//   Other(int): 对方玩家标识。
native final function NotiXcngRequestDeny(int Other);
// 参数:
//   int Other, int InvenIndex, int InvenX, int InvenY, int ExchangeX, int ExchangeY: 调用时传入的参数。
// 功能: 将背包物品放入交易栏。
// 参数:
//   Other(int): 对方玩家标识。
//   InvenIndex(int): 背包容器索引。
//   InvenX(int): 背包 X 坐标。
//   InvenY(int): 背包 Y 坐标。
//   ExchangeX(int): 交易栏 X 坐标。
//   ExchangeY(int): 交易栏 Y 坐标。
native final function NotiXcngAddItem(int Other, int InvenIndex, int InvenX, int InvenY, int ExchangeX, int ExchangeY);
// 参数:
//   int Other, int ExchangeX, int ExchangeY, int InvenIndex, int InvenX, int InvenY: 调用时传入的参数。
// 功能: 从交易栏移除物品并放回背包。
// 参数:
//   Other(int): 对方玩家标识。
//   ExchangeX(int): 交易栏 X 坐标。
//   ExchangeY(int): 交易栏 Y 坐标。
//   InvenIndex(int): 背包容器索引。
//   InvenX(int): 目标背包 X 坐标。
//   InvenY(int): 目标背包 Y 坐标。
native final function NotiXcngRemoveItem(int Other, int ExchangeX, int ExchangeY, int InvenIndex, int InvenX, int InvenY);
// 参数:
//   int Other, int FromX, int FromY, int ToX, int ToY: 调用时传入的参数。
// 功能: 在交易栏内部移动物品。
// 参数:
//   Other(int): 对方玩家标识。
//   FromX(int): 原位置 X。
//   FromY(int): 原位置 Y。
//   ToX(int): 目标位置 X。
//   ToY(int): 目标位置 Y。
native final function NotiXcngArrangeItem(int Other, int FromX, int FromY, int ToX, int ToY);
// 参数:
//   int Other, string Amount: 调用时传入的参数。
// 功能: 设置交易中提供的金币数量。
// 参数:
//   Other(int): 对方玩家标识。
//   Amount(string): 提供的金币数量字符串。
native final function NotiXcngMoney(int Other, string Amount);
// 参数:
//   Other(int): 调用时传入的参数。
// 功能: 在交易界面确认自己的物品与金币。
// 参数:
//   Other(int): 对方玩家标识。
native final function NotiXcngOk(int Other);
// 参数:
//   Other(int): 调用时传入的参数。
// 功能: 取消当前交易流程。
// 参数:
//   Other(int): 对方玩家标识。
native final function NotiXcngCancel(int Other);
//@by wj(07/22) for Exchange MultiSelect
// 参数:
//   int Other, int InvenIndex, array<SephirothItem> SelectedItems: 调用时传入的参数。
// 功能: 批量将多个物品加入交易栏。
// 参数:
//   Other(int): 对方玩家标识。
//   InvenIndex(int): 背包容器索引。
//   SelectedItems(array<SephirothItem>): 要加入交易的物品列表。
native final function NotiXcngAddItemMany(int Other, int InvenIndex, array<SephirothItem> SelectedItems);

// 参数: 无。
// 功能: 解散当前队伍。
// 参数: 无。
native final function NotiPartyDismiss();
// 参数:
//   Other(int): 调用时传入的参数。
// 功能: 请求加入指定玩家的队伍。
// 参数:
//   Other(int): 目标玩家标识。
native final function NotiPartyJoin(int Other);
// 参数:
//   string Other, int OtherLevel: 调用时传入的参数。
// 功能: 同意其他玩家的入队申请。
// 参数:
//   Other(string): 申请者角色名。
//   OtherLevel(int): 申请者等级。
native final function NotiPartyJoinAccept(string Other, int OtherLevel);
// 参数:
//   Other(string): 调用时传入的参数。
// 功能: 拒绝其他玩家的入队申请。
// 参数:
//   Other(string): 申请者角色名。
native final function NotiPartyJoinDeny(string Other);
// 参数:
//   Other(int): 调用时传入的参数。
// 功能: 邀请指定玩家加入队伍。
// 参数:
//   Other(int): 目标玩家标识。
native final function NotiPartyInvite(int Other);
// 参数:
//   string Other, int OtherLevel: 调用时传入的参数。
// 功能: 接受他人的组队邀请。
// 参数:
//   Other(string): 邀请者角色名。
//   OtherLevel(int): 邀请者等级。
native final function NotiPartyInviteAccept(string Other, int OtherLevel);
// 参数:
//   Other(string): 调用时传入的参数。
// 功能: 拒绝他人的组队邀请。
// 参数:
//   Other(string): 邀请者角色名。
native final function NotiPartyInviteDeny(string Other);
// 参数:
//   NewLeader(string): 调用时传入的参数。
// 功能: 将队长权限移交给指定队员。
// 参数:
//   NewLeader(string): 新的队长角色名。
native final function NotiPartyLdrChange(string NewLeader);
// 参数:
//   Other(string): 调用时传入的参数。
// 功能: 将指定队员从队伍中移除。
// 参数:
//   Other(string): 被移除的队员角色名。
native final function NotiPartyBan(string Other);
// 参数: 无。
// 功能: 通知服务器自己离开队伍。
// 参数: 无。
native final function NotiPartyLeave();
// 参数:
//   Message(string): 调用时传入的参数。
// 功能: 向队伍频道发送消息。
// 参数:
//   Message(string): 队伍聊天内容。
native final function NotiPartyTell(string Message);
// 参数:
//   Index(int): 调用时传入的参数。
// 功能: 调整队员在队伍列表中的顺序。
// 参数:
//   Index(int): 队员列表索引或目标位置。
native final function NotiPartyMove(int Index);

// Mento
// 参数:
//   OccuID(int): 调用时传入的参数。
// 功能: 申请成为特定职业的导师。
// 参数:
//   OccuID(int): 职业或导师类别 ID。
native final function NotiRequestMentor(int OccuID);
// 参数:
//   string sName, int OccuID: 调用时传入的参数。
// 功能: 同意其他玩家的导师申请。
// 参数:
//   sName(string): 申请者角色名。
//   OccuID(int): 职业 ID。
native final function NotiResponseMentorAccept(string sName, int OccuID);
// 参数:
//   sName(string): 调用时传入的参数。
// 功能: 拒绝其他玩家的导师申请。
// 参数:
//   sName(string): 申请者角色名。
native final function NotiResponseMentorDeny(string sName);
// 参数:
//   OccuID(int): 调用时传入的参数。
// 功能: 申请成为某位导师的学员。
// 参数:
//   OccuID(int): 职业或导师类别 ID。
native final function NotiRequestMentee(int OccuID);
// 参数:
//   string sName, int OccuID: 调用时传入的参数。
// 功能: 接受其他玩家成为学员。
// 参数:
//   sName(string): 学员角色名。
//   OccuID(int): 职业 ID。
native final function NotiResponseMenteeAccept(string sName, int OccuID);
// 参数:
//   sName(string): 调用时传入的参数。
// 功能: 拒绝学员申请。
// 参数:
//   sName(string): 学员角色名。
native final function NotiResponseMenteeDeny(string sName);
// 参数:
//   nSlotIndex(int): 调用时传入的参数。
// 功能: 退出导师系统或解除师徒关系。
// 参数:
//   nSlotIndex(int): 师徒槽位索引。
native final function NotiLeaveMentorSystem(int nSlotIndex);
// 参数:
//   nSlotIndex(int): 调用时传入的参数。
// 功能: 开启新的学员槽位。
// 参数:
//   nSlotIndex(int): 学员槽位索引。
native final function NotiEnableMenteeSlot(int nSlotIndex);
// 参数:
//   int nSlotIndex, string sName: 调用时传入的参数。
// 功能: 将指定学员移出师徒列表。
// 参数:
//   nSlotIndex(int): 学员槽位索引。
//   sName(string): 学员角色名。
native final function NotiKickMentee(int nSlotIndex, string sName);
// 参数:
//   nIndex(int): 调用时传入的参数。
// 功能: 接受导师系统的声望任务。
// 参数:
//   nIndex(int): 任务索引。
native final function NotiAcceptRPQuest(int nIndex);
// 参数:
//   int nIndex, int nPoint: 调用时传入的参数。
// 功能: 赠送声望点数给学员。
// 参数:
//   nIndex(int): 目标槽位或角色索引。
//   nPoint(int): 声望点数。
native final function NotiGiveReputationPoint(int nIndex, int nPoint);
// 参数:
//   nOccuID(int): 调用时传入的参数。
// 功能: 请求特定职业的导师信息。
// 参数:
//   nOccuID(int): 职业或导师类别 ID。
native final function NotiRequestMentorInfo(int nOccuID);

// 参数: 无。
// 功能: 请求当前可用任务列表。
// 参数: 无。
native final function NotiQuestInfo();

// 参数:
//   int Npc, string Category: 调用时传入的参数。
// 功能: 查询 NPC 出售物品的价格表。
// 参数:
//   Npc(int): NPC 唯一标识。
//   Category(string): 商品分类名称。
native final function NotiSellPrices(int Npc, string Category);
// 参数:
//   Npc(int): 调用时传入的参数。
// 功能: 查询 NPC 回收物品的价格。
// 参数:
//   Npc(int): NPC 唯一标识。
native final function NotiBuyPrices(int Npc);
// 参数:
//   Npc(int): 调用时传入的参数。
// 功能: 查询 NPC 的修理费用。
// 参数:
//   Npc(int): NPC 唯一标识。
native final function NotiRepairPrices(int Npc);
// 参数:
//   int Npc, int Item, int Amount: 调用时传入的参数。
// 功能: 向 NPC 购买物品。
// 参数:
//   Npc(int): NPC 唯一标识。
//   Item(int): 商品 ID。
//   Amount(int): 购买数量。
native final function NotiBuy(int Npc, int Item, int Amount);
// 参数:
//   int Npc, int InvenIndex, int InvenX, int InvenY: 调用时传入的参数。
// 功能: 将背包中的物品卖给 NPC。
// 参数:
//   Npc(int): NPC 唯一标识。
//   InvenIndex(int): 背包索引。
//   InvenX(int): 背包 X 坐标。
//   InvenY(int): 背包 Y 坐标。
native final function NotiSell(int Npc, int InvenIndex, int InvenX, int InvenY);
// 参数:
//   int Npc, byte EquipPlace: 调用时传入的参数。
// 功能: 将当前穿戴的装备卖给 NPC。
// 参数:
//   Npc(int): NPC 唯一标识。
//   EquipPlace(byte): 装备槽位。
native final function NotiSellWorn(int Npc, byte EquipPlace);
// 参数:
//   int Npc, int InvenIndex, int ItemX, int ItemY: 调用时传入的参数。
// 功能: 修理背包中的物品。
// 参数:
//   Npc(int): NPC 唯一标识。
//   InvenIndex(int): 背包索引。
//   ItemX(int): 物品 X 坐标。
//   ItemY(int): 物品 Y 坐标。
native final function NotiRepair(int Npc, int InvenIndex, int ItemX, int ItemY);
// 参数:
//   int Npc, byte EquipPlace: 调用时传入的参数。
// 功能: 修理已装备的物品。
// 参数:
//   Npc(int): NPC 唯一标识。
//   EquipPlace(byte): 装备槽位。
native final function NotiRepairWorn(int Npc, byte EquipPlace);

// 参数:
//   Npc(int): 调用时传入的参数。
// 功能: 请求与仓库银行相关的信息。
// 参数:
//   Npc(int): 仓库 NPC 或银行 ID。
native final function NotiStashBankInfo(int Npc);
// 参数:
//   Stash(int): 调用时传入的参数。
// 功能: 获取指定仓库的详细信息。
// 参数:
//   Stash(int): 仓库 ID。
native final function NotiStashInfo(int Stash);
// 参数:
//   Stash(int): 调用时传入的参数。
// 功能: 丢弃仓库中的债务物品。
// 参数:
//   Stash(int): 仓库 ID。
native final function NotiStashDebtTrash(int Stash);
// 参数:
//   Stash(int): 调用时传入的参数。
// 功能: 打开仓库债务处理界面。
// 参数:
//   Stash(int): 仓库 ID。
native final function NotiStashDebtOpen(int Stash);
// 参数:
//   Stash(int): 调用时传入的参数。
// 功能: 关闭当前仓库箱体。
// 参数:
//   Stash(int): 仓库 ID。
native final function NotiStashDismissBox(int Stash);
// 参数: 无。
// 功能: 关闭仓库银行界面。
// 参数:
//   Stash(int): 仓库 ID。
native final function NotiStashDismissBank();
// 参数:
//   StashName(string): 调用时传入的参数。
// 功能: 创建新的仓库页。
// 参数:
//   StashName(string): 新仓库的名称。
native final function NotiStashNew(string StashName);
// 参数:
//   Stash(int): 调用时传入的参数。
// 功能: 打开指定仓库页。
// 参数:
//   Stash(int): 仓库 ID。
native final function NotiStashOpen(int Stash);
// 参数:
//   Stash(int): 调用时传入的参数。
// 功能: 废弃或删除整个仓库。
// 参数:
//   Stash(int): 仓库 ID。
native final function NotiStashTrash(int Stash);
// 参数:
//   int Stash, string Friend: 调用时传入的参数。
// 功能: 将仓库共享给指定好友。
// 参数:
//   Stash(int): 仓库 ID。
//   Friend(string): 好友角色名。
native final function NotiStashShare(int Stash, string Friend);
// 参数:
//   int Stash, string Friend: 调用时传入的参数。
// 功能: 取消与好友共享仓库。
// 参数:
//   Stash(int): 仓库 ID。
//   Friend(string): 好友角色名。
native final function NotiStashUnshare(int Stash, string Friend);
// 参数:
//   int Stash, string StashName: 调用时传入的参数。
// 功能: 重命名仓库页。
// 参数:
//   Stash(int): 仓库 ID。
//   StashName(string): 新的仓库名称。
native final function NotiStashRename(int Stash, string StashName);
// 参数:
//   Stash(int): 调用时传入的参数。
// 功能: 拒绝他人共享仓库的邀请。
// 参数:
//   Stash(int): 仓库 ID。
native final function NotiStashShareRefuse(int Stash);

// 参数:
//   int Stash, int InvenIndex, int InvenX, int InvenY, int StashX, int StashY: 调用时传入的参数。
// 功能: 将背包物品存入仓库。
// 参数:
//   Stash(int): 仓库 ID。
//   InvenIndex(int): 背包容器索引。
//   InvenX(int): 背包 X 坐标。
//   InvenY(int): 背包 Y 坐标。
//   StashX(int): 仓库格 X 坐标。
//   StashY(int): 仓库格 Y 坐标。
native final function NotiStashAddItem(int Stash, int InvenIndex, int InvenX, int InvenY, int StashX, int StashY);
// 参数:
//   int Stash, int StashX, int StashY, int InvenX, int InvenY, int InvenIndex: 调用时传入的参数。
// 功能: 将仓库物品取回背包。
// 参数:
//   Stash(int): 仓库 ID。
//   StashX(int): 仓库格 X 坐标。
//   StashY(int): 仓库格 Y 坐标。
//   InvenX(int): 背包目标 X 坐标。
//   InvenY(int): 背包目标 Y 坐标。
//   InvenIndex(int): 背包容器索引。
native final function NotiStashRemoveItem(int Stash, int StashX, int StashY, int InvenX, int InvenY, int InvenIndex);
// 参数:
//   int Stash, int FromX, int FromY, int ToX, int ToY: 调用时传入的参数。
// 功能: 在仓库内部移动物品。
// 参数:
//   Stash(int): 仓库 ID。
//   FromX(int): 原位置 X 坐标。
//   FromY(int): 原位置 Y 坐标。
//   ToX(int): 目标位置 X 坐标。
//   ToY(int): 目标位置 Y 坐标。
native final function NotiStashArrangeItem(int Stash, int FromX, int FromY, int ToX, int ToY);
// 参数:
//   int Stash, string Amount: 调用时传入的参数。
// 功能: 存入金币到仓库。
// 参数:
//   Stash(int): 仓库 ID。
//   Amount(string): 存入金额（字符串）。
native final function NotiStashAddMoney(int Stash, string Amount);
// 参数:
//   int Stash, string Amount: 调用时传入的参数。
// 功能: 从仓库取出金币。
// 参数:
//   Stash(int): 仓库 ID。
//   Amount(string): 取出金额（字符串）。
native final function NotiStashRemoveMoney(int Stash, string Amount);
//@by wj(07/22) for Stash MultiSelect
// 参数:
//   int Stash, int InvenIndex, array<SephirothItem> SelectedItems: 调用时传入的参数。
// 功能: 批量将多个物品存入仓库。
// 参数:
//   Stash(int): 仓库 ID。
//   InvenIndex(int): 背包容器索引。
//   SelectedItems(array<SephirothItem>): 要存入的物品列表。
native final function NotiStashAddItemMany(int Stash, int InvenIndex, array<SephirothItem> SelectedItems);
// 参数:
//   int Stash, array<SephirothItem> SelectedItems, int InvenIndex: 调用时传入的参数。
// 功能: 批量从仓库中取出物品。
// 参数:
//   Stash(int): 仓库 ID。
//   SelectedItems(array<SephirothItem>): 要取出的物品列表。
//   InvenIndex(int): 背包容器索引。
native final function NotiStashRemoveItemMany(int Stash, array<SephirothItem> SelectedItems, int InvenIndex);

// 参数:
//   int Npc, string Link: 调用时传入的参数。
// 功能: 触发与 NPC 的对话链接。
// 参数:
//   Npc(int): NPC 唯一标识。
//   Link(string): 对话链接关键字。
native final function NotiNpcDialog(int Npc, string Link);

// 参数:
//   Command(string): 调用时传入的参数。
// 功能: 向服务器发送自定义控制台命令。
// 参数:
//   Command(string): 完整命令字符串。
native final function NotiCommand(string Command);

// 参数:
//   string Skill, int Seq, int Target, vector Location, float SpeedRate, int ComboCount: 调用时传入的参数。
// 功能: 执行近战连招动作。
// 参数:
//   Skill(string): 技能名称。
//   Seq(int): 动作序号。
//   Target(int): 目标 Actor ID。
//   Location(vector): 目标位置。
//   SpeedRate(float): 动作速度倍率。
//   ComboCount(int): 连击次数。
native final function NotiActMeleeCombo(string Skill, int Seq, int Target, vector Location, float SpeedRate, int ComboCount);
// 参数:
//   string Skill, int Seq, int Target, vector Location, float SpeedRate: 调用时传入的参数。
// 功能: 结束近战连招动作。
// 参数:
//   Skill(string): 技能名称。
//   Seq(int): 动作序号。
//   Target(int): 目标 Actor ID。
//   Location(vector): 动作位置。
//   SpeedRate(float): 速度倍率。
native final function NotiActMeleeFinish(string Skill, int Seq, int Target, vector Location, float SpeedRate);
// 参数:
//   int Seq, vector MyLocation, int Target, vector Location, int WithdrawDistance: 调用时传入的参数。
// 功能: 汇报近战命中结果。
// 参数:
//   Seq(int): 判定序号。
//   MyLocation(vector): 施法者位置。
//   Target(int): 被击中目标。
//   Location(vector): 命中位置。
//   WithdrawDistance(int): 击退距离。
native final function NotiHitMelee(int Seq, vector MyLocation, int Target, vector Location, int WithdrawDistance);
// 参数:
//   string Skill, int Seq, int Target, vector Location, float SpeedRate: 调用时传入的参数。
// 功能: 开始施放指定技能。
// 参数:
//   Skill(string): 技能名称。
//   Seq(int): 施法序号。
//   Target(int): 目标 ID。
//   Location(vector): 目标位置。
//   SpeedRate(float): 速度倍率。
native final function NotiCast(string Skill, int Seq, int Target, vector Location, float SpeedRate);
// 参数:
//   int Seq, int Target, vector Location: 调用时传入的参数。
// 功能: 释放远程射击或投射技能。
// 参数:
//   Seq(int): 动作序号。
//   Target(int): 目标 ID。
//   Location(vector): 目标位置。
native final function NotiFire(int Seq, int Target, vector Location);
// 参数:
//   Seq(int): 调用时传入的参数。
// 功能: 通知服务器本次射击失败。
// 参数:
//   Seq(int): 动作序号。
native final function NotiFireFail(int Seq);
// 参数:
//   int Seq, vector MyLocation, int Target, vector Location: 调用时传入的参数。
// 功能: 汇报法术命中的结果。
// 参数:
//   Seq(int): 判定序号。
//   MyLocation(vector): 施法者位置。
//   Target(int): 目标 ID。
//   Location(vector): 命中位置。
native final function NotiHitMagic(int Seq, vector MyLocation, int Target, vector Location);
// 参数:
//   string Skill, int Seq, int Target, vector Location, int Pitch: 调用时传入的参数。
// 功能: 触发远程蓄力或瞄准动作。
// 参数:
//   Skill(string): 技能名称。
//   Seq(int): 动作序号。
//   Target(int): 目标 ID。
//   Location(vector): 目标位置。
//   Pitch(int): 俯仰角度。
native final function NotiActRange(string Skill, int Seq, int Target, vector Location, int Pitch);
// 参数:
//   int Seq, vector MyLocation, int Target, vector Location: 调用时传入的参数。
// 功能: 汇报远程攻击的命中结果。
// 参数:
//   Seq(int): 判定序号。
//   MyLocation(vector): 施放位置。
//   Target(int): 目标 ID。
//   Location(vector): 命中位置。
native final function NotiHitRange(int Seq, vector MyLocation, int Target, vector Location);
// 参数:
//   string Act, optional float ActRate: 调用时传入的参数。
// 功能: 执行非战斗单人动作或互动。
// 参数:
//   Act(string): 动作名称。
//   ActRate(optional float): 动作速度倍率（可选）。
native final function NotiActSolo(string Act, optional float ActRate);
// 参数:
//   Skill(string): 调用时传入的参数。
// 功能: 触发灵魂或召唤类施法动作。
// 参数:
//   Skill(string): 技能名称。
native final function NotiSpiritCast(string Skill);
// 参数:
//   string Skill, bool bSet: 调用时传入的参数。
// 功能: 控制灵魂系技能的持续或开关。
// 参数:
//   Skill(string): 技能名称。
//   bSet(bool): 是否启用该技能效果。
native final function NotiSpiritMagic(string Skill, bool bSet);

// 参数: 无。
// 功能: 请求好友列表及分组信息。
// 参数: 无。
native final function NotiBuddyInfo();
// 参数:
//   string GroupName, string BuddyName: 调用时传入的参数。
// 功能: 向指定分组添加好友。
// 参数:
//   GroupName(string): 好友分组名称。
//   BuddyName(string): 好友角色名。
native final function NotiBuddyAdd(string GroupName, string BuddyName);
// 参数:
//   BuddyName(string): 调用时传入的参数。
// 功能: 从好友列表移除指定玩家。
// 参数:
//   BuddyName(string): 好友角色名。
native final function NotiBuddyRemove(string BuddyName);
// 参数:
//   GroupName(string): 调用时传入的参数。
// 功能: 创建新的好友分组。
// 参数:
//   GroupName(string): 新分组名称。
native final function NotiBuddyGroupAdd(string GroupName);
// 参数:
//   GroupName(string): 调用时传入的参数。
// 功能: 删除现有的好友分组。
// 参数:
//   GroupName(string): 分组名称。
native final function NotiBuddyGroupRemove(string GroupName);
// 参数:
//   string GroupName, string NewGroupName: 调用时传入的参数。
// 功能: 重命名好友分组。
// 参数:
//   GroupName(string): 原分组名称。
//   NewGroupName(string): 新的名称。
native final function NotiBuddyGroupRename(string GroupName, string NewGroupName);
// 参数:
//   string GroupName, string BuddyName, string NewGroupName: 调用时传入的参数。
// 功能: 将好友移动到新的分组。
// 参数:
//   GroupName(string): 原分组名称。
//   BuddyName(string): 好友角色名。
//   NewGroupName(string): 目标分组名称。
native final function NotiBuddyArrange(string GroupName, string BuddyName, string NewGroupName);

// 参数:
//   string BuddyName, string Message: 调用时传入的参数。
// 功能: 向好友发送便笺邮件。
// 参数:
//   BuddyName(string): 收件人角色名。
//   Message(string): 便笺内容。
native final function NotiNoteSend(string BuddyName, string Message);
// 参数:
//   string GroupName, string Message: 调用时传入的参数。
// 功能: 向整个好友分组群发便笺。
// 参数:
//   GroupName(string): 收件分组名称。
//   Message(string): 便笺内容。
native final function NotiNoteSendToGroup(string GroupName, string Message);

// 参数: 无。
// 功能: 请求便笺收件箱的列表信息。
// 参数: 无。
native final function NotiNoteInboxInfo();
// 参数:
//   NoteId(int): 调用时传入的参数。
// 功能: 读取指定便笺内容。
// 参数:
//   NoteId(int): 便笺唯一 ID。
native final function NotiNoteInboxRead(int NoteId);
// 参数:
//   NoteId(int): 调用时传入的参数。
// 功能: 删除指定便笺。
// 参数:
//   NoteId(int): 便笺唯一 ID。
native final function NotiNoteInboxRemove(int NoteId);

// 参数: 无。
// 功能: 通知服务器角色执行跳跃。
// 参数: 无。
native final function NotiJump();
// 参数: 无。
// 功能: 汇报角色的常规移动输入。
// 参数: 无。
native final function NotiMove();

// 参数:
//   int InvenFromX, int InvenFromY, int InvenToX, int InvenToY, string SelectedAffix, int invenIndex: 调用时传入的参数。
// 功能: 对物品应用选中的附加属性。
// 参数:
//   InvenFromX(int): 来源格 X 坐标。
//   InvenFromY(int): 来源格 Y 坐标。
//   InvenToX(int): 目标格 X 坐标。
//   InvenToY(int): 目标格 Y 坐标。
//   SelectedAffix(string): 所应用的词缀名称。
//   invenIndex(int): 背包容器索引。
native final function NotiApplySelect(int InvenFromX, int InvenFromY, int InvenToX, int InvenToY, string SelectedAffix, int invenIndex);

//+jhjung,2003.7.3: Lobby & 2nd skill
// 参数: 无。
// 功能: 请求返回游戏大厅。
// 参数: 无。
native final function NotiGoLobby();
// 参数:
//   string Skill, int Target, vector Location: 调用时传入的参数。
// 功能: 触发二段技能的施放动作。
// 参数:
//   Skill(string): 技能名称。
//   Target(int): 目标 ID。
//   Location(vector): 目标位置。
native final function NotiSkill2ndAct(string Skill, int Target, vector Location);
// 参数:
//   string Skill, int Target, vector Location: 调用时传入的参数。
// 功能: 汇报二段技能的命中结果。
// 参数:
//   Skill(string): 技能名称。
//   Target(int): 目标 ID。
//   Location(vector): 命中位置。
native final function NotiSkill2ndHit(string Skill, int Target, vector Location);
//native final function NotiSkill2ndUsePoint(string Skill);

//@by wj(10/06)------
// 参数: 无。
// 功能: 将宠物收回宠物笼。
// 参数: 无。
native final function NotiPetToCage();
// 参数:
//   int FromPosX, int FromPosY, int ToPosX, int ToPosY, string PetName, int invenIndex: 调用时传入的参数。
// 功能: 向宠物面板提交命名或喂养等操作。
// 参数:
//   FromPosX(int): 源格 X。
//   FromPosY(int): 源格 Y。
//   ToPosX(int): 目标格 X。
//   ToPosY(int): 目标格 Y。
//   PetName(string): 宠物名称。
//   invenIndex(int): 容器索引。
native final function NotiApplyInput(int FromPosX, int FromPosY, int ToPosX, int ToPosY, string PetName, int invenIndex);
//@by wj(040611)------ Pet 
// 参数: 无。
// 功能: 请求宠物聊天关键词列表。
// 参数: 无。
native final function NotiPetChatInfo();
// 参数:
//   array<string> OwnerWords, string PetComment: 调用时传入的参数。
// 功能: 新增宠物聊天词条。
// 参数:
//   OwnerWords(array<string>): 主人触发词数组。
//   PetComment(string): 宠物回复文本。
native final function NotiPetChatAdd(array<string> OwnerWords, string PetComment);
// 参数: 无。
// 功能: 删除全部宠物聊天词条。
// 参数: 无。
native final function NotiPetChatDelete();
// 参数:
//   int OwnerX, int OwnerY, int PetX, int PetY: 调用时传入的参数。
// 功能: 将物品存入宠物背包。
// 参数:
//   OwnerX(int): 主人背包 X。
//   OwnerY(int): 主人背包 Y。
//   PetX(int): 宠物背包 X。
//   PetY(int): 宠物背包 Y。
native final function NotiPetInvenItemIn(int OwnerX, int OwnerY, int PetX, int PetY);
// 参数:
//   int PetX, int PetY, int OwnerX, int OwnerY: 调用时传入的参数。
// 功能: 从宠物背包取出物品到主人背包。
// 参数:
//   PetX(int): 宠物背包 X。
//   PetY(int): 宠物背包 Y。
//   OwnerX(int): 主人背包 X。
//   OwnerY(int): 主人背包 Y。
native final function NotiPetInvenItemOut(int PetX, int PetY, int OwnerX, int OwnerY);
// 参数:
//   int FromX, int FromY, int ToX, int ToY: 调用时传入的参数。
// 功能: 调整宠物背包内物品位置。
// 参数:
//   FromX(int): 原位置 X。
//   FromY(int): 原位置 Y。
//   ToX(int): 新位置 X。
//   ToY(int): 新位置 Y。
native final function NotiPetInvenItemMove(int FromX, int FromY, int ToX, int ToY);
// 参数:
//   SelectedItem(array<SephirothItem>): 调用时传入的参数。
// 功能: 批量将物品存入宠物背包。
// 参数:
//   SelectedItem(array<SephirothItem>): 要存入的物品集合。
native final function NotiPetInvenItemInMany(array<SephirothItem> SelectedItem);
// 参数:
//   SelectedItem(array<SephirothItem>): 调用时传入的参数。
// 功能: 批量从宠物背包取出物品。
// 参数:
//   SelectedItem(array<SephirothItem>): 要取出的物品集合。
native final function NotiPetInvenItemOutMany(array<SephirothItem> SelectedItem);
//@by wj(040621)-----
// 参数: 无。
// 功能: 自动整理宠物背包。
// 参数: 无。
native final function NotiPetInvenAutoArrange();
// 参数:
//   Index(int): 调用时传入的参数。
// 功能: 删除指定索引的宠物聊天词条。
// 参数:
//   Index(int): 词条索引。
native final function NotiPetChatDeleteIndex(int Index);
//-------------------

//SubInventory-------
// 参数:
//   int OwnerX, int OwnerY, int SubX, int SubY: 调用时传入的参数。
// 功能: 将物品存入副背包。
// 参数:
//   OwnerX(int): 主人背包 X。
//   OwnerY(int): 主人背包 Y。
//   SubX(int): 副背包 X。
//   SubY(int): 副背包 Y。
native final function NotiSubInvenItemIn(int OwnerX, int OwnerY, int SubX, int SubY);
// 参数:
//   int SubX, int SubY, int OwnerX, int OwnerY: 调用时传入的参数。
// 功能: 从副背包取出物品。
// 参数:
//   SubX(int): 副背包 X。
//   SubY(int): 副背包 Y。
//   OwnerX(int): 主人背包 X。
//   OwnerY(int): 主人背包 Y。
native final function NotiSubInvenItemOut(int SubX, int SubY, int OwnerX, int OwnerY);
// 参数:
//   int SrcIndex, int SrcX, int SrcY, int DestX, int DestY: 调用时传入的参数。
// 功能: 在副背包内部移动物品。
// 参数:
//   SrcIndex(int): 源容器索引。
//   SrcX(int): 源格 X。
//   SrcY(int): 源格 Y。
//   DestX(int): 目标格 X。
//   DestY(int): 目标格 Y。
native final function NotiSubInvenItemMove(int SrcIndex, int SrcX, int SrcY, int DestX, int DestY);
// 参数:
//   SelectedItem(array<SephirothItem>): 调用时传入的参数。
// 功能: 批量存入物品到副背包。
// 参数:
//   SelectedItem(array<SephirothItem>): 要存入的物品集合。
native final function NotiSubInvenItemInMany(array<SephirothItem> SelectedItem);
// 参数:
//   SelectedItem(array<SephirothItem>): 调用时传入的参数。
// 功能: 批量从副背包取出物品。
// 参数:
//   SelectedItem(array<SephirothItem>): 要取出的物品集合。
native final function NotiSubInvenItemOutMany(array<SephirothItem> SelectedItem);
// 参数:
//   SubInvenIndex(int): 调用时传入的参数。
// 功能: 自动整理指定副背包。
// 参数:
//   SubInvenIndex(int): 副背包索引。
native final function NotiSubInvenAutoArrange(int SubInvenIndex);
//--------------------
//SubInventory2
// 参数:
//   int SrcIndex, int SrcX, int SrcY, int DestIndex, int DestX, int DestY: 调用时传入的参数。
// 功能: 在不同背包容器之间移动物品。
// 参数:
//   SrcIndex(int): 源容器索引。
//   SrcX(int): 源格 X。
//   SrcY(int): 源格 Y。
//   DestIndex(int): 目标容器索引。
//   DestX(int): 目标格 X。
//   DestY(int): 目标格 Y。
native final function NotiInvenItemMove(int SrcIndex, int SrcX, int SrcY, int DestIndex, int DestX, int DestY);
// 参数:
//   int SrcIndex, array<SephirothItem> SelectedItem, int DestIndex: 调用时传入的参数。
// 功能: 批量在背包容器之间移动物品。
// 参数:
//   SrcIndex(int): 源容器索引。
//   SelectedItem(array<SephirothItem>): 要移动的物品列表。
//   DestIndex(int): 目标容器索引。
native final function NotiInvenItemMoveMany(int SrcIndex, array<SephirothItem> SelectedItem, int DestIndex);
// 参数:
//   SrcIndex(int): 调用时传入的参数。
// 功能: 打开副背包界面。
// 参数:
//   SrcIndex(int): 副背包索引。
native final function NotiSubInvenOpen(int SrcIndex);
//--------------------

//@by wj(12/12)------	castle
// 参数:
//   castle(string): 调用时传入的参数。
// 功能: 请求城堡的整体信息。
// 参数:
//   castle(string): 城堡名称。
native final function NotiCastleInfo(string castle);
// 参数:
//   string castle, string msg: 调用时传入的参数。
// 功能: 发布领主公告。
// 参数:
//   castle(string): 城堡名称。
//   msg(string): 公告文本。
native final function NotiCastleLordAnnounce(string castle, string msg);
// 参数:
//   string castle, float rate: 调用时传入的参数。
// 功能: 调整城堡的一般税率。
// 参数:
//   castle(string): 城堡名称。
//   rate(float): 税率百分比。
native final function NotiCastleLordTaxRate(string castle, float rate);
// 参数:
//   string castle, float rate: 调用时传入的参数。
// 功能: 调整城堡的摆摊税率。
// 参数:
//   castle(string): 城堡名称。
//   rate(float): 税率百分比。
native final function NotiCastleLordBoothTaxRate(string castle, float rate);
// 参数:
//   string castle, string moneystring: 调用时传入的参数。
// 功能: 从城堡资金中提取金币。
// 参数:
//   castle(string): 城堡名称。
//   moneystring(string): 提取金额。
native final function NotiCastleLordWithdrawMoney(string castle, string moneystring);
// 参数:
//   string castle, string moneystring: 调用时传入的参数。
// 功能: 向城堡资金存入金币。
// 参数:
//   castle(string): 城堡名称。
//   moneystring(string): 存入金额。
native final function NotiCastleLordDepositMoney(string castle, string moneystring);
//-------------------

//@by wj(040203)------
// 参数: 无。
// 功能: 请求公会成员列表。
// 参数: 无。
native final function NotiClanMemberInfo();
// 参数: 无。
// 功能: 请求正在申请加入公会的玩家列表。
// 参数: 无。
native final function NotiClanApplicantInfo();
// 参数: 无。
// 功能: 标记自己正在申请加入某公会。
// 参数: 无。
native final function NotiClanApplying();
// 参数:
//   ClanName(string): 调用时传入的参数。
// 功能: 申请加入指定公会。
// 参数:
//   ClanName(string): 公会名称。
native final function NotiClanApply(string ClanName);
// 参数: 无。
// 功能: 取消对公会的申请。
// 参数: 无。
native final function NotiClanCancelApply();
// 参数:
//   Name(string): 调用时传入的参数。
// 功能: 批准申请者加入公会。
// 参数:
//   Name(string): 申请者角色名。
native final function NotiClanAdmit(string Name);
// 参数:
//   Name(string): 调用时传入的参数。
// 功能: 拒绝申请者加入公会。
// 参数:
//   Name(string): 申请者角色名。
native final function NotiClanReject(string Name);
// 参数:
//   Name(string): 调用时传入的参数。
// 功能: 将玩家列入公会黑名单。
// 参数:
//   Name(string): 目标角色名。
native final function NotiClanBlock(string Name);
// 参数:
//   Name(string): 调用时传入的参数。
// 功能: 将玩家从公会黑名单移除。
// 参数:
//   Name(string): 目标角色名。
native final function NotiClanUnblock(string Name);
// 参数:
//   Name(string): 调用时传入的参数。
// 功能: 将成员开除出公会。
// 参数:
//   Name(string): 成员角色名。
native final function NotiClanExpel(string Name);
// 参数:
//   Name(string): 调用时传入的参数。
// 功能: 任命新的公会会长。
// 参数:
//   Name(string): 被任命者角色名。
native final function NotiClanMaster(string Name);
// 参数:
//   message(string): 调用时传入的参数。
// 功能: 发布公会公告。
// 参数:
//   message(string): 公告内容。
native final function NotiClanAnnounce(string message);
// 参数:
//   ClanName(string): 调用时传入的参数。
// 功能: 向其他公会发起宣战。
// 参数:
//   ClanName(string): 目标公会名称。
native final function NotiClanBattle(string ClanName);
// 参数:
//   string TargetName, string NewTitle: 调用时传入的参数。
// 功能: 授予成员新的公会头衔。
// 参数:
//   TargetName(string): 目标成员。
//   NewTitle(string): 新的头衔。
native final function NotiClanTitle(string TargetName, string NewTitle);
// 参数:
//   string Name, int i: 调用时传入的参数。
// 功能: 调整公会成员列表顺序或职位。
// 参数:
//   Name(string): 成员角色名。
//   i(int): 排序或职位索引。
native final function NotiClanOrder(string Name, int i);
//@by wj(040317)------
// 参数:
//   Name(string): 调用时传入的参数。
// 功能: 设置代理会长。
// 参数:
//   Name(string): 代理人角色名。
native final function NotiClanDelegate(string Name);
// 参数:
//   Name(string): 调用时传入的参数。
// 功能: 取消代理会长职务。
// 参数:
//   Name(string): 代理人角色名。
native final function NotiClanCancelDelegate(string Name);
//--------------------
//@by wj(040401)------
// 参数: 无。
// 功能: 退出当前公会。
// 参数: 无。
native final function NotiClanQuit();
// 参数:
//   Name(string): 调用时传入的参数。
// 功能: 回收或管理公会授予的物品。
// 参数:
//   Name(string): 物品持有人角色名。
native final function NotiClanEndowedItem(string Name);
//--------------------

// 参数:
//   string ClanName, string MyName, string Msg: 调用时传入的参数。
// 功能: 在公会频道发送消息。
// 参数:
//   ClanName(string): 公会名称。
//   MyName(string): 发送者角色名。
//   Msg(string): 聊天内容。
native final function NotiClanTell(string ClanName, string MyName, string Msg);

//@by wj(040305)------ Item remodeling
// 参数:
//   int ItemX, int ItemY, array<SephirothItem> SelectedItems: 调用时传入的参数。
// 功能: 请求物品改造的预览说明。
// 参数:
//   ItemX(int): 背包 X 坐标。
//   ItemY(int): 背包 Y 坐标。
//   SelectedItems(array<SephirothItem>): 参与改造的物品列表。
native final function NotiRemodelItemDesc(int ItemX, int ItemY, array<SephirothItem> SelectedItems);
// 参数:
//   int npcID, int ItemX, int ItemY, array<SephirothItem> SelectedItems: 调用时传入的参数。
// 功能: 执行物品改造操作。
// 参数:
//   npcID(int): 改造 NPC ID。
//   ItemX(int): 背包 X 坐标。
//   ItemY(int): 背包 Y 坐标。
//   SelectedItems(array<SephirothItem>): 额外材料列表。
native final function NotiRemodelItem(int npcID, int ItemX, int ItemY, array<SephirothItem> SelectedItems);
//--------------------

// 参数:
//   report(string): 调用时传入的参数。
// 功能: 提交玩家举报信息。
// 参数:
//   report(string): 举报内容。
native final function NotiUserReport(string report);

//@by wj(040802)------
// 参数: 无。
// 功能: 触发变身或形态切换。
// 参数: 无。
native final function NotiTransform();
//--------------------

// 参数:
//   message(string): 调用时传入的参数。
// 功能: 向团队或比赛频道发送消息。
// 参数:
//   message(string): 聊天内容。
native final function NotiTellTeam(string message);

//Booth
// 参数: 无。
// 功能: 请求或支付摆摊费用。
// 参数: 无。
native final function NotiBoothFee();
// 参数:
//   bUseAd(bool): 调用时传入的参数。
// 功能: 开启摆摊界面并选择是否使用广告。
// 参数:
//   bUseAd(bool): 是否启用广告位。
native final function NotiBoothOpen(bool bUseAd);
// 参数: 无。
// 功能: 关闭当前摆摊。
// 参数: 无。
native final function NotiBoothClose();
// 参数:
//   int BoothState, string BoothTitle, string BoothAd, bool bUseTout: 调用时传入的参数。
// 功能: 更新摊位状态与展示信息。
// 参数:
//   BoothState(int): 摊位状态码。
//   BoothTitle(string): 摊位标题。
//   BoothAd(string): 广告语。
//   bUseTout(bool): 是否高亮宣传。
native final function NotiBoothState(int BoothState, string BoothTitle, string BoothAd, bool bUseTout);
// 参数:
//   int invenIndex, int InvenX, int InvenY, int ShowcaseX, int ShowcaseY, bool bPricePerEach, string SellPriceStr: 调用时传入的参数。
// 功能: 向摊位陈列柜放入物品。
// 参数:
//   invenIndex(int): 背包容器索引。
//   InvenX(int): 背包 X 坐标。
//   InvenY(int): 背包 Y 坐标。
//   ShowcaseX(int): 摊位柜 X 坐标。
//   ShowcaseY(int): 摊位柜 Y 坐标。
//   bPricePerEach(bool): 是否按件定价。
//   SellPriceStr(string): 出售价格字符串。
native final function NotiBoothAddItem(int invenIndex, int InvenX, int InvenY, int ShowcaseX, int ShowcaseY, bool bPricePerEach, string SellPriceStr);
// 参数:
//   int invenIndex, array<SephirothItem> ItemList, bool bPricePerEach, string SellPriceStr: 调用时传入的参数。
// 功能: 批量向摊位放入多件物品。
// 参数:
//   invenIndex(int): 背包容器索引。
//   ItemList(array<SephirothItem>): 要上架的物品列表。
//   bPricePerEach(bool): 是否按件定价。
//   SellPriceStr(string): 售价字符串。
native final function NotiBoothAddItemMany(int invenIndex, array<SephirothItem> ItemList, bool bPricePerEach, string SellPriceStr);
// 参数:
//   int ShowcaseX, int ShowcaseY: 调用时传入的参数。
// 功能: 从摊位移除单个物品。
// 参数:
//   ShowcaseX(int): 摊位柜 X 坐标。
//   ShowcaseY(int): 摊位柜 Y 坐标。
native final function NotiBoothRemoveItem(int ShowcaseX, int ShowcaseY);
// 参数:
//   ItemList(array<SephirothItem>): 调用时传入的参数。
// 功能: 批量移除摊位物品。
// 参数:
//   ItemList(array<SephirothItem>): 要移除的物品列表。
native final function NotiBoothRemoveItemMany(array<SephirothItem> ItemList);
// 参数:
//   Seller(int): 调用时传入的参数。
// 功能: 访问指定摊主的摊位。
// 参数:
//   Seller(int): 摊主玩家标识。
native final function NotiBoothVisit(int Seller);
// 参数:
//   int invenIndex, int Seller, int ShowcaseX, int ShowcaseY, bool bPricePerEach, int TotalAmount, int BuyAmount, string PaidMoney: 调用时传入的参数。
// 功能: 购买摊位上的单件物品。
// 参数:
//   invenIndex(int): 背包容器索引。
//   Seller(int): 摊主 ID。
//   ShowcaseX(int): 摊位柜 X。
//   ShowcaseY(int): 摊位柜 Y。
//   bPricePerEach(bool): 是否按件定价。
//   TotalAmount(int): 库存总量。
//   BuyAmount(int): 实际购买数量。
//   PaidMoney(string): 支付金额。
native final function NotiBoothBuyItem(int invenIndex, int Seller, int ShowcaseX, int ShowcaseY, bool bPricePerEach, int TotalAmount, int BuyAmount, string PaidMoney);
// 参数:
//   int invenIndex, int Seller, array<SephirothItem> ItemList, string PaidMoney: 调用时传入的参数。
// 功能: 批量购买摊位上的多件物品。
// 参数:
//   invenIndex(int): 背包容器索引。
//   Seller(int): 摊主 ID。
//   ItemList(array<SephirothItem>): 购买的物品列表。
//   PaidMoney(string): 支付总金额。
native final function NotiBoothBuyItemMany(int invenIndex, int Seller, array<SephirothItem> ItemList, string PaidMoney);
// 参数:
//   Seller(int): 调用时传入的参数。
// 功能: 离开当前摊位。
// 参数:
//   Seller(int): 摊主玩家标识。
native final function NotiBoothLeave(int Seller);

// InGameShop
// 参数:
//   string UserAlias, string CharacterName: 调用时传入的参数。
// 功能: 请求一次性密码用于进入商城。
// 参数:
//   UserAlias(string): 账号别名。
//   CharacterName(string): 角色名。
native final function NotiRequestOtp(string UserAlias, string CharacterName);
// 参数: 无。
// 功能: 请求发放商城购买的物品。
// 参数: 无。
native final function NotiRequestGrantItem();
// 参数: 无。
// 功能: 检查是否有新的商城赠送物品。
// 参数: 无。
native final function NotiRequestCheckNewGrantItem();

// 参数: 无。
// 功能: 请求商城商品列表。
// 参数: 无。
native final function NotiRequestInGameShopList();
// 参数: 无。
// 功能: 查询商城现金余额。
// 参数: 无。
native final function NotiRequestInGameShopCash();
// 参数:
//   nIndex(int): 调用时传入的参数。
// 功能: 购买商城商品。
// 参数:
//   nIndex(int): 商品索引。
native final function NotiRequestInGameShopBuy(int nIndex);
// 参数: 无。
// 功能: 请求订阅型商品列表。
// 参数: 无。
native final function NotiRequestInGameShopSubscriptionList();
// 参数:
//   int nIndex, int nKeyTime: 调用时传入的参数。
// 功能: 确认领取订阅奖励或延长订阅。
// 参数:
//   nIndex(int): 订阅索引。
//   nKeyTime(int): 关联密钥或时间值。
native final function NotiRequestInGameShopSubscriptionAccept(int nIndex, int nKeyTime);
// 参数:
//   int nIndex, int nKeyTime: 调用时传入的参数。
// 功能: 取消商城订阅或停止续费。
// 参数:
//   nIndex(int): 订阅索引。
//   nKeyTime(int): 关联密钥或时间值。
native final function NotiRequestInGameShopSubscriptionCancel(int nIndex, int nKeyTime);


// 2011/09/21 Add ssemp : ���� �÷��̸� �ܼ� ��ɾ�� ó�� ���� ���ϵ��� ����...
// 参数:
//   sSelectedCharacterName(string): 调用时传入的参数。
// 功能: 确认选角后开始进入游戏世界。
// 参数:
//   sSelectedCharacterName(string): 即将进入的角色名。
native final function NotiGameStartPlay(string sSelectedCharacterName);
// 参数:
//   sServerAddr(string): 调用时传入的参数。
// 功能: 请求返回大厅并连接到指定地址。
// 参数:
//   sServerAddr(string): 目标大厅服务器地址。
native final function NotiGotoLobbyEx(string sServerAddr);

// add : ���� [4/19/2012 ssemp]
// 参数:
//   string strCategoryName, int invenIndex, int InvenX, int InvenY: 调用时传入的参数。
// 功能: 分解指定类别的物品。
// 参数:
//   strCategoryName(string): 物品类别名称。
//   invenIndex(int): 背包索引。
//   InvenX(int): 背包 X 坐标。
//   InvenY(int): 背包 Y 坐标。
native final function NotiDissolveItem(string strCategoryName, int invenIndex, int InvenX, int InvenY);

defaultproperties
{
}
