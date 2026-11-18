# 其他角色跳跃与位置同步代码分析记录

## 2026-11-17 攻击加速度差异与视频反馈

**状态：分析完成，两处受限脚本清理已实施并完成必要本地验证；效果待游戏确认。** 实际实施、摘要及交付见[当前进度](REMOTE_PLAYER_MOVEMENT_IMPLEMENTATION_PLAN.md#2026-11-17-弓手与近战队列加速度补齐)。本节不以“存在差异”替代“已证明视频唯一根因”。

用户视频 `QQ20261116-224906-HD.mp4` 长 7.36 秒；用户确认是观察端看到其他角色往返，且上一版 DLL 和两份 SPG 均配套替换。用户反馈跳跃已正常。录像观察者 HUD 坐标保持 23066:34496，该值不是远端角色坐标，不能据此判断其网络位置是否不变。

| 检查范围 | 实际证据与结论 |
| --- | --- |
| 弓手攻击脚本 | CA 实际 SephirothUI.u 的 NetRecv_ActRange 在技能有效时直接清零 Acceleration；上一版构建 U 包在 IsAvatar() 或 !bSyncingPosition 时才清零。普通远端仍有误差时会跳过，这是已确认差异。 |
| 同步标记含义 | UpdateRemoteCAMoving 按水平目标误差 >= SyncCloseDistance（默认 30）设置 bSyncingPosition，不表示操作端移动输入。跳跃通知可设置 Acceleration，MoveTo 导航也可产生推力，不能因用户停手便假定远端加速度已为零。 |
| 近战队列 | CA 实际 Sephiroth.u 的 UpdateActionPool 在有效动作开始前无条件清零；上一版只对 Avatar 清零。首动作 NetRecv_ActMeleeCombo 本身已清理，不能与队列后续动作混同。 |
| 攻击结束与输入 | BowAttacking.ActionEnd/EndState 选取方法语义一致，未新增清速度/加速度。CA BowAttacking.PlayerMove 无条件清输入轴，生产只清本地；但远端父状态提前返回，未证明输入轴是摆动原因，本轮未改。两版 BowAttacking.PlayerTick 均调用 Super。 |
| 弓手 DLL | CA 回调 RVA A14A0，经 A156A 调用 SerializeFromActRange 3E890，再由 3E9E3 调脚本事件；生产回调 A45E0，经 A46AA 调用 43DE0。所查入口不对攻击者 FarMove，不把目标坐标写成攻击者 Destination；所查序列差异仅断言源码行号常量，匿名深层调用不据此全部判等。 |
| 法师施法 | CA 与上一版实际字节码 NetRecv_StartCast 均直接清零加速度；原生 SerializeFromCast 为生产 467A0、CA 41240，所查范围未发现弓手条件保留差异。不代表所有特殊远程技能已实机验收。 |
| 近战 DLL | CA 9F600/9F830 和生产 A2740/A2970 都保留网络坐标 Z+10 的位置修正；FarMove 调用为 CA 9F7B1/9F9E1、生产 A28F1/A2B21。不属于弓手 ActRange，不能把删除它称为 CA 对齐。 |
| Triumphus | 既有移动安装点仍为 6072A/60873/60908；另见 9F15B/9F18A/9F198/9F1D7 属于复活而非攻击结束。部分 Engine 碰撞分支要求 ServerController，不能直接当作弓手停止逻辑。当前解包和安装器证据未确认额外弓手停止补丁，不代表动态 VM 钩子或完整启动时序已排除。 |

CA 与当前共同使用 `max(旧水平速度,min(水平误差/累计时间,地速))` 建立追赶速度。若攻击未清旧加速度，具备继续受推力、越过目标后反向追赶的条件；这是机制推断，尚缺本次游戏 Acceleration/Velocity/收包时序实测。不能用删除速度下限、清跳跃速度或取消 Walking 来冒充已证实的 CA 修复。

本轮复用 CanApplyRemoteCAMotion，只为普通远端补齐攻击清理；原本地与业务分支、冲刺登记时序保留。实际 UCC 97 项断言及三方法字节码核对通过，详见实施记录。旧三处 DLL 补齐仅覆盖普通移动/跳跃入口，不代表完整攻击—移动—停步链已全部一致。

本地原始分析及字节码位于 [2026-11-16 分析目录](../../.tmp/jump-attack-rebound-20261116/ANALYSIS.txt)，当前构建及验证位于 [2026-11-17 任务目录](../../.tmp/ca-attack-acceleration-20261117)。上述目录为工作区过程内容，不随 Git 长期保存；本节及实施记录保留关键结论、摘要和适用边界。

## 2026-11-16 CA 原生差异与验证边界

> 实施进度更新：下述三处差异已在独立生产 DLL 副本中受限实现并完成本地验证，当前候选及摘要见[实施记录](REMOTE_PLAYER_MOVEMENT_IMPLEMENTATION_PLAN.md#2026-11-16-ca-三处原生差异实施与本地验证)。本节保留差异发现时的证据和运行验证边界。

**结论：已比较的磁盘移动函数同源，不代表 CA 装载 Triumphus 后与生产逻辑相同。** 展开的 Triumphus 含三处确定的消息应用补丁；2026-11-15 候选 DLL 仍为原生产副本，未包含这些修改。因此，之前“保留原生路径、DLL 不改字节即可对齐”的判断已修正。现行范围与进度分别见[方案](REMOTE_PLAYER_MOVEMENT_PLAN.md)和[实施计划](REMOTE_PLAYER_MOVEMENT_IMPLEMENTATION_PLAN.md)。本节为差异证据，不表示补丁已经实施或完成实机验收。

### 本次固定样本

| 样本 | SHA-256 |
| --- | --- |
| [生产 Sephiroth.dll](../Bin/Sephiroth.dll) | `e20b332cee1cff232a85f0a6b2aa67ff752ff281694f66fd30b402ece3376209` |
| [CA Sephiroth.dll](../Bin-CA/Sephiroth.dll) | `7aefce4ea3d4a20780dda00db15507814ad0dfce6fa6be3d65772828cd461f29` |
| [生产 Engine.dll](../Bin/Engine.dll) | `d555c0a3be748f65a512c9319fde9228109d2e3fe5c0bc2699b557e6340fbb48` |
| [CA Engine.dll](../Bin-CA/Engine.dll) | `a84d06acc4dbc0719b8313847f618d45a66a1b9d493eb56c3e8a2cf8316eb215` |
| [CA Triumphus.dll](../Bin-CA/Triumphus.dll) | `075be248d5d5cc5ff58f83ee59502ef8210699247920ef701bb77fb3b81bc50d` |

RVA 相对各自 DLL 的加载基址；文件偏移必须经 PE 节表映射，不能混用。`Bin-CA` 是本地未跟踪对照样本，不为保存证据而将整套二进制加入版本库。

### 移动与跳跃主要调用链

| 阶段 | 已核对入口与行为 |
| --- | --- |
| 本地通知发送 | SepNetInterface 的 execJump：生产 `0x7CB80`、CA `0x795C0`；execMove：生产 `0x7CC70`、CA `0x796B0`。本次三处差异位于远端接收应用，不要求改动本地发送。 |
| 队列分发 | Engine 的 UClientNetDriver.TickDispatch 调接口虚表 `+0x84`；CA 对应 `0x685E0`，取包后按注册处理器分发，附近移动回调注册键为 `0xB`。 |
| 角色与消息构造 | CBNearOccupantMoved：生产 `0x75750`、CA `0x72120`；查找角色控制器并验证 ClientController 类型。移动记录构造器：生产 `0x74D90`、CA `0x71760`。 |
| 原生消息应用 | 生产 `0x65620`、CA `0x60650`，调用 eventNetRecv_PlayerMove；Triumphus 三处修改作用于此函数内部，详见下表。 |
| 脚本登记与消费 | CA NetRecv_PlayerMove 登记目标和运动类型，跳包登记 Acc/JumpZ；PlayerTick 累加时间，经状态 PlayerMove/Approaching.PlayerMove 消费。`S=max(旧水平速度,min(XY距离/累计帧时,当前地速))`，`Velocity=S*Normal(三维方向)`，随后按类型尝试起跳；普通包可覆盖未消费的待跳。 |
| 跳跃与动画 | Hero.DoJump 先检查 bServerAdmitJump，再进入 Character/Pawn.DoJump。Pawn 检查蹲伏和物理状态；地面慢走使用 Default.JumpZ，相应奔跑分支使用当前 JumpZ，移动底座可能叠加 Z。父类成功后 Character 才按慢走 WalkingPct 缩放 Z、调用 CHAR_PlayInAir；TweenAnim(0.5) 不证明完整跳跃序列会续播。 |
| 物理与落地 | performPhysics/startNewPhysics 分发至 physWalking/physFalling，再经 MoveActor、碰撞、processLanded 和脚本 Landed/Landfloor。CA 普通 Landfloor 只在本地重置目标，远端保留目标。实际批量收包、各 Actor 调度和导航覆盖的帧内先后仍需游戏观察。 |

已扩大比较到 33 个 Core/Engine/Sephiroth 公开方法及上述 5 个私有/native 入口，所选范围归一化结构相同；startNewPhysics 的指令与尾部 16 项状态跳表分别核对。归一化仍有未解析匿名辅助调用、可变数据和动态虚调用，不能据此认定完整 DLL 或深层所有分支等价。

### Triumphus 三处确定的修改配方

展开 Triumphus 的 Sephiroth 安装函数 RVA 为 `0x54320`，三项调用位于 `0x54CF2–0x54D24`；模块对象构造器 `0x50F40` 将首个虚方法设为此安装函数，`[对象+4]` 保存取得的 Sephiroth 模块句柄。这三项不位于该函数的 INI 条件分支内；完整启动后何时自动执行到此处尚未实机观察。

| 修改 | CA RVA | 生产 RVA / 文件偏移 | 两侧原字节 | CA 配方及效果 |
| --- | --- | --- | --- | --- |
| 跳跃前 FarMoveActor | `0x6072A` | `0x656FA` / `0x64AFA` | `FF D2` | NOP 2 字节；跳包不再提前搬移 Pawn，而由脚本登记目标并延后起跳。 |
| 水平零位移过滤 | `0x60873` | `0x65843` / `0x64C43` | `75 17 DD D8 8B 06` | 写 `E9 14 00 00 00 90`，转到 CA `0x6088C` / 生产 `0x6585C`；放行纯垂直变化及重复坐标。 |
| 小位移过滤 | `0x60908` | `0x658D8` / `0x64CD8` | `0F 85 92 00 00 00` | NOP 6 字节；原先不超过 30 的小位移改走脚本事件及 Walking。 |

表中是 CA 原配方和生产对应位置；后续候选使用远端/业务门禁跳板实现对应行为，并未直接按表无条件写入。跳跃前 FarMove 原调用被跳过时额外回收 28 字节参数，以保持生产 ABI。实际生成器与验证结果见最新实施记录；本表不能代替完整候选文件。

三处配方仍保留历史坐标 X 为零的哨兵、超过 2000 的位置修正、原地速处理和普通回调后的 `SetPhysics(Walking)`。30/2000 的距离是相邻网络坐标的三维位移；水平零位移是此前另一项独立过滤，不能把 30 阈值概括成单纯 XY 距离，也不能与脚本的 Pawn 到目标误差混用。

### 配方前后的受控结果

| 输入情形 | 磁盘原分支 | 套用 CA 三处配方后的分支 |
| --- | --- | --- |
| 重复坐标或纯垂直变化，历史 X 非零 | 不调用普通移动事件 | 普通事件 → Walking |
| 三维位移 20 或 30 | FarMoveActor → None | 普通事件 → Walking |
| 三维位移 40 或 2000 | 普通事件 → Walking | 不变 |
| 三维位移 2001 | FarMoveActor → None | 不变 |
| 历史 X 为零 | 哨兵路径，不调用普通事件 | 不变 |
| 跳跃包 | FarMoveActor → 跳跃事件 | 跳跃事件，不先 FarMoveActor |

以上来自九组 Unicorn 分支对比，FarMove、脚本事件与 SetPhysics 使用受控替身，不模拟地图、物理结果或网络调度。另在 CA 原始 SEP 隔离副本的入口暂停进程中，直接调用真实 Triumphus 助手，仅操作新分配内存，验证了 NOP2、NOP6 和六字节相对 JMP 的写入结果；游戏主线程没有恢复。这验证助手语义，不等于自动安装流程已完成。

### 其他位置相关补丁及本次范围

| Triumphus 修改 | 已确认位置与影响 | 本次处理 |
| --- | --- | --- |
| 掉出世界下界 | Engine 安装函数 `0x21580` 在 CA Engine `0x15F635` 跳转到 Triumphus `0x20B90`，将下界判断读取的字段写为 `-25000` 后恢复比较。 | 涉及地图/区域规则，保留生产行为。 |
| MoveActor / SingleLineCheck | 注册位于 Triumphus `0x23780`，替代入口为 `0x21470` / `0x235C0`，含物理状态、ServerController/类型、线程局部状态、碰撞掩码和短时缓存条件。 | 已识别专用条件含 AIController 分支的 ServerController，而 ClientController 继承 PlayerController；不能整体视为远端玩家必须迁移的补丁，全部辅助分支的实际命中未验。 |
| 复活定位 | CA Sephiroth `0x9F15B`、`0x9F18A`、`0x9F198`、`0x9F1D7` 属于 CBSNotiResurrectAt，涉及 FindSpot、高度处理及自有 FarMove 包装，取网络接口的本地控制器。 | 保留生产复活业务，不归入普通远端收包。 |
| 模块版本校验 | Triumphus 含对应 Core/Engine/Sephiroth 的时间戳及 SizeOfImage 校验。 | 不整体引入 Triumphus，不把 CA 偏移直接应用到生产版本。 |

### 尚未完成的运行验证

CA 原始 SEP 的入口暂停快照已取得展开 Triumphus，但此时尚未加载 Sephiroth.dll；Engine.text 扣除重定位后没有修改。Core 的五字节 execLog 钩子来自本次观察器，不是 CA 业务补丁。该时点不能证明后续没有补丁，也不能证明上述业务安装流程已生效。

用户已确认本机没有完整可正常启动的 CA 客户端，登录后安装时机、真实收包与地图/碰撞表现暂无法核实。生产 SEP 隔离入口快照遇到 Windows 740 的启动提权要求，未取得快照，因此生产 SPC32/SPM 的后续运行时修改尚未动态排除。三处配方已确定，完整实机调用链尚未验证一致。

本节所述只读复核阶段没有改动源码、生产 DLL 或已有候选；随后经用户授权生成独立候选，生产原件仍未覆盖。复核原始本地证据：[补丁位置及摘要](../../.tmp/ui-movement-chain-20261116/patch-evidence.json)、[九组分支结果](../../.tmp/ui-movement-chain-20261116/patch-recipe-branch-probes.json)、[真实助手写入结果](../../.tmp/ui-movement-chain-20261116/runtime-helper-results.json)、[公开方法比较](../../.tmp/ui-movement-chain-20261116/chain-static.json)、[Triumphus 安装代码](../../.tmp/ui-movement-chain-20261116/triumphus/0x54cf6-function-0x54320.asm.txt)。这些过程文件不随 Git 保存；样本摘要、关键位置、结果及限制以本节长期记录为准。

## 2026-11-07 历史静态分析


> 历史证据说明：本文分析的是 2026-11-07 的 CA 与当时原 DLL 样本。此后对远端 Main 成品的分析发现其远端消息接收存在配套原生调整；本文中“native 仅在脚本对齐后作为备选”等定位仅属于旧方案，不再是现行实施要求。新方案及证据边界见[现行方案入口](REMOTE_PLAYER_MOVEMENT_PLAN.md)和[实施计划](REMOTE_PLAYER_MOVEMENT_IMPLEMENTATION_PLAN.md)。

日期：2026-11-07。适用项目：`easy-game-ui`。状态：实施前的只读静态分析记录。现行实施要求与候选状态见[优化方案](REMOTE_PLAYER_MOVEMENT_PLAN.md)；本记录的源码哈希、行号及测试范围属于实施前基线，不代表当前候选已完成 DLL 加载或真实游戏验收。

当时方案采用“以 CA 脚本为基线、保留现有 DLL”。2026-11-16 已确认 Triumphus 存在配套原生修改，因而“native 仅作为脚本验收后备选”的旧定位不再适用。以下调用位置与对象字段用于追溯磁盘代码，运行时差异及完整分支条件以上方复核为准；历史记录不构成新的代码或 C++ 修改授权。

## 样本与证据边界

本轮读取当前仓库 `.uc`、CA `.u` 包内嵌的可读源码，并分析两目录的 PE 导出和相关 x86 指令。DLL 的 RVA 相对各自模块 ImageBase，文件字节偏移用于包内源码定位，两者不可混用。两个 `Sephiroth.dll` 的 ImageBase 均为 `0x10000000`，实际加载地址可能重定位，调试时应使用模块基址加 RVA。

| 样本 | 字节数 | SHA-256 |
| --- | ---: | --- |
| [当前 Sephiroth.dll](../Bin/Sephiroth.dll) | 1900544 | `e20b332cee1cff232a85f0a6b2aa67ff752ff281694f66fd30b402ece3376209` |
| [CA Sephiroth.dll](../Bin-CA/Sephiroth.dll) | 1949976 | `7aefce4ea3d4a20780dda00db15507814ad0dfce6fa6be3d65772828cd461f29` |
| [当前 Engine.dll](../Bin/Engine.dll) | 4029440 | `d555c0a3be748f65a512c9319fde9228109d2e3fe5c0bc2699b557e6340fbb48` |
| [CA Engine.dll](../Bin-CA/Engine.dll) | 4045080 | `a84d06acc4dbc0719b8313847f618d45a66a1b9d493eb56c3e8a2cf8316eb215` |
| [CA Sephiroth.u](../Bin-CA/Sephiroth.u) | 1257504 | `ef78b69e1108a8140bbc04c10aece50fe0616b5b80097bb93e31c72f6ab4e9fd` |
| [CA Engine.u](../Bin-CA/Engine.u) | 2705813 | `4def236c7c2f2a2ad8268755beb5ebf42b38d94a68d8a7c5c642be9c9d084517` |
| [ClientController.uc](../Sephiroth/Classes/ClientController.uc) | 192640 | `7fbd71002a7e7e57d17d36f1c7d3f620af714ef0b3e607ad8139364d087b30e4` |
| [Character.uc](../Sephiroth/Classes/Character.uc) | 17942 | `403056ba0d912686e445548c8102fdcc8f80e1e35dbd66d9cd3ff31c6682a69e` |

用户确认两边 DLL 基本同源、引擎同版本。CA DLL 存在有效数字签名，当前文件未签名，整文件大小和哈希差异不证明逻辑不同。本轮关键调用路径也直接支持同源前提。`Bin` 是本地分析样本目录，不据此认定用户实际运行的客户端必然加载这一整组文件。

`Bin/Sephiroth.pdb` 的 GUID/Age 与当前 DLL 的 CodeView 信息不匹配，不能将其作为当前 DLL 精确字段、源行和函数边界的匹配符号。这里的 native 结论以导出、指令和交叉调用为依据。CA 包内源码可读不等于已核验所有执行字节码；相关关键行为仍需按方案运行对照。`Bin-CA` 当前是本地未跟踪目录，文档记录样本摘要，不将整套二进制加入版本库。

## 当前脚本

以下为上述哈希对应的基线行号，实施后应按函数名重新定位。

| 文件与位置 | 已确认行为 |
| --- | --- |
| `ClientController.uc:4168–4204`，`NetRecv_PlayerMove` | 硬控和冲刺判断之后，跳跃立即写 Acc/JumpZ 并 `DoJump` |
| `ClientController.uc:4229–4294` | XY 距离大于 3000 直接设置 XY；其余分段追赶写 `GroundSpeed`；每次收包重置防卡时间 |
| `ClientController.uc:4252–4264` | 500 附近倍率从约 1.5 跳到 3 以上，数学上不连续；`GroundSpeed` 变化不等于实际 Velocity 必然瞬时按同倍数变化 |
| `ClientController.uc:1181–1255` | 远端分支恢复地速并观察防卡；触发时 Z 实际为当前值加 100；未排除下落 |
| `ClientController.uc:1297–1308`、`:4303–4329` | 既有状态通过 `MoveTo(Destination, ...)` 导航，不能忽略它对运动的影响 |
| `ClientController.uc:3492–3495` | `HandleWalking` 依据 PSI.RunState 设置走跑；当前接收跳跃在此调用之前 |
| `ClientController.uc:708–712` | 普通 `Landfloor` 将目标设为自身；攻击状态有不同覆盖实现 |
| `ClientController.uc:477–497`、`:4189–4196` | 硬控先同步 XY、清整个速度后返回；冲刺可在跳跃前返回 |
| `ClientController.uc:6412–6456` | 击退继承导航，仍可调用父移动；不能假定天然隔离普通同步 |
| `ClientController.uc:3165`、`:3355`、`:4015` | 销毁、Possess、死亡是清理边界；死亡仅忽略输入不等于网络事件被拒绝 |
| `Character.uc:529–534` | 父类 DoJump 失败也调用空中动画 |
| `Character.uc:556–564` | 落地转发给控制器 Landfloor |
| `Hero.uc:883–889`、`:983–985` | 跳跃许可与本地广播；默认 GroundSpeed=580、JumpZ=600、WalkingPct=0.431035 |

脚本声明及生成包装见 [SepNetInterface.uc](../Sephiroth/Classes/SepNetInterface.uc) 的 native `NotiJump` 和 [SephirothClasses.h](../Sephiroth/Inc/SephirothClasses.h) 的 `eventNetRecv_PlayerMove`。生成头是本地生成产物，不能代替已编译 DLL 布局证据。

## CA 包内脚本与引擎契约

下表为十进制文件字节偏移，片段所在包可按前述哈希核对。可通过字节搜索函数声明复查，无须运行客户端或将包转为可部署文件。

| 文件 | 偏移 | 内容与结论 |
| --- | ---: | --- |
| `Sephiroth.u` | 893889 | `class ClientController extends PlayerController` 可读源码起点 |
| `Sephiroth.u` | 913419 | 远端 `Approaching.PlayerMove` 调 `AdjustDestinationMotion` |
| `Sephiroth.u` | 958908 | `PlayerTick` 累加 `NetRecv_DeltaTime`，远端直接走自有 PlayerMove |
| `Sephiroth.u` | 971632 | `AdjustDestinationMotion` 函数名起点；先准备 Velocity，再按标记跳跃 |
| `Sephiroth.u` | 973123 | `NetRecv_PlayerMove`，普通目标标 1、跳跃标 2，接收时 DoJump 被注释 |
| `Sephiroth.u` | 1067615 | `Character.DoJump`，父方法成功才播空中动作，走路时再乘 WalkingPct |
| `Engine.u` | 1593694 | `GroundSpeed` 注释为 maximum ground speed |
| `Engine.u` | 1593812 | `AirSpeed` 注释为 maximum flying speed；不是普通跳跃水平速度的直接证据 |
| `Engine.u` | 1594089 | `WalkingPct` 注释为走路速度占跑速比例，使用有效速度时避免重复换算 |
| `Engine.u` | 1652501 | `Pawn.DoJump`：非蹲且 Walking/Ladder/Spider 才成功；普通地面分支保留 XY、写 Z、转 Falling |
| `Engine.u` | 1482845 | `PlayerWalking.ProcessMove` 设置 Acceleration，按输入尝试 DoJump |
| `Engine.u` | 1463417 | 引擎 PlayerTick 的常规输入与 PlayerMove 路径 |
| `Engine.u` | 2155333 | `MoveTo` 是 `native(500) final latent` 声明，具体导航与物理仍在 native |
| `Engine.u` | 2307019 | `EPhysics` 枚举依次为 None、Walking、Falling，因此 1=Walking、2=Falling |

CA 核心公式为：

```text
d = 目标 XY 距离
t = 上次成功调整后累计的本地帧时间
v0 = 原 Velocity 的 XY 长度
v = max(v0, min(d / t, Pawn.GroundSpeed))
Pawn.Velocity = v * Normal(Destination - Pawn.Location)
标记为 2 时 Pawn.DoJump(true)
```

这段代码的限制：先限速再取旧速度最大值，不是最终严格封顶；距离是二维、方向却为三维，会写 Z；累计时间不是严格的服务端包间隔；单份标记可能被后续普通消息覆盖。速度准备时目标可能已被 native 原点校正到零距离，需要运行核对并在新方案中显式处理。

CA `Pawn.DoJump` 普通地面分支中，走路使用 `Default.JumpZ`，奔跑使用当前 `JumpZ`；移动平台还会影响垂直速度。不能将收到的 JumpZ 当作所有跳高的唯一来源，CA 的 Character 缩放也不能机械迁移成本地角色新规则。

## 磁盘 DLL 中的远端运动应用

### 对应位置

| 函数或调用点 | 当前 Sephiroth.dll RVA | CA Sephiroth.dll RVA |
| --- | --- | --- |
| 消息到运动对象构造函数 | `0x74D90` | `0x71760` |
| 本轮定位的远端运动应用入口 | `0x65620` | `0x60650` |
| 跳跃分支调用 FarMoveActor | `0x656FA` | `0x6072A` |
| 跳跃分支调用脚本事件包装 | `0x65748` | `0x60778` |
| eventNetRecv_PlayerMove 导出包装 | `0x160F0` | `0xD400` |
| 普通分支写地速附近 | `0x6579B` | `0x607CB` |
| 普通中间误差分支调用事件 | `0x65932` | `0x60962` |
| 普通事件返回后调用 setPhysics | `0x6596C` | `0x6099C` |
| SetMoveSpeed 导出 | `0x497D0` | `0x44270` |

`SetMoveSpeed` 对应函数本轮比较的完整 `0x4B` 字节机器码相同，机器码 SHA-256 均为 `6614db725eb4fb26dd34c1903f544dbccd02c16a55c32038e52d9c9fa85ce61e`，相关对象写入偏移也一致。此结论仅覆盖该函数，不能扩展为整个 DLL 字节或全部逻辑完全一致。

native 跳跃应用可以归纳为：

```text
消息跳跃标志非零
    → Level 的 FarMoveActor(Pawn, 消息 Loc, 0, 0, 0)
    → eventNetRecv_PlayerMove(同一 Loc, Rot, Acc, true, JumpZ)
    → 更新 PSI 保存的上次网络位置
```

当前 `Engine.dll` 的 ULevel 虚表导出 RVA `0x282724`，虚表 `+0xBC` 指向导出的 `FarMoveActor`，目标 RVA `0x105820`。据此交叉确认跳跃分支中的虚调用身份，不仅凭调用地址外观命名。调用说明“尝试位置调整”，不等于每次必然成功或一定发生可见位移。

CA 对应 ULevel 虚表 RVA `0x282714`、FarMoveActor RVA `0x1058B0`，同样完成交叉确认。两版本均传入消息完整 XYZ，而非仅脚本中那些保持 Z 的 XY 修正。

### 消息对象内部布局

此处是 native 已解析运动对象内存偏移，**不是 TCP 包字段偏移**。类型由下游事件参数使用方式确认：

| 对象偏移 | 下游用途 |
| --- | --- |
| `+0x00 / +0x04 / +0x08` | Loc 的三个分量，FarMoveActor 和脚本事件使用同一组数据 |
| `+0x0C / +0x10 / +0x14` | Rot 三个分量 |
| `+0x24` | 跳跃标志判定 |
| `+0x28 / +0x2C / +0x30` | Acc 三个分量 |
| `+0x34` | JumpZ |
| `+0x48` | 普通分支写入 Pawn 地速字段的值 |
| `+0x4C` | 普通包第二个浮点值，旧类型信息名为 GameSpeed；下游动画用途未验证 |

### 普通位置分支与两种距离

以下仅描述两版本磁盘代码，CA 展开后的 Triumphus 会按上方配方修改其中分支：

1. 对象地速在 `400..1000` 范围内时使用，范围外回退 `580`，写到 Pawn `+0x450`。
2. 根据 PSI 中上次网络坐标与本次消息坐标的位移选择分支；**不是按 Pawn 实际渲染位置与消息目标的误差选择**。
3. 历史 X 为零先走哨兵路径；水平位移为零也有独立过滤。通过这些判断后，3D 位移大于 2000 走 FarMove 恢复，不超过 30 走小位移 FarMove/None，中间范围回调普通 event。旧文将 30 概括为 XY 阈值不准确，本项据 2026-11-16 分支复核更正。
4. 常规普通 event 返回后调用 `Pawn.setPhysics(1, None, (0,0,1))`。跳跃分支自身返回后没有这一步，后续进入该普通分支的消息才会触发。

历史坐标经控制器 `+0xAC0` 指向 PSI，PSI `+0x424` 为上次坐标；入口将本次坐标写入 `+0x430`，分支末尾再提交到 `+0x424`。首次状态含 X 为零的哨兵处理，需要在实施时核对所有初始化调用方。

native 的 30/2000 是**相邻网络坐标位移**，当前脚本 500/3000 才是**Pawn 到目标的实际位置误差**。这两组阈值不能混为一套纠偏条件。脚本观察到的普通 event 也不等于全部网络位置包。

### 普通消息切回 Walking 的识别

当前 RVA `0x65937–0x6596C`、CA `0x60967–0x6099C` 在普通事件返回后，通过 AHero 虚表 `+0x138` 调用 setPhysics；当前跳板 RVA `0xCE434`、CA `0xCADA4`，导入名为 `?setPhysics@AActor@@UAEXEPAV1@VFVector@@@Z`，Engine APawn 同槽交叉确认。再由 Engine.u 偏移 2307019 的 EPhysics 枚举确认参数 1 为 Walking。

这一行为可能打断远端 Falling，但是否正是用户场景中的可见问题，仍需记录到包时物理状态、调用前后变化及后续碰撞。不能写成“所有跳跃都会立即切回 Walking”。

### SetMoveSpeed 与速度更新来源

确定的偏移计算为：参数记为 a、b、c，写对象 `+0x940=a`、`+0x46C=b`，在 a 非零时 `+0x910/+0x914` 为先计算 a*c 再除 a，`+0x450/+0x944=a*c`。不要将这一指令计算泛化成所有异常输入下数学上等价的赋 c。

结合生成头和不匹配旧 PDB 的类型信息，字段名可交叉推断为 BaseGroundSpeed、WalkingPct、AnimSpeed/CurrentAnimSpeed、GroundSpeed/CurrentGroundSpeed；其中字段名是交叉推断，偏移和计算是当前机器码证据。当前初始化 RVA `0x43888`、属性接收 `0xA01B9/0xA01EF` 会调用该函数，因此不能再说正常速度只在脚本 PostBeginPlay 初始化。

普通位置应用只写 `+0x450`，没有同步写 `+0x944`。当前脚本用 CurrentGroundSpeed 快照恢复，可能覆盖本次网络位置速度。完整队列线程、MoveTo 的临时地速变化和物理推进仍需运行核对；不因已定位这些写入就宣称全部帧顺序已经还原。

### 对根因的影响

已能确认当前脚本的倍速断点、脚本防卡抬高、native 起跳前位置调整及后续普通包可能切回 Walking 同时存在；不能仅凭静态分析将某次游戏中的闪现归给其中一个。CA 也有相关 native 行为，合理待验证解释是前序运动偏差与脚本起跳衔接不同，使同样的原点校正和物理处理产生不同视觉结果。应量化校正前误差、校正实际位移以及 Falling 被改变的时序验证这一解释。

历史上据磁盘 native 路径同源而提出“先对齐脚本、不预先取消 FarMove 或扩大回调范围”的判断，已由 2026-11-16 的 Triumphus 证据修正；普通回调后的 Walking 仍保留。延后 DoJump 可能改变它与当批 native 处理的时序，但并未证明能够抵消所有后续 Walking；也尚未证明用户问题发生时普通包正在错误打断空中运动。存在位置校正不等于产生明显闪现，校正实际位移和结果才是进一步归因的依据。

如果只记录脚本入口位置，会遗漏 native 已经完成的校正。也不能通过脚本再次 SetLocation 到旧位置来抵消 native 调整：那会增加一次位置突变并破坏既有起跳原点语义。

## 服务端与客户端字段对照

服务端 [MapComponet](../../easy-game-linux/easy-game-scene/src/componets/map_componet.cpp) 的位置同步路径校验客户端上报位置后更新并广播，未在此路径模拟跳跃轨迹。[HF 接收模型](../../easy-game-linux/easy-game-scene/src/models/public_c2s_tcp_packet_hf.h) 的 `type=1` 尾部三个整数与一个浮点数读取后未保存；[HF 广播模型](../../easy-game-linux/easy-game-scene/src/models/public_s2c_tcp_packet_hf.cpp) 同类型固定写三个零和浮点数 600，QQ 对应实现相同。

客户端解码已经补全：当前构造函数 RVA `0x74F40–0x74FAA` 从其输入缓冲区 `+0x2C` 读取 type；非零时 `+0x2D/+0x31/+0x35` 的三个 32 位浮点位模式直接写入运动对象 Acc，`+0x39` 写 JumpZ。type=0 的 `0x74FB7–0x74FDC` 将 `+0x2D` 写对象 GroundSpeed、`+0x31` 写 GameSpeed。以上是该函数输入缓冲区坐标，不可不核对包前缀就当作 TCP 帧绝对偏移。当前 RVA `0x75813` 调构造、`0x7581A` 调运动应用，串起解码与应用。

因此，服务端 type=1 的三个零和 600 **确实对应下游 Acc=(0,0,0)、JumpZ=600**。跑跳水平运动不能依赖该 Acc 重新建立；应保留已有有效 XY 或新鲜前序普通运动信息。本次脚本方案不修改该协议或服务端；若后续要转发上报 Acc，必须先讨论可信性、字段校验和业务语义，再补充共享方案与 C++ 修改授权，不能顺带实施。

## 复核方法与验证范围

包内源码可用 Python 的 `Path.read_bytes().find(b"event NetRecv_PlayerMove")` 等方式定位，注意同包有多个重名事件，应确认所在类；韩文注释需要旧编码，英文代码与字节偏移不受解码展示影响。

PE 导出可使用本机 Visual Studio 的 `dumpbin /exports` 核对；反汇编时使用上述样本 SHA、RVA、导出包装和 ULevel 虚表交叉核对。不要使用未匹配 PDB 的源行名称替代指令证据，也不要将 RVA 直接当作文件偏移读取。

本机 dumpbin 路径为 `C:/Program Files/Microsoft Visual Studio/2022/Professional/VC/Tools/MSVC/14.41.34120/bin/Hostx64/x86/dumpbin.exe`。本轮以 PE 节表映射 RVA，用 Capstone 按 x86-32 解码相关指令；分析依赖仅放在系统临时目录，不作为项目依赖。PDB GUID 为 `07a066d2-03b5-4696-9bc5-828fe8eeb64b`、Age 1，DLL RSDS 为 `de2abcde-4d6e-4bf3-bd64-8491197be47c`、Age 5，可复核不匹配结论。

本轮未修改任何 C++ 或脚本、未附加运行客户端、未注入 hook、未构建部署，也未做性能或游戏画面验收。已完成的范围是源码阅读、二进制静态定位、同源路径比较及文档编写。后续运行观测与验收要求统一由[优化方案](REMOTE_PLAYER_MOVEMENT_PLAN.md)维护。
