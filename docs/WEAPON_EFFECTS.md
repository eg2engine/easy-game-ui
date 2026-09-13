# 黑金武器光效

## 正式版本

保留V40基础视觉，采用V41显示条件：同一黑金武器至少5个不同名称的属性词条 `AffixValue >= 17` 才创建自定义光效。适用 MurcielSwordB、AcordGauntletB（男女模型）、AblazeStaffB、GlaciesStickB、ApliteBowB。
不使用装备基础Level代替词条等级，不累计其它装备。数据缺失时不显示；每0.25秒复核，卸下或不达标时销毁。
聊天框不输出光效调试日志。显式执行BGFXStatus只写引擎文件日志。

V42修正装备对象关联：优先在持有者自己的WornItems中匹配物品/模型对象，再按Hero手部挂载槽位及完整模型名匹配；双手武器槽位差异仅允许匹配唯一的同模型已装备武器。不再直接返回脱离装备栏的Attachment.Info。模型名忽略包名前缀与大小写，拳套男女模型归一；不按词条是否达标挑选候选物品。歧义、缺失数据、非武器槽位仍不显示。不改变AffixValue含义，也不解析提示框文字代替真实数值。

## 代码入口

- `Sephiroth/Classes/Attachment.uc`：创建脚本挂载辅助对象，不增加原生类字段。
- `BlackGoldWeaponFxLink.uc`：模型匹配、物品对象解析、五词条门槛及创建/销毁。
- `DesignedWeaponFxBase.uc`：维护粒子对象及武器世界坐标同步。
- `Designed_*_Attached.uc` → `Designed_*.uc` → `Designed_*_Particles.uc`：现行显示链。Attached使用DT_None，避免重复显示旧模型覆盖层。
- `Designed_ApliteBow_HJ*`为历史内部类名，实际弓模型匹配是ApliteBowB；不要仅因类名改变服务端模型配置。
- ItemFxTable不再配置本次自定义光效，防止绕过多词条门槛；普通武器原版效果保持。

未使用的坐标标记、*_17和*Particles17实验类已移出编译目录并归档。它们不是当前规则所需，达到17仍使用V40基础视觉。不要删除基础类中 `ItemFx.*_17_Mesh` 等原版资源引用，这与已归档的实验脚本不同。

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

## 客户端交付

取Bin或 `.weapon-fx-work/current/` 中的两份 `.u`，用现有工具转换为同名 `.spg`，关闭客户端、备份旧文件后替换 `D:\tenang\new_kx\内服\EGClient\Bin` 对应文件。不能直接改后缀。除另有说明外，不更换模型、贴图、DLL或服务端脚本。

必测：4条17不显示、5条17显示、其中一条降为16后消失；普通武器不获得这些自定义效果；重登/重新佩戴/战斗切换；另一客户端观察。远端WornItems可能仅含外观，如果缺词条数据，需要另查服务端同步，本代码不会借用本地人物的数据。

## 提交

提交正式源码、本文档、测试脚本、AGENTS.md和.gitignore。不要提交 `.weapon-fx-work/` 或Bin构建目录。Git忽略规则不影响手动上传，手动上传时也应排除这两个目录。
本次整理未永久删除历史产物，可从archive恢复；恢复实验类需重新检查引用并完整重编译。
