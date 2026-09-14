# 武器光效开发约定

- 后续设计直接修改正式项目源码；不要在根目录继续创建 `WeaponFx_vNN`、`BowModelTest_vNN` 等过程目录。
- 所有本地过程产物（旧版本、备份、试验源码、截图、编译日志、临时交付包）放在 `.weapon-fx-work/`，该目录已加入 Git 忽略。
- 正式规则和部署说明维护在 `docs/WEAPON_EFFECTS.md`，门槛检查脚本维护在 `tests/Verify-WeaponFxGate.ps1`。
- 正式编译输出仍为 `Bin/Sephiroth.u` 和 `Bin/SephirothUI.u`；本地交付副本放 `.weapon-fx-work/current/`。不要直接部署客户端或重启服务。
- 保留用户无关改动。归档/清理仅限确认属于本次光效工作的文件，优先可恢复归档。
- 目前规则：以V40为基础，红法采用用户确认的整杖头红金火焰包裹、常驻外围旋流和汇聚增强，废止仅照亮中空处的内缘方案；杖尾使用稳定亮心与红橙外晕、不恢复跳动火苗，其余武器保持原视觉；同一黑金武器至少5个不同词条 `AffixValue >= 17`；缺失数据不显示；不要自动切换实验性17版视觉。改变规则前需用户明确要求。
- 红法位置校准分别使用HeadGlowCenter/HeadWrapCenter、TailGlowCenter/TailWrapCenter；挥动尾迹固定使用TailTrailCenter，避免调亮心或外晕时移动运动尾迹。参数见 `docs/WEAPON_EFFECTS.md`。
- 红法上一轮增强六区包裹火焰、外围金橙光层和尾部外晕/边缘光；运行时SyncWrapFlow的六区基础尺寸必须与defaultproperties一致，中心、轨道、节奏和运动尾迹锚点沿用已校准值。
- 红法现有38层粒子：28～35以HeadWrapCenter和HeadSurfaceDepth=4组成四组正反面沿刃柔光；26/27与36/37以TailWrapCenter和TailSurfaceDepth=3组成尾部正反面柔光。杖头覆盖试调只启用28/30/32/34并设置ZTest=False、ZWrite=False，背侧29/31/33/35设Disabled=True；其余柔光仍保留深度测试。正Y锚点、原延迟和RGB渐隐保持，头部跟随Pulse/Surge/Bloom，尾部仅跟随GlowPulse，不在循环边界重置。槽20及26～37沿用PTDS_Translucent和RGB渐隐、Alpha固定255；峰值RGB依次为(28,17,5)、头部(35,21,6)、尾部(50,30,9)。四层覆盖光可能显示在遮挡的角色或墙面上；若不能接受，按本轮差异恢复ZTest与背层启用状态。
- 红法Attached恢复DT_None，只显示现有红金粒子；原版Lv17贴皮模型试用后已取消绘制。其他武器Attached仍用DT_None，不修改共用的`IE_11_LMShader2`材质或已归档的实验性*_17脚本。
- 用户偏好简短交付，说明修改点、文件位置和替换步骤即可。
