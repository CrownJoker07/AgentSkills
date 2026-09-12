# Unity / 游戏客户端 考点地图

## 0. 用途

用于岗位方向为 Unity 客户端、游戏引擎、图形或玩法程序的候选人，覆盖 **3.1 技术基础**、**3.2 技术进阶**、**3.4 场景 / 设计**。

- 引擎机制题必须以候选人**实际使用过的 Unity 版本与渲染管线**为前提。简历只有“了解 Unity”而无项目证据时，改用 §9 的迁移问法，不考引擎专属机制。
- Unity 岗仍必须考 C# 语言深度（见 `csharp-dotnet.md`）。本文件不与语言深度题重复。
- 具体参数名、生效条件、平台差异以本文件末尾的官方页面为准核对；候选人给出具体条件时，按“版本 + 平台 + 配置”追问。

---

## 1. Player Loop 与脚本生命周期

**已核实的官方口径** [S010]：

- 事件函数按固定顺序构成 MonoBehaviour 生命周期；完整 Player Loop 由更多系统按默认顺序组成，可用 `LowLevel.PlayerLoop` API 查看，并可移除系统、插入自定义系统来定制循环。
- **物理步进位置可配置**：`Physics.simulationMode` 为 `FixedUpdate` 时紧跟 `FixedUpdate` 之后；为 `Update` 时紧跟 `Update` 之后；为 `Script` 时由脚本用 `Physics.Simulate` 手动推进。步进包含碰撞检测各阶段、Rigidbody 与关节积分、把姿态写回 Transform，并触发 `OnTrigger*` / `OnCollision*` / `OnJointBreak*` / `OnParticleCollision` 回调。
- 动画有独立的内部更新序列，`OnAnimatorMove` / `OnAnimatorIK` 在 MonoBehaviour 上，状态机回调在 `StateMachineBehaviour` 上。
- 渲染回调（`OnPreCull`、`OnBecameVisible` / `OnBecameInvisible`、`OnWillRenderObject`、`OnPreRender`、`OnRenderObject`、`OnPostRender`、`OnRenderImage`、`OnGUI`）属于 Built-In 管线的顺序；SRP 管线（URP / HDRP）有各自的执行顺序文档。`OnPreCull` / `OnPreRender` / `OnPostRender` **只有脚本与 Camera 挂在同一物体上才会作为消息被调用**，否则要用 `Camera.onPreCull` 等委托。
- 协程按 `yield` 指令在不同阶段恢复（`WaitForEndOfFrame` 在帧末，`WaitForFixedUpdate` 在固定步末）；普通 .NET `Task` / `async` 的续排在 `Update` 阶段恢复；Unity `Awaitable` 可按等待方式在不同 PlayerLoop 时机恢复。**协程与异步任务的恢复顺序不保证**。
- 顺序限制：**不能依赖同一事件函数在不同 GameObject 之间的调用顺序**，也不能指定同一脚本不同实例间的调用顺序；跨脚本可用 Script Execution Order 配置 [S016]。
- 使用 ECS 时，Entities 的系统组会被并入 Player Loop 更新序列 [S028]。
- 官方已标注 Built-In Render Pipeline 处于弃用周期，Unity 6.7 LTS 期间仍获维护 [S010]。

**考点写法（L1 / L2）**：给出一个初始化状态错乱的现象，要求按顺序解释发生在哪个回调、为什么、如何修复（不要背顺序表）。

**考点写法（L3 / L4）**：

- 异步场景加载 / Additive 加载后对象就绪时机：跨场景引用为 null、初始化读到未准备好的配置，如何用显式的就绪信号（事件、`Awaitable`、加载完成回调）而不是靠生命周期顺序保证时序。
- 域重载（Domain Reload）被关闭时静态字段与单例会跨 Play 保留，如何造成状态污染与难以复现的 bug；哪些代码在这种配置下会出错。
- 需要每帧一次且顺序确定的系统（战斗结算、AI 决策、网络同步）如何设计执行顺序，而不是依赖脚本注册顺序。

**弱答案信号**：只背 `Awake → Start → Update`；把同一脚本不同实例的顺序当成可控；不知道物理回调与 `Update` 的相对位置。

---

## 2. 帧预算、瓶颈定位与工具

**答题骨架**（L3 / L4 必备）：先确定目标帧率与预算（如 60 FPS ≈ 16.6 ms、30 FPS ≈ 33 ms），再判定瓶颈类别，再定位到具体系统，最后给出前后一致的量化验证。

- **CPU-bound（主线程）**：脚本、物理、动画、剔除、粒子、GC 暂停、序列化。主线程与渲染线程分离，渲染线程耗时不在脚本里但会限制整体吞吐。
- **GPU-bound**：顶点 / 片元处理、带宽、Overdraw、后处理、纹理与显存压力、移动端 tile 渲染特性、分辨率与 UI 全屏透明层。
- **其他**：加载与 IO 卡顿、内存压力导致系统回收、驱动 / 平台限制、后台线程竞争锁。

**官方工具与考点边界** [S011][S013][S014][S015]：Unity Profiler（CPU 模块、层级与自持时间）、Deep Profile（开销会显著改变帧表现）、Profiler Memory 模块与分配溢出、Frame Debugger（逐 draw 还原渲染过程）、RenderDoc / Xcode GPU capture、Profiler Analyzer（多帧统计）、Memory Profiler（快照与 diff）、Project Auditor（静态扫描已知性能问题）、外部工具（PerfHUD、平台性能分析器）。自定义 `ProfilerMarker` 的使用与开销。

**L3 / L4 追问重点**：

- 如何区分“主线程等 GPU”与“主线程自己的开销”。
- Deep Profile 为什么不能用于结论性测量；如何只用发布版数据判断。
- 帧时间尖峰的统计方式：为什么平均值会掩盖问题、应该看分布与最大帧时间。
- 一次真实定位：现象 → 假设 → 采集的数据 → 排除掉的可能性 → 修复 → 同负载复测。

---

## 3. 脚本性能与每帧分配

**已核实的官方建议** [S025]：

- 每个 MonoBehaviour 消息方法（`Update`、`LateUpdate` 等）被调用都伴随一次原生侧到托管侧的 **interop 调用**；数量上千时开销显著。建议实现自定义 Update Manager，让需要回调的对象订阅 / 退订。
- 尽量把不必每帧执行的逻辑移出 `Update` / `FixedUpdate`；确需高频执行时按 `Time.frameCount % n` 分批，或用**时间切片**把一份大数据拆到多帧处理，避免周期性尖峰。
- 在 `Awake` / `Start` 缓存组件引用，避免每帧 `GetComponent`。官方说明：Unity 2020.2 之前 `GameObject.Find`、`GameObject.GetComponent`、`Camera.main` 非常昂贵，之后不再是极端操作，但仍不建议每帧调用。
- 避免留空的 Unity 事件函数（仍会产生调用开销）；用 `[System.Diagnostics.Conditional("ENABLE_LOG")]` 包裹自定义日志封装，使发布构建剥离 `Debug.Log` / `DrawLine` / `DrawRay`；发布版关闭或限制 Stack Trace Logging。
- Animator / Material / Shader 内部按 **hash 的整数 ID** 寻址属性，应使用 `Animator.StringToHash` 与 `Shader.PropertyToID` 并在初始化时缓存，而不是每帧传字符串。
- `Instantiate` / `Destroy` 会产生分配与 GC 尖峰；对高频创建销毁的对象（子弹、特效、UI 列表项）使用**对象池**预创建并复用；Unity 2021 LTS 起提供 `UnityEngine.Pool` 命名空间管理池与生命周期。
- 静态配置数据用 **ScriptableObject** 承载：不需要 GameObject 与 Transform 的额外开销，多对象共享同一份数据引用，等价于 flyweight 模式。

**L3 / L4 考点**：给一个每帧分配的具体来源清单（装箱、字符串拼接与格式化、LINQ 与闭包、`new` 容器、`GetComponent`、值类型 `ToString`、非泛型集合、协程 `yield return` 产生的临时对象），要求结合 Profiler 的分配视图定位并说明修复后的分配量变化。答案要能连到 `csharp-dotnet.md` §2 的 GC 因果链。

---

## 4. 内存与资源生命周期

**考点范围**（具体语义以 [S012][S023][S027] 为准）：

- 内存构成：托管堆、native 堆（纹理 / Mesh / AnimClip 的图形资源）、纹理与 RenderTexture 的实际占用（尺寸 × 格式 × Mipmap × 数组层）、AssetBundle 压缩与解包后的差异、序列化与常驻、AB 依赖、场景与 UI 预制体。
- 平台限制：32/64 位地址空间、移动端单进程可用内存上限、系统因内存压力直接杀进程（不只是“卡顿”）、纹理压缩格式与 GPU 支持差异。
- 加载与卸载：`Resources` 与 AssetBundle / Addressables 的差异（依赖、引用计数、打包冗余、可寻址性）；Addressables 的 `AsyncOperationHandle` 必须释放、实例化对象需要 `Release` 归零后才会卸载；AssetBundle 的 `Unload(false)` 与 `Unload(true)` 对已加载对象和实例化对象的后果差异；`Resources.UnloadUnusedAssets` 的触发成本与时机；`Resources.UnloadAsset` 的适用限制。
- 泄漏与膨胀的典型根因：静态字典缓存资源、事件未取消订阅、Object 未 Destroy（含 GameObject 组件与 Mesh 实例）、实例化的 `Material` 副本、常驻的 AB、`Destroy` 与生命周期结束时序、TextureStreaming 未生效。
- 启动耗时：程序集加载与 JIT/AOT、场景与 AB 下载、序列化反序列化、Shader 预热（ShaderVariantCollection）、首帧资源同步加载。
- 包体与分发：AB / Addressables 的分组粒度与热更新，冗余与共享依赖，压缩与 CDN 缓存，资源版本与兼容（旧包加载新数据），下载失败与重试策略。

**L3 / L4 题干模板**：给定“低端机上运行 30 分钟后被系统杀掉”或“切换场景后可用内存不回升”，要求给出内存快照对比策略、可疑对象类型、引用链判读方法、修复方案和复测证据。

---

## 5. 渲染与合批

**考点范围**（生效条件以 [S020][S021][S022][S026] 为准）：

- CPU 侧渲染开销：Draw Call 提交、SetPass（材质 / 状态切换）、剔除与可见性计算、材质与属性上传。GPU 侧：顶点与片元处理、纹理采样与带宽、Overdraw、后处理与 RT 切换。
- **SRP Batcher**：以常驻材质常量缓冲区减少每帧属性上传的 CPU 开销；判定条件是 Shader 兼容（材质属性放入统一 cbuffer），Batch 会因 Shader / 材质变化而中断；候选人说“它减少了 Draw Call 数量”时应追问区别。[S020]
- **GPU Instancing**：相同 Mesh + 相同材质、差异通过每实例属性传入；受平台与 Shader 支持、实例数量与属性大小影响。[S021]
- 静态合批（合并网格，牺牲内存与灵活性）、动态合批（受顶点数限制，属 Built-In 行为，是否适用要问管线）。
- 剔除：视锥剔除、遮挡剔除（需要静态物体与预计算数据，动态物体不自动受益）、UI 的 Overdraw 与矩形剔除、粒子的视锥与距离剔除。[S022]
- 网格与材质：图集与 UV 布局、纹理压缩格式、Mesh 顶点属性与精度、LOD / GPU LOD、法线贴图与 PBR 的带宽代价、SRP Batcher 与 Shader 变体爆炸。
- 光照与后处理：烘焙 Lightmap 与 Light Probe、实时光数量与渲染路径、阴影距离与级联、雾 / Bloom / 颜色分级等全屏 pass 的成本、移动端 MSAA 与解析度缩放的取舍。
- UI：Canvas 重重建（脏标记导致的整层重建）、合批被中间材质打断、Image 与 SpriteAtlas、Scissor / Mask 成本、超高分辨率下的填充率。
- 分辨率与画质动态缩放（Runtime performance scaling）：用什么指标触发、避免抖动、如何确认玩家感知。[S011]

**L3 / L4 题干模板**：给一个“同屏 FPS 从 60 掉到 25”的具体现场（含 Draw Call、SetPass、主线程 / GPU 时间数字），要求判定瓶颈类别、给出下一步采集动作、并列出至少两种不同侧（CPU 提交 vs GPU 填充）的优化方案及各自代价。

---

## 6. 物理与动画

**考点范围** [S024]：

- 固定步与时间：`FixedUpdate` 与渲染帧的对应关系、最大步长限制如何避免死亡螺旋（追帧过多 → 更慢）、`Time.timeScale` 对物理的影响。
- 模拟成本：Rigidbody 数量与休眠、`Collision Detection` 模式与穿透、离散 vs 连续检测、Layer Collision Matrix、`Physics.Simulate` 手动步进（配合 `SimulationMode.Script`）。
- 查询成本：`Raycast` vs `RaycastAll`、Overlap 系列与 `NonAlloc` 变体分配、查询触发器与 `queriesHitTriggers`、命中层过滤、避免每帧对所有实体做全量查询（用空间划分或分批）。
- 角色控制：CharacterController 与 Rigidbody 的取舍、`Move` / `SimpleMove` 与台阶与斜面、根运动与网络同步的一致性。
- 动画：Animator 更新成本、状态机与 Layer、Avatar、`Playable API` 的批量与自定义求值、混合树与 IK（`OnAnimatorIK` 的调用位置）、蒙皮与骨骼数、GPU 蒙皮 / 顶点动画纹理的适用条件、布料的成本。
- 与生命周期的关系：`OnAnimatorMove` / `OnAnimatorIK` 与 `Update` 的先后，物理回调可能在 `FixedUpdate` 之前或之后触发导致状态读写不一致。[S010]

---

## 7. 游戏代码架构与数据驱动

**考点范围**：

- 分层与解耦：表现层 / 玩法层 / 数据层边界；Module / Feature 划分与 asmdef 边界对编译时间与依赖检查的作用；哪些跨层调用会造成后期无法拆分的耦合。
- 数据驱动：ScriptableObject 作配置与 flyweight、配置到运行时对象的构建流程、数据校验与编辑器导入器、策划可改数据的版本与热更兼容。[S025]
- 事件与消息：事件总线 / 信号系统的订阅生命周期、顺序依赖、调试可见性（谁触发谁）、与直接引用的取舍；避免把全局单例当默认方案。
- 状态与行为：有限状态机 / 分层状态机 / 行为树 / 数据驱动技能的适用场景；回放与确定性（固定种子、时间步进、避免浮点跨端不一致）。
- ECS / DOTS：Archetype 与 chunk 的连续内存布局为什么能降低缓存不命中、结构性变更的成本、Job 与 Burst 的收益与限制、`NativeArray` 等容器与 Allocator、主线程限制与 Safety System、`CompletionSource` / JobHandle 依赖链。什么规模与类型的项目值得引入，以及团队与调试成本。[S017][S028]
- 异步与热更：IL2CPP / AOT 后端下 C# 无法运行时编译新代码，热更方案的常见形态（数据与配置驱动、脚本层如 Lua、解释器或反射式补丁），各自的性能、安全与商店合规风险；协程、`async`、`Awaitable` 在游戏循环中恢复时机的差异与选型。[S018][S019]
- 编辑器与流水线：自定义 Inspector / PropertyDrawer、EditorTool、Scripted Importer、AssetPostprocessor、Build Pipeline / IPreprocessBuildWithReport、PlayMode 与 EditMode 测试、自动化打包与资源校验、崩溃符号化与 IL2CPP 行号还原。
- 常见架构反模式：把 MonoBehaviour 当唯一组织方式（无法脱离引擎单测）、上帝单例、通过 `Find` / 名字耦合、场景加载与卸载造成静态状态残留、UI 与玩法互相持有、以事件传递数据替代接口。

**L4 题干模板（3.4 场景 / 设计）**：给一个会随版本增长的现实约束（例：同一套战斗逻辑要在客户端、服务器回放和自动化测试中运行；或包体从 2 GB 降到 800 MB 同时热更体积可控），要求给出模块边界、依赖方向、资源与代码的分发方案、演进与回滚路径、以及验证手段和被放弃的方案与放弃理由。

---

## 8. 网络与多人（岗位涉及时使用）

- 状态同步 vs 帧同步（锁步 / 回滚）的带宽、服务器权威、反外挂、掉线重连、跨端浮点一致性上的差异与取舍。
- 客户端预测、服务器和解、插值与外推、实体快照与延迟补偿；抖动缓冲与帧率适配。
- 序列化与带宽：位压缩、增量与脏标记、AOI / 兴趣管理、广播分组与优先级、消息合并与限频。
- 连接与传输：UDP 之上自建可靠层、MTU 与分片、NAT 打洞 / 中继、断线与重连的状态一致性。
- 与主循环的关系：网络线程与主线程的数据交接、避免在网络回调里直接改场景对象、`CompletionSource` / 队列消费。

---

## 9. 跨引擎迁移问法（目标栈与候选人栈不一致时）

把引擎专属知识抽象成通用能力后提问，参考答案先给通用原理，再允许候选人用其熟悉的技术栈说明实现与工具。

| 通用能力 | 迁移题干示例 | 优秀回答应覆盖 |
| --- | --- | --- |
| 帧循环与调度 | 在你的引擎里，一个逻辑系统如何拿到每帧固定步长、如何控制执行顺序 | 游戏循环分层、固定步与累加器、系统注册与顺序控制、避免依赖脚本注册顺序 |
| 组件与实体模型 | 大量同类单位如何组织数据与更新 | 组合优于继承、数据布局与缓存、更新裁剪、批量与并行、生命周期 |
| 资源生命周期 | 资源从加载到卸载的完整链路与引用管理 | 显式引用计数 / 句柄、依赖闭包、卸载时机与残留对象、加载失败与超时 |
| 渲染批次 | 你如何降低同屏提交成本 | 状态切换与材质归并、实例化前提、剔除、带宽与填充率、测量方法 |
| 内存与 GC | 长时运行后的内存增长与尖峰如何排查 | 分配来源分层、快照 diff、池化与复用、量化验证 |
| 事件系统 | 模块间通信如何解耦又不失控 | 订阅生命周期、顺序与状态一致性、可观测性、与直接引用的边界 |
| 网络同步 | 同步方案选型与不一致的定位 | 选型取舍、权威端、预测与和解、可重放的日志与验证 |
| 调试与度量 | 无 Profiler 环境下的性能定位 | 标记与埋点、预算与阈值、复现用例、回归基线 |

**红线**：不得把候选人未实际使用过的引擎的专属 API、生命周期、资源系统或渲染管线作为正式题目主要考点；对该引擎的现有接触程度只在面试官备注里确认。[S010][S011] 的机制内容同样适用于快速确认目标栈排雷点。

---

## 10. 不得作为考点的内容

- 编辑器菜单项位置、快捷键、旧版本 API 名称的背诵。
- 只有在特定管线 / 平台 / 版本才成立的“一定”结论（动态合批适用范围、SRP Batcher 生效细节、纹理压缩格式支持、`Camera.main` 开销等级）。
- 只问“你知道什么是 Addressables / ECS”而不给场景与约束。

---

## 11. 来源

[S010] 事件函数执行顺序与 Player Loop · [S011] 官方优化工具与主题划分 · [S012]–[S015] 内存、Profiler、Memory 模块、ProfilerMarker · [S016] Script Execution Order · [S017] Job System · [S018] `Awaitable` · [S019] IL2CPP 后端 · [S020]–[S022] SRP Batcher、GPU Instancing、遮挡剔除 · [S023] AssetBundle · [S024] 物理 CPU 优化 · [S025] 脚本与代码架构官方建议 · [S026] 移动端 / XR / Web 性能 E-Book · [S027] Addressables · [S028] Entities / ECS
