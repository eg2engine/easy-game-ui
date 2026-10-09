# 黑金武器光效

## 1.0.0.5 发布验证（2026-10-09）

本次从暂存记录提取 2026-09-29 生命周期与模型名称读取加固，纳入 main 发布范围；跨服诊断等无关改动未提取。现行生命周期要求见下节，金龙对应要求见 [D47](GOLDEN_DRAGON_ORBIT.md#d47金龙增强生命周期保护2026-09-29)。

本次重新执行检查，426 项源码与行为模型断言通过（包括新增策略入库后的基线检查）；两份脚本包完整 UCC 编译为 0 错误、55 个警告。警告数量与历史基线一致，未出现修改文件的编译警告。验证日志保存在本地 `../.weapon-fx-work/builds/release-lifecycle-20261009/`，编译包保存在 `../.weapon-fx-work/current/release-lifecycle-20261009/`，这些目录不随 Git 发布。尚未进行客户端登录、变身、宠物切换和崩溃复现验收；未转换 spg 或部署。

## 生命周期保护（2026-09-29）

`FxLifecyclePolicy.GetHeroState` 先检查角色、控制器、PSI 和控制器所持角色，再以 `bTransformed` 或 `TransToMonsterName` 判断变身。神秘人、技能变身及变身卡期间，黑金 Link 暂停并清除当前效果、装备资格缓存和重试；角色和数据恢复正常后重新读取当前挂载与装备。初始化期间仅等待，不永久停止。挂件销毁时先停止 Link，再销毁其效果；粒子结构异常记录仍保留。

正常形态下的词条门槛、视觉默认参数和资源未改。本轮仅完成源码静态检查与 `Bin/UCC.exe make` 脚本编译；没有启动客户端或验证崩溃是否消失。编译日志和两份 `.u` 位于 `.weapon-fx-work/builds/lifecycle-20260929` 及 `.weapon-fx-work/current/lifecycle-20260929`，未转换 `.spg` 或部署。金龙对应生命周期说明见 [金龙生命周期保护](GOLDEN_DRAGON_ORBIT.md#d47金龙增强生命周期保护2026-09-29)。

后续名称读取加固：骨骼网格使用引擎现有 `Actor.GetMeshName()` 取得短名称；静态网格分别读取 `StaticMesh.Name`，保留两类网格的冲突校验和拳套实际男女变体优先规则。这样避开将整个模型对象转成包含 Outer 路径的字符串。该调用仍依赖原生模型指针有效，不能单凭静态检查认定访问违例已消失。验收日志与脚本包位于 `.weapon-fx-work/builds/getmeshname-20260929` 和 `.weapon-fx-work/current/getmeshname-20260929`。

## 正式版本

以V40视觉为基础，红法采用整杖头红金火焰包裹和常驻外围旋流，其余武器保持原视觉。采用V41显示条件：同一黑金武器至少5个不同名称的属性词条 `AffixValue >= 17` 才创建自定义光效。适用 MurcielSwordB、AcordGauntletB（男女模型）、AblazeStaffB、GlaciesStickB、ApliteBowB。
不使用装备基础Level代替词条等级，不累计其它装备。数据缺失时不显示；有效装备每0.25秒复核，未就绪/无法关联的挂件每0.75秒等待，卸下或不达标时销毁光效但保留仍存活挂件的Link以等待后续数据。
聊天框不输出光效调试日志。显式执行BGFXStatus只写引擎文件日志。

本轮收紧V42的装备对象关联：先确认挂件仍属于该Hero的实际手部挂载，再只在持有者自己的WornItems中匹配物品/模型对象；没有真实关联时，必须满足实际手部槽位和完整模型名匹配。唯一允许按模型跨槽的情况是AT_BothHand挂件匹配装备位8且物品含AP_BHand标记；不再跨所有武器槽搜索“唯一同模型”。真实对象关联也必须来自当前装备位8/9/16，且不能绕过手部挂载检查；脱离装备栏的Attachment.Info无效。歧义不显示，不按词条是否达标挑选候选物品。

左右拳挂件还必须是Gauntlet，且关联物品为IDT_Glove；无真实物品/模型关联时暂不显示，不把AT_LeftFist/AT_RightFist的数字当成装备位。模型名忽略包名前缀与大小写，拳套男女模型归一；特效类型用精确白名单而不是子串。非空实际Mesh/StaticMesh须与候选物品模型一致；物品模型为空时仅真实关联路径可使用实际模型。拳套性别先取实际模型HM/HF，未指明时取PSI.bIsMale，不猜测Actor名称。不改变AffixValue含义，也不解析提示框文字代替真实数值。

## 登录崩溃链路加固与诊断

这次是本地源码加固，不是已经证实根因的客户端崩溃修复。截图中的`UObject::IsValid / GetFullName / ProcessEvent / BlackGoldWeaponFxLink.Tick`不能单独确定最初出错的对象或操作；None和bDeleteMe检查也不能验证任意损坏的原生指针。没有故障客户端的对应包、DLL及复现日志，不能用编译通过代替登录验收。

- 保留Attachment的创建入口及所有native类/结构字段。新运行状态仅追加在三个脚本辅助/粒子类的字段末尾，不改变原字段类型、顺序或数量。
- Link负责装备资格、隐藏和重试；基础类负责逐帧粒子变换同步。Link仅在创建时立即同步一次，不再每帧重复调用。资格变化、卸装和销毁会清理子效果并取消重试。
- Visual或粒子Spawn失败、运行中意外丢失时采用0.5/1/2秒退避，此后最多每2秒重试；实际调用时间还受0.25秒核验节奏影响。成功重置计数，不在同一Tick内重复尝试首次粒子Spawn。
- 蓝法每次自定义Tick前验证Emitters长度至少25、槽2/3/5/10/11/15/16/17/18/23/24非空及槽23的ColorScale[0]存在。失败立即隐藏、停止自定义更新，并通过基础类同步将DetailClass锁存在Link；记录过程不销毁调用栈中的对象，后续由正常清理链处理。
- 已知结构异常在该Link整个生命周期内按DetailClass禁止重建，即使先卸装、降门槛或换物品也不丢记录；其他DetailClass仍能尝试。蓝法原有25层默认配置、六个禁用零容量层及其他武器的视觉参数不变。

诊断默认关闭。需要复现阶段日志时，在故障客户端关闭后按其配置目录约定编辑`WeaponFxDiagnostics.ini`，重启客户端加载：

```ini
[Sephiroth.BlackGoldWeaponFxLink]
bDebugTrace=True
```

诊断结束改回False。此选项只控制文件日志，不改变显示门槛或视觉，也不向聊天框输出。固定阶段包括ResolveBefore/ResolveAfter、Gate、VisualSpawnBefore/After、DetailSpawnBefore/After、ParticleFirstTick；只记录阶段、原因码和基本数值，不输出UObject全文。相同阶段/数值不重复刷日志，状态仅变化时记录，结构错误每个Link每类只记录一次。最后一个阶段标记只能缩小范围，不能自动认定为根因。

显式执行`BGFXStatus`无需开启自动诊断，只报告本地人物现有Link缓存的标量状态：WaitingMount、WaitingData、WaitingItem、BelowGate、UnsupportedModel、Pending、Ready、Retry、StructureInvalid，以及挂载标记、资格、Visual是否存在、重试步数/剩余时间和被锁类型数量。mount=32是内部拳套标记，不是Hero或装备槽；该状态报告不是重新遍历对象所得的瞬时诊断。

## 红法：红金火焰包裹整个杖头

正式视觉目标为光效覆盖、环绕整片黑色弯刃，常驻状态足够绚丽，汇聚时进一步增强。废止“只照亮中空处、火焰收紧到内缘”的旧目标。常驻可见宽度目标为金属杖头的1.2～1.35倍，零散火舌短暂约1.5倍；这些是客户端验收比例，不等同于源码尺寸。

红法的Designed_AblazeStaffB_Attached使用DT_None，仅显示父类创建的38层红金粒子。此前试用原版Lv17贴皮模型，客户端画面未见明显的材质覆盖提升，现已取消该模型的绘制；不修改原武器材质或共用的`IE_11_LMShader2`。本轮以贴近弯刃正反面的柔光粒子模拟表面发光，并不替代真实材质。

原有中心与运动参数保持不变。已校准位置：HeadGlowCenter=(4,2,73)控制中央核心、亮心及头部余光；HeadWrapCenter=(5,2,78)控制六区火焰、底光、外围旋流、电弧、火星及新增沿刃柔光。TailGlowCenter=(3,2,-99)控制尾部核心22和亮心24；TailWrapCenter=(3,2,-103)控制外晕21及边缘柔光26、27、36、37；TailTrailCenter=(3,2,-96.5)独立保留运动尾迹位置。均为武器局部坐标。

|槽位|包裹区域|相对HeadWrapCenter坐标|基础火片尺寸|
|---|---|---|---|
|8|根部|(0,0,-22)|15.4～19.8|
|9|左下|(-12,-2,-10)|16.5～22|
|13|左上|(-13,2,8)|17.6～24.2|
|14|顶部|(0,0,20)|15.4～22|
|15|右上|(16,-2,10)|17.6～24.2|
|16|右下|(14,2,-8)|16.5～22|

- 六层出生范围X/Z±2、Y±1.5，每秒16颗、寿命0.7秒、上限12；初速度按相对区域坐标归一化后向外3单位/秒。保留原有火焰贴图，根部/下方红橙、上方金橙，峰值Alpha115。默认尺寸与SyncWrapFlow运行时尺寸同步，增强阶段仍在表中基础尺寸上乘以1+0.12×Surge。
- 槽20底光位于包裹中心，尺寸32～38；本轮将原Alpha28折算为峰值RGB(28,17,5)，以有效的RGB能量降低大范围泛光。中央核心7及亮心17保留此前尺寸20～25.6及4.2～6、颜色及呼吸。
- 槽10/11常驻，路径相对包裹中心为(18cosθ,6sin2θ,24sinθ)。WrapPhase按约2.8秒一圈连续累计，仅在整圈取模，与4.6秒增强循环独立。
- 金流10尺寸6～9、每秒36颗、寿命0.4～0.5秒、上限18；橙火11尺寸9～13、每秒14颗、寿命0.45～0.55秒、上限8。使用相对坐标，已生粒子保留局部轨迹并淡出。
- 电弧12常驻，跟随外围旋流出生，基础每秒4颗、增强峰值10颗，寿命0.35秒、上限5；原出生扰动范围和尺寸保持。
- 追加25为外围金色火星，每秒8颗、寿命0.6秒、上限8、尺寸1.5～2.5；随旋流出生，以3单位/秒沿局部径向向外扩散，使用现有particle05贴图。
- 杖身及4.6秒循环保持。2.025秒进入1.1秒增强阶段，Surge采用正弦平方，旋流半径100%→75%→100%，六层火焰尺寸最多增加12%，金流颜色倍率最多增加20%，电弧发射率平滑提升。随后0.6秒柔和补光；所有包裹层始终开启。
- 槽20、26～37使用引擎支持的PTDS_Translucent与单一RGB ColorScale曲线：0～20%由黑色渐亮、20～70%保持峰值、70～100%回到黑色；四节点Alpha固定255，FadeIn/FadeOut均关闭。加色柔光的强度由RGB控制，不能再把配置的Alpha28/35/50视作实际运行亮度。
- 头部28～35四组成对沿刃柔光，以HeadWrapCenter为基准，HeadSurfaceDepth=4：根部(0,±4,-18)、左上(-10,±4,6)、右上(12,±4,8)、右下(11,±4,-6)。各层使用现有particle05，峰值RGB(35,21,6)，尺寸8～11、寿命0.6秒、每秒5颗、上限3颗，零出生扰动/速度/加速度。本轮覆盖试调仅启用正Y侧的28、30、32、34：设置Disabled=False、ZTest=False、ZWrite=False，保留原延迟0、0.15、0.3、0.45秒；停用背侧29、31、33、35，保留它们的参数和索引，避免正反面重复叠亮。四个启用层的配置粒子上限合计12颗。
- 头部柔光的RGB倍率为 `0.96 + 0.08×Pulse + 0.10×Surge + 0.04×Bloom`。运行时修改ColorMultiplierRange仅影响新出生粒子，存活粒子仍沿各自的RGB曲线渐隐；不因4.6秒循环启停或清空粒子。
- 尾部核心22、亮心24位于TailGlowCenter；红橙外晕21位于TailWrapCenter，RGB(255,90,35)、配置峰值Alpha42、尺寸16～20。固定边缘光26/36位于相对(3,±3,3)，27/37位于(-2,±3,-4)，由TailSurfaceDepth=3控制正反面深度，连接上部亮心与下方弯钩。四层均使用particle05，峰值RGB(50,30,9)，尺寸6～8、每秒5颗、寿命0.8秒、上限4，零出生扰动/速度/加速度，保留深度测试；按26、36、27、37顺序固定启动延迟0、0.1、0.2、0.3秒。尾部轻微呼吸覆盖21、22、24、26、27、36、37；运动尾迹23仍取TailTrailCenter并受挥动门槛控制。不恢复跳动小火苗。
- 原0～27索引保留，追加28～37，共38层；新增粒子上限32颗（头部24、尾部8）。无新增Actor、原生类字段、贴图模型资源或网络数据；词条门槛和其他武器保持原行为。

此前已修复13层柔光的RGB渐隐与低亮度，峰值分别为槽20的RGB(28,17,5)、头部28～35的RGB(35,21,6)、尾部26/27/36/37的RGB(50,30,9)。本轮只试调杖头四层柔光越过模型遮挡；光片进入绘制后可能透过角色或场景遮挡显示，Actor隐藏和引擎可见性剔除仍有效，不保证穿透所有场景物体。已校准中心、六区火焰、旋流路径、运动门槛、RGB亮度和配置粒子总上限不变。本地已通过UCC编译，未部署客户端。客户端先以相同近景和全身距离检查弯刃正面覆盖，再检查侧面和背面的投影位置、重新佩戴及三个循环的渐隐、挥杖经过身体和靠墙时的穿透，以及收武器后的清理和同场景帧率。若穿透或偏移不可接受，仅将28/30/32/34恢复ZTest=True，并将29/31/33/35恢复Disabled=False。

## 代码入口

- `Sephiroth/Classes/Attachment.uc`：创建脚本挂载辅助对象，不增加原生类字段。
- `BlackGoldWeaponFxLink.uc`：模型匹配、物品对象解析、五词条门槛及创建/销毁。
- `DesignedWeaponFxBase.uc`：维护粒子对象及武器世界坐标同步。
- `Designed_*_Attached.uc` → `Designed_*.uc` → `Designed_*_Particles.uc`：现行显示链。各武器Attached使用DT_None，保留原武器可见模型并显示自定义粒子。
- `Designed_ApliteBow_HJ*`为历史内部类名，实际弓模型匹配是ApliteBowB；不要仅因类名改变服务端模型配置。
- ItemFxTable不再配置本次自定义光效，防止绕过多词条门槛；普通武器原版效果保持。

未使用的坐标标记、*_17和*Particles17实验类已移出编译目录并归档。它们不是当前规则所需，达到17仍使用V40基础视觉。基础类中的`ItemFx.*_17_Mesh`是原版资源引用，与已归档的实验性*_17脚本不同；红法Attached当前不绘制该模型。

## 开发与编译

后续直接修改正式源码，不创建新的版本目录。过程文件统一放 `.weapon-fx-work/`（Git忽略）：

- `archive/deliveries/`：历史交付包。
- `archive/bin-backups/`：本次开发的旧编译备份。
- `archive/unused-classes/`：退出编译的实验类。
- `archive/notes/`：过期说明。
- `builds/`：编译前快照及日志。
- `current/`：最新本地交付副本。

UCC编译前须备份并移开Bin中的Sephiroth.u和SephirothUI.u，再从Bin运行 `UCC.exe make`。务必保留Sephiroth/Inc目录（.gitkeep已保留），生成的SephirothClasses.h不提交。检查最终编译结果；不能只看进程是否启动。

运行边界检查：`powershell -NoProfile -ExecutionPolicy Bypass -File tests/Verify-WeaponFxGate.ps1`。该检查验证源码守卫和边界逻辑模型，不替代引擎集成测试。

本轮基线与本地构建记录位于`.weapon-fx-work/builds/crash-hardening-20260918-223731/`。检查涵盖严格槽位、登录数据迟到、旧Info、同模型不同资格、拳套性别、重试及结构异常后立即卸装的锁存。源码检查同时对比基线native文件和视觉配置；这些是静态检查与PowerShell行为模型，不执行真实UnrealScript/native挂载逻辑。本地交付应附UCC最终日志、检查日志、源码/脚本包/DLL哈希及待验清单，不自动部署或转换spg。

2026-09-18本地验证结果：286项源码/模型断言通过，蓝法25个实际默认子对象绑定与ColorScale(0)检查通过；最终完整UCC编译为0错误、55个编译警告，警告与修复前基线一致，没有本次新增警告。实机登录崩溃仍未验证。

## 客户端交付

取Bin或 `.weapon-fx-work/current/` 中的两份 `.u`，用现有工具转换为同名 `.spg`，关闭客户端、备份旧文件后替换 `D:\tenang\new_kx\内服\EGClient\Bin` 对应文件。不能直接改后缀。除另有说明外，不更换模型、贴图、DLL或服务端脚本。

必测：4条17不显示、5条17显示、其中一条降为16后消失；普通武器不获得这些自定义效果；重登/重新佩戴/战斗切换；另一客户端观察。远端WornItems可能仅含外观，如果缺词条数据，需要另查服务端同步，本代码不会借用本地人物的数据。

本轮实机均待验证：蓝法达标/不达标分别登录、连续重登、快速换装和卸装、左右同模型但资格不同、切图、死亡复活、隐藏后恢复、他人角色显示，以及剑/红法/弓/男女拳套回归。重点确认数据迟到后能恢复显示，缺少关联的拳套不借用词条。故障客户端尚未提供，因此这些项目不得标为通过；也不得声称登录崩溃已解决。

## 提交

提交正式源码、本文档、测试脚本、AGENTS.md和.gitignore。不要提交 `.weapon-fx-work/` 或Bin构建目录。Git忽略规则不影响手动上传，手动上传时也应排除这两个目录。
本次整理未永久删除历史产物，可从archive恢复；恢复实验类需重新检查引用并完整重编译。

金龙表面光纹的最新修正在 `docs/GOLDEN_DRAGON_ORBIT.md` 的 D24 条目：改用两个同步骨骼姿态的透明网格层，保留原龙贴图；普通武器本身的材质和门槛未改。本地交付 `.weapon-fx-work/current/dragon-surface-d24/`，需客户端验证。

金龙 D25 针对 D24 黑色覆盖撤回 Shader/ConstantColor 回退链，改为 ColorModifier + FB_Translucent，并检测渲染回退后撤下表面网格。详见 `docs/GOLDEN_DRAGON_ORBIT.md` D25；交付 `.weapon-fx-work/current/dragon-surface-d25/`，尚待客户端验证。

金龙 D26 沿用 D25 表面材质，尾火按末端骨骼方向收束，头部金光/电纹增强，四爪局部动作触发爪下爆火，并移除所有金龙聊天/控制台诊断。详见 `docs/GOLDEN_DRAGON_ORBIT.md` D26；两份脚本交付 `.weapon-fx-work/current/dragon-fx-d26/`，不更换模型或配置。

金龙 D27 按用户澄清恢复 D25 尾部爆火强度、保留尾骨顺向，龙头追加6段黄色电弧和额头/两颊3处局部黄光。四爪爆火、动作、表面材质和关闭打印保持 D26。详见 `docs/GOLDEN_DRAGON_ORBIT.md` D27；交付 `.weapon-fx-work/current/dragon-fx-d27/`。

金龙 D28：红金流光叠加量2倍、头部电弧6→12、爪下外焰尺寸1.5倍；尾芯顺向，新增龙须细电、嘴前金色龙珠/微电弧及双侧后下方流火。详见 `docs/GOLDEN_DRAGON_ORBIT.md` D28；交付 `.weapon-fx-work/current/dragon-fx-d28/`，不换模型/配置，诊断仍关闭。

金龙 D29 将龙珠改为内嵌脚本包的实体黄色球形网格，移至上下颌之间；12段短电弧贴球面，关联嘴侧流火同步移位。详见 `docs/GOLDEN_DRAGON_ORBIT.md` D29；交付 `.weapon-fx-work/current/dragon-fx-d29/`，仍只更新两份脚本包。

金龙 D30 修正嘴内龙珠偏到上吻部的问题：改用上下颌局部内侧锚点，珠体、电弧和两侧火焰共同移位。详见 `docs/GOLDEN_DRAGON_ORBIT.md` D30；交付 `.weapon-fx-work/current/dragon-fx-d30/`，附离线红旧/绿新校准图。

金龙 D31 新增 OrbitCrawlV9 环绕脊椎左右摆动，肩胯错相、尾段延迟跟随，保留D30光效/爪步/尺寸/环绕路线。详见 `docs/GOLDEN_DRAGON_ORBIT.md` D31；交付 `.weapon-fx-work/current/dragon-motion-d31/`，本次须同时更新 PetPkg.ukx 和两份脚本包，ini不变。


金龙 D32：OrbitCrawlV10恢复原Run完整躯干旋转/起伏，增强步伐同步肩胯摆动和尾部跟随；环绕路径、大小与现有光效不变。详见 docs/GOLDEN_DRAGON_ORBIT.md D32；交付 .weapon-fx-work/current/dragon-motion-d32，须同时更新PetPkg.ukx与两份转换后的脚本包，ini不变。


金龙 D33：OrbitCrawlV11新增胸腹至腰胯的延迟俯仰波及轴向扭转，补足侧面/仰视躯干变化；固定根骨、保留爪步与路线/光效。详见 docs/GOLDEN_DRAGON_ORBIT.md D33；交付 .weapon-fx-work/current/dragon-motion-d33，须同时更新PetPkg.ukx与两份转换后的脚本包，ini不变。


金龙 D34：OrbitCrawlV12增强龙头横摆/抬压，头部波形提前约0.255秒、颈部分段承接到D33肩胯爪步；光效/路线/大小不变。详见 docs/GOLDEN_DRAGON_ORBIT.md D34；交付 .weapon-fx-work/current/dragon-motion-d34，PetPkg.ukx与两份转换后的脚本包须同时更新，ini不变。


金龙 D35：OrbitCrawlV13对头颈/身躯/四爪做周期旋转平滑，保留主节奏和幅度；120帧60fps仍2秒，路线/速度/光效不变。详见 docs/GOLDEN_DRAGON_ORBIT.md D35；交付 .weapon-fx-work/current/dragon-motion-d35，PetPkg.ukx及两份转换后脚本包须同时更新，ini不变。


金龙 D36：OrbitCrawlV14按主骨实际高度重做抬头→胸腹→腰胯→尾部的延迟起伏，增强抬头表现；环绕位置/速度/光效不变。详见 docs/GOLDEN_DRAGON_ORBIT.md D36；交付 .weapon-fx-work/current/dragon-motion-d36，动画包和两份转换后的脚本包须一起换，ini不变。


金龙 D37：OrbitCrawlV15实现一高一低回位、抬头峰值约增26%；动作倍率2/OrbitPeriod匹配稳定环绕周期，半径/转圈速度/光效不改。详见 docs/GOLDEN_DRAGON_ORBIT.md D37；交付 .weapon-fx-work/current/dragon-motion-d37，动画包与两份转换后脚本包须一起换，ini不变。


金龙 D38：OrbitCrawlV16让原固定肩背/颈根连接点参与波形，胸腹起伏增大，抬头峰值降低20%；一圈一轮、半径/速度/光效保持D37。详见 docs/GOLDEN_DRAGON_ORBIT.md D38；交付 .weapon-fx-work/current/dragon-motion-d38，动画包及两份转换后的脚本包一起换，ini不变。


金龙D39：参考044242外部动作合集，OrbitCrawlV17改用沿身体长度延迟的弧形路径，移除固定背弯并收敛抬头。100间距、速度、大小及光效沿用D38；详见docs/GOLDEN_DRAGON_ORBIT.md D39。交付 .weapon-fx-work/current/dragon-motion-d39，三文件一起更新，ini不变。


金龙D40：原地Pain不再退出环绕；新增RunFlowV1平滑跑动，保留原步频、四爪主要节奏，加入头颈至尾部连续起伏。D39环绕、间距/大小/速度/光效不变。详见docs/GOLDEN_DRAGON_ORBIT.md D40，交付 .weapon-fx-work/current/dragon-motion-d40，三文件一起更新，ini不变。


金龙D41：RunFlowV2四肢角幅分层增加，普通跑动1.35倍速；环绕/受击修复/光效不变。交付 .weapon-fx-work/current/dragon-motion-d41，三文件一起更新。眼睛仅建议方案，见docs/GOLDEN_DRAGON_EYES_PROPOSAL.md，未加入效果包。


金龙D42已实现双眼虹膜/竖瞳/小高光，达标附贴眼金光与眼尾细电弧，沿现有门槛。保留D41跑动。交付 .weapon-fx-work/current/dragon-eyes-d42，更新两份u转spg；PetPkg与D41一致。详见docs/GOLDEN_DRAGON_ORBIT.md D42及眼睛设计文档。


金龙D43：新增RunFlowV3，四爪对角交替爬行，增加肩胯/四爪侧摆，收小上下浮动；普通跟跑1.35→1.7倍速。D42眼部及所有装备光效、资格规则保持。交付.weapon-fx-work/current/dragon-motion-d43，三文件一起更新；详见GOLDEN_DRAGON_ORBIT.md。


金龙D44：参照QQ20260925-114123重制RunFlowV4，头颈到尾尖连续上下波浪，四爪配合各自身段收拢/后划，约1.60秒一轮。原站立环绕、眼部及装备光效、资格规则保持。交付.weapon-fx-work/current/dragon-motion-d44，三文件一起更新，详见GOLDEN_DRAGON_ORBIT.md。


金龙D45：RunFlowV5四肢参照OrbitCrawlV17收拢，保留轻微屈伸；D44身体游动和1.60秒节奏保持。光效/眼部/资格规则不变。交付.weapon-fx-work/current/dragon-motion-d45，三文件一起更新，INI不改。


金龙D46：Run/环绕改为持续双通道混合，短停跳过中间Idle，返回右侧提前展开并制动，原地短动画防抖与转向位置/朝向同步。D45动画资源及全部光效/资格规则不变。交付.weapon-fx-work/current/dragon-motion-d46；已有D45仅需更新两个脚本包，INI不改。原生混合实际显示待客户端验证。
