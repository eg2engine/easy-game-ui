# 换线列表名称配置

更新日期：2026-10-14。适用项目：`easy-game-ui`。状态：资源键方案已实施，UCC 构建及原生本地化接口行为检查通过，真实游戏显示与换线待验；繁体原生转换与字体绘制的验证边界见下文。本文是当前 UI 配置与实现入口，不作为服务端方案或客户端验收记录。

## 配置与迁移

`ServerSetInfo` 决定地址、数量及顺序；`ServerSetName` 改为与地址逐项对应的本地化资源键列表。在客户端实际使用的 `Bin/sep.ini` 中配置：

```ini
[SephirothUI.SephirothGame]
ServerGroup=
ServerIndex=
ServerSetInfo=127.0.0.1:3027|127.0.0.1:3028
ServerSetName=LocalLine|CrossBattle
```

两项分别查找 `LocalLine`、`CrossBattle` 的当前语言文字。地址调整顺序时同步调整键列表；翻译字典保持相同键，无须随菜单重排。键使用稳定的 ASCII 标识，`|` 仅作分隔符。

旧的 `ServerSetName=本服线路|跨服战场` 完整文字配置必须迁移为上面的资源键列表。本版不会猜测旧文字的编码，也不会把缺失键作为显示名直接输出。字段为空时保留旧名称生成规则，不强制启用新名字。

`ServerSetName` 配置字段与原生 `ConsoleCommand("ServerSetName")` 是不同职责：前者是资源键列表，后者继续取得旧名称所需的服务器组名。现有 `ServerGroup`、`ServerIndex` 及地址路由行为不因本版改变。

## 语言资源

UI 沿用现有调用 `Localize("ServerSetNames", Key, "SephirothUI")`。语言选择由客户端现有配置和本地化机制处理，查找当前 `SephirothUI.<语言>` 资源并使用引擎自身的 `.int` 回退。

中文资源中的对应内容为：

```ini
[ServerSetNames]
LocalLine=本服线路
CrossBattle=跨服战场
```

| 语言文件 | LocalLine | CrossBattle |
| --- | --- | --- |
| `SephirothUI.chn` | 本服线路 | 跨服战场 |
| `SephirothUI.cht` | 本服線路 | 跨服戰場 |
| `SephirothUI.kor` | 본 서버 채널 | 서버 간 전장 |
| `SephirothUI.int` | Home Server Channel | Cross-Server Battlefield |

Git 可跟踪的翻译源位于 [SephirothUI/Localization](../SephirothUI/Localization/README.md)，四份文件仅包含本次 `[ServerSetNames]` 增量，采用 UTF-8 文本方便维护；它们不是可直接覆盖运行语言文件的完整资源。

通过 [merge_locales.py](../SephirothUI/Localization/merge_locales.py) 合并到项目本地 `Bin` 或独立构建目录。工具保留已有语言文件的其他节与键，并保留既有编码；当前 `.chn/.cht/.kor` 为 UTF-16LE BOM、CRLF，缺失的 `.int` 以同样格式创建。交付时同时提供新 UI 脚本包和合并后的完整四份语言文件，不用增量片段替换原完整资源。

## 回退规则

| 情况 | 行为 |
| --- | --- |
| 未配置或配置值为空 | 整份列表保留旧显示。 |
| 键数量与地址数量不同 | 记录数量不匹配日志，整份列表回退旧显示。 |
| 对应键为空 | 保留槽位，仅该项使用旧显示。 |
| 当前语言未提供该键，`.int` 提供了可用文字 | 使用引擎返回的基础语言文字。 |
| 本地化最终返回空串或对应缺失标记 | 记录缺失日志，该项回退旧显示。 |
| 地址列表为空 | 不打开空选择框，不发起直接换线。 |

旧显示继续使用服务器组名、原 `Localize("Terms", "Server", "Sephiroth")` 和菜单序号；“当前服务器”标记继续使用原本地化资源。

资源缺失通常返回空串；启动参数 `SHOWLANGERROR` 可使引擎返回 `<?语言?包名.节名.键名?>`，不同查找路径仍可能返回空串。UI 仅识别指向同一 `SephirothUI.ServerSetNames.<键>` 的错误标记并回退，不猜测语言或编码。实测当前语言存在空值时返回空串，不再使用 `.int` 中同键文字；当前语言缺键且开启 `SHOWLANGERROR` 时，原生接口可能优先给出缺失标记，本版同样回退旧显示。

解析资源键保留首部、连续和尾部空项。例如 `|CrossBattle` 的第一项回退，`LocalLine|` 的第二项回退，三条地址对应 `LocalLine||CrossBattle` 时中间项回退；后续键不会向前移动。

## 入口、索引与范围

`GotoLobby`、`GotoLobbyDirect` 继续共用 `ShowLobbyServerSelection`；列表由 `SephirothGame.GetServerSelectionInfo` 统一构造。确认选择后仍按选中下标取得地址，显示文字和资源键均不参与路由。

当前线路保留 `ServerSetID - 1` 的原对应规则。范围外返回 `-1`，无当前标记或默认选择，直接入口保留选择框但不自动请求，等待玩家手动选择；有效当前索引下保留原请求次序。此版不通过默认登录地址或名称猜测当前连接，不改变服务端线路号。

源码入口：

- [SephirothGame.uc](../SephirothUI/Classes/SephirothGame.uc)：资源键解析、本地化、缺失回退、列表与当前索引处理。
- [SephirothInterface.uc](../SephirothUI/Classes/SephirothInterface.uc)：两个共用入口与按地址发出原生请求。
- [CSkillInfoBox.uc](../SephirothUI/Classes/CSkillInfoBox.uc)、[CItemInfoBox.uc](../SephirothUI/Classes/CItemInfoBox.uc)：项目现有本地化字段及动态键使用方式。

本次仅修改 UI、语言资源与配套工具和说明，不修改 C++、启动器或服务端，不自动部署运行客户端，也不调整发布版本。

## 本次验证

2026-10-14 本次 UI-only UCC 构建为 **0 错误、47 个既有 UI 警告**，无新增警告；交付包来自正式源码，不包含临时测试命令入口。资源合并核对三份旧文件的原内容逐字节保留、四语言重复合并无变化、重复目标节/键拒绝，英文文件按约定新建。

隔离 UCC 命令实际执行生产 `ResolveServerSetName` 函数：项目 Core 与运行客户端 Core 的只读副本分别覆盖 `chn / cht / kor / int` 和缺失语言文件、正常与 `SHOWLANGERROR` 两种模式，共 20 轮、每轮 9 项接口行为检查通过。范围包括语言选择、资源键读取、空键、最终缺失、空翻译、`.int` 回退及缺失标记过滤；不执行网络换线、窗口布局或字体绘制。

简体、韩文和英文结果与对应资源的 Unicode 码元一致。繁体分支在当前 Windows 环境中，原 `Localize` 返回值与资源的直接 Unicode 码元不一致，两份 Core 均观察到同样差异；本版检查的是 UI 原样使用该接口结果，资源源文为繁体，**不将该检查表述为繁体文字显示验收通过**。相关首轮差异记录保留，UI 未加入任何繁体转码或字符猜测；真实字体与客户端显示仍须独立验证。

日志及本机结果位于 `../.weapon-fx-work/builds/server-set-localization-20261014/`，包括 `build-result.json`、`locale-merge-result.json`、`localization-execution-final-result.json`。使用的项目 Core SHA256 为 `F7FF84F832ECFE7E6CB44240F60DDF242F163ACDA1E9585E4406F3230EC7CADF`，运行 Core 只读副本为 `33907A003D897A088213C3BAB4AC247A48370801BA94CA2880658ED016800C2D`。

正式本地输出为 `Bin/SephirothUI.u`；交付目录为 `../.weapon-fx-work/current/server-set-localization-20261014/`，同时包含 UI 包、完整四语言文件与配置示例。运行客户端文件未修改，新 UI 包仍须按既有流程转换为 `.spg` 后部署，语言资源与键配置须一并迁移。

真实游戏仍需核对四种语言的菜单和当前标记、不同地址顺序、未配置、数量不符、空键、缺失资源、有效及越界当前索引、两个入口的实际换线目标。

## 替代关系与历史记录

2026-10-11 首轮将 `ServerSetName` 作为完整显示名列表，UCC 为 0 错误、47 个既有 UI 警告；用户随后报告真实客户端中文乱码。该字段契约由本版资源键契约替代，旧配置须迁移。首轮记录位于 `../.weapon-fx-work/builds/server-set-names-20261011/`。

同日尝试的 UTF-8 猜测解码版本已按用户要求撤回，解码函数及调用不在当前源码中。该版本曾通过特定编码输入的 UCC/脚本检查，但未验证现有多语言体系，不作为本版通过依据；撤回记录与历史包保留在 `../.weapon-fx-work/builds/server-set-name-encoding-20261011/`。
