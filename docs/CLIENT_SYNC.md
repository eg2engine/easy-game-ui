# V135 累计客户端源码同步

本次将本地 V135 的累计改动合入正式源码目录，仓库基线为 `8c662327c204d95435d11b75e17700b03329f20e`。不改仓库发布版本号，不部署客户端，不合并 PR。

## 同步范围

| 模块 | 内容 |
| --- | --- |
| `CmdMelee`、`BowAttackRuntime` | 近战／弓手命令攻击、鼠标优先、控制和距离限制、每轮技能快照、会话内固定技能定义、辅助技能完整动作锁 |
| `RemoteMotionSys`、`Sephiroth`、`SephirothUI` | 远端移动、跳跃、攻击显示优先级、路径受阻恢复、收招恢复和鼠标锁定 |
| `UIVisibility`、`FreeviewPrefs` | 小地图、聊天、快捷键栏、BUFF、宠物信息的持久设置；共享视角角度和距离、滑块值保存 |
| `ObjectStore`、`SceneRegistry`、特效包 | 动态对象、材质、Pattern、附属特效清理；有效对象登记与查询 |
| `Engine`、`Sephiroth` | 飞行显示、飞行消息入口、跟随队伍限制、聊天对象清理等累计修复 |
| `native/src`、`native/patches` | 音频失败分支释放、私有对象释放、骨骼／渲染查询缓存、D3D9资源回收、远端运动、窗口居中、弓手单次动作／模型重绑等原生补丁 |

弓手命令攻击保留最终规则：连续出箭每支之间等待 200ms，最后一支后等待 150ms；同时出箭在动作结束后发送命中批次，再等待 50ms。鼠标攻击继续使用原生箭矢，不套用命令攻击的免飞行命中路径。首次角色技能数据完整建立，后续动态等级、SP、速度更新；固定的动作和出箭定义保持到退出角色。

V135 删除的新增运行日志没有带回：不包含 `FlightVisualLog` 模块、自动日志配置、原生技能收包记录缓冲。原版日志入口和仓库原有的可选光效诊断保持原状。不新增定时扫描。

## 与仓库现有修复的合并

保留仓库现有黑金武器门槛、视觉默认属性、生命周期策略和金龙停止／宿主恢复保护。特别保留 `StopWork` 不递归销毁自身，以及 `SyncDetailTransform` 的生命周期检查；累计版本中的材质所有权释放与重复计算优化在这些保护之上合并。

历史成品曾直接移植字节码，附带的 `ScriptText` 并非始终同步。因此没有直接覆盖导出的 `.uc`：

- 还原 `ClientController.AddActionPool`、`PlayAction` 的源码；与成品字节码核对过它们的历史编译来源。
- 删除重复／残缺的收招片段，`NetRecv_ActMeleeFinish` 采用实际执行的队列优先级版本。
- 将弓手 `ActionEnd` 放回 `BowAttacking` 状态，移除游离在函数外的旧片段。
- 保留序列化的粒子默认子对象和 UI 默认属性；补全导出遗漏的默认属性。
- 补齐跟随入口已引用、但最近导出包中缺少的 `RemoteMotionSys.FollowPolicy` 源码。单独重建该纯脚本包验证通过。
- 对齐 `EffectProjector.PostBeginPlay` 中实际字节码已经移除的计数调用，避免从旧文本重新带回。

这些是源码还原／合并修正。本次没有把新编译文件替换到运行客户端。

## 检查命令

在仓库根目录运行：

```powershell
python tests/Verify-ClientSync.py
powershell -NoProfile -ExecutionPolicy Bypass -File tests/Verify-WeaponFxGate.ps1
python -m unittest discover -s tests -p test_client_patches.py
python -m unittest discover -s tests -p test_compile_warnings.py
git diff --check
```

原生及动画补丁复现见 [native/README.md](../native/README.md)。输出目录必须与原版客户端分开，工具先验证整组输入与结果哈希，再写输出；不覆盖不同的既有文件。

脚本类型检查需要匹配的旧版 `UCC.exe`、DLL、解密后的 `.u` 依赖和本地游戏资源。它们不上传到 Git。配置文件用这套 UCC 已能正常工作的 ini：

```powershell
python tools/validate_client_sources.py `
  --runtime-bin <V135及UCC依赖的Bin目录> `
  --original-bin <原版解密后u文件目录> `
  --config <UCC配置文件> `
  --asset-root <包含Textures等目录的客户端根目录>
```

输出在 `.weapon-fx-work/source-validation/`。工具在副本中更新供编译器解析的文本，去掉已有粒子默认引用，避免旧编辑器重导入时发生子对象重名；校验用派生类中的 final 方法会临时改名。**这些包仅做语法、类型和状态体检查，不能部署。** 视觉默认属性由独立的光效检查保护。这不是从完整原生 SDK 重新编译游戏，也不保证校验包与成品字节码逐字节相同。

正式后续构建仍须按原有字节码移植／包构建流程保留原生类布局、状态引用、资源偏移，不能只在根目录直接执行 `UCC make` 后部署全部生成文件。

## 本次验证结果

- 98 个源码文件、2141 个方法的重复定义、括号、原生前缀和输出入口静态检查通过。
- 武器／金龙 413 项源码和边界模型断言通过；视觉默认属性保持。
- 远端运动辅助包完整编译：0 错误、0 警告。
- 隔离校验包检查 480 个方法／状态体：0 错误、164 条已审核提示（96 条数字结尾类名、68 条未使用局部变量）。原先 166 条中的返回值缺失、局部变量遮蔽已修复；逐条记录见 [COMPILER_WARNINGS.md](COMPILER_WARNINGS.md)。完整日志留在忽略目录。
- 6 项补丁输入／哈希／重叠／边界测试及 6 项警告检查器测试通过。
- 6 个 DLL 和 `PetPkg.spa` 从原版输入复现，逐文件 SHA256 与 V135 成品一致。
- 对照原版列出 182 个已改变的既有函数，均有对应源码文件；没有用旧导出文本替代缺失的函数体。

尚未做本次仓库合并后的联网实机回归。审核后需测试：三连射使用攻速卷轴、鼠标连续切技能、弓手辅助技能期间切技能、命令出箭节奏、远端跑跳和攻击、超距收招、UI重启保持、换图／小退及武器／金龙生命周期。

`toolys.dll`、DLL/SPG成品、完整游戏资源、内存转储、旧日志和本地备份均不进入此次提交。源码与补丁通过 PR 审核，不直接合并。
