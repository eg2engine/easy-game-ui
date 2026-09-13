# 武器光效开发约定

- 后续设计直接修改正式项目源码；不要在根目录继续创建 `WeaponFx_vNN`、`BowModelTest_vNN` 等过程目录。
- 所有本地过程产物（旧版本、备份、试验源码、截图、编译日志、临时交付包）放在 `.weapon-fx-work/`，该目录已加入 Git 忽略。
- 正式规则和部署说明维护在 `docs/WEAPON_EFFECTS.md`，门槛检查脚本维护在 `tests/Verify-WeaponFxGate.ps1`。
- 正式编译输出仍为 `Bin/Sephiroth.u` 和 `Bin/SephirothUI.u`；本地交付副本放 `.weapon-fx-work/current/`。不要直接部署客户端或重启服务。
- 保留用户无关改动。归档/清理仅限确认属于本次光效工作的文件，优先可恢复归档。
- 目前规则：V40基础视觉；同一黑金武器至少5个不同词条 `AffixValue >= 17`；缺失数据不显示；不要自动切换实验性17版视觉。改变规则前需用户明确要求。
- 用户偏好简短交付，说明修改点、文件位置和替换步骤即可。
