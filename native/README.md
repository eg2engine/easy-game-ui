# 累计原生与动画补丁

`patches/*.json` 记录原版到 V135 的精确字节替换、追加内容和整文件哈希；不包含整份 DLL 或动画资源。`src/` 保存所编写的 C++ 热路径实现与清理日志后的射击汇编。它们是原生补丁代码，不是引擎完整 SDK 源码。

| 文件 | 主要改动 |
| --- | --- |
| `ALAudio.dll` | 创建流失败时释放 256KB 暂存缓冲，成功路径保持 |
| `Core.dll` | 限定私有类型的释放入口、事件维护的存活对象登记 |
| `D3D9Drv.dll` | 资源回收与前驱提示；保留原有析构、COM释放和链表回退 |
| `Engine.dll` | 骨骼／灯光／声明查询优化、碰撞筛选、远端运动相关入口、后台地图保护、弓手单次动画保护 |
| `Sephiroth.dll` | 原生远端运动接收、附件／特效生命周期、技能刷新时保留 Shot/ShotC 原循环标志 |
| `WinDrv.dll` | 启动窗口和修改分辨率后居中 |
| `Animations/PetPkg.spa` | 金龙动画累计资源差异 |

输入版本由每个配方的 `source_sha256` 和 `source_size` 限定，指令原字节也逐段验证。输出必须满足 `target_sha256` 和 `target_size`，不接受其他客户端版本。配方包含 PE 节、重定位和校验和的最终差异，因此不依赖旧工作区的分步产物或本机地址。

```powershell
# 先只验证，不写输出。
python tools/apply_client_patches.py --original-root <原版客户端根目录> `
  --output-root .weapon-fx-work/native-reproduced --verify-only

# 输出到独立目录，不部署客户端。
python tools/apply_client_patches.py --original-root <原版客户端根目录> `
  --output-root .weapon-fx-work/native-reproduced
```

配方中的文件偏移是磁盘位置；`src/` 中的地址为特定版本的模块 RVA，不能当作任意运行地址。压缩的追加段包含机器码、字符串、状态区和重定位等内容；保留这些内容是为了精确复现既有补丁。C++ 片段按 x86 MSVC 构建，汇编按原配方位置编码；单独重新编译片段不能替代整套配方。

当前复现已验证全部 7 个文件与 V135 成品一致。没有打包 `toolys.dll`、日志诊断段或完整第三方客户端；不修改服务端。
