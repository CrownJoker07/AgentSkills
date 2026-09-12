# 来源索引（SOURCES）

> 本文件是 `references/` 的统一来源注册表。正文中的 `[S001]`、`[S010]` 等编号均指向这里。
>
> **使用原则**
>
> - 来源只用于确定**考点范围、机制因果链和参考答案的深度基准**，不得整段复制原文，也不得把来源内容当作候选人的经历证据。
> - 厂商文档（Microsoft Learn、Unity Manual）中的行为多数与**具体版本和运行时配置**相关。引用时必须区分“语言规范 / 通用原理”“主流运行时实现”“特定版本行为”，不得把实现细节表述为语言保证。
> - 题目站点（如 [S004]、[S043]）只提供**考点清单和常见问法**，不提供标准答案。其答案表述若与厂商文档冲突，以厂商文档为准；若已过时或与当前版本不符，以当前版本文档为准。
> - 标注“本仓库整理”的条目，是基于多个来源重新组织的面试官工作规范（考点分层、红旗判定、配额映射），不是任何来源的原话。
> - 候选人实际使用的技术栈与本文档不一致时，按 SKILL.md 的技术栈迁移规则改写题目，不强行考本栈专属机制。
>
> 检索日期：2026-09-12

---

## C# / .NET

### S001 — Fundamentals of garbage collection（.NET）

- **发布方**：Microsoft Learn
- **URL**：https://learn.microsoft.com/en-us/dotnet/standard/garbage-collection/fundamentals
- **页面日期**：ms.date 2025-10-22，updated 2026-03-30
- **读取状态**：已通读
- **核心主题**：虚拟内存三态、托管堆与分配指针、roots（栈上局部变量、静态数据、GC handle、栈回溯）、标记 / 重定位 / 压缩三阶段、Gen0/1/2 与 LOH（≥ 85,000 字节，逻辑上随 Gen2 回收）、触发 GC 的三种条件、生存率与分配阈值自适应、Workstation 与 Server GC、临时段（ephemeral segment）默认大小、LOH 默认不压缩及按需压缩、GC 期间挂起托管线程、非托管资源与 `Dispose` / `SafeHandle` / `Finalize`
- **本仓库用途**：`csharp-dotnet.md` §1、§2

### S002 — Debug memory leaks（.NET diagnostics）

- **发布方**：Microsoft Learn
- **URL**：https://learn.microsoft.com/en-us/dotnet/core/diagnostics/debug-memory-leak
- **读取状态**：仅收录为出处（未逐节通读）
- **核心主题**：`dotnet-counters` / `dotnet-dump` / `dotnet memory` 等诊断工具的使用路径，托管堆增长的排查流程
- **本仓库用途**：`csharp-dotnet.md` §2（诊断指标与排查路径）

### S003 — Async and await：advanced / async scenarios

- **发布方**：Microsoft Learn
- **URL**：https://learn.microsoft.com/en-us/dotnet/csharp/asynchronous-programming/async-scenarios
- **读取状态**：仅收录为出处（重定向自 `/dotnet/standard/async-in-depth`）
- **核心主题**：`async` / `await` 的使用场景与最佳实践、`Task` 与线程的关系
- **本仓库用途**：`csharp-dotnet.md` §1、§3

### S004 — C# Interview Questions（Top 70+）

- **发布方**：InterviewBit
- **URL**：https://www.interviewbit.com/c-sharp-interview-questions/
- **页面日期**：Last Updated 2026-02-23
- **读取状态**：已通读（题目清单与分类）
- **核心主题**：CLR / 托管与非托管、GC 触发条件、class 与 struct、装箱拆箱、`ref` 与 `out`、`const` 与 `readonly`、`String` 与 `StringBuilder`、`==` 与 `Equals`、抽象类与接口、重写与隐藏、多态、泛型与协变逆变、`IEnumerable` / `ICollection` / `IList`、委托与事件、LINQ、`async`/`await` 与 `Task`/`Thread`、反射、延迟绑定、属性与索引器、partial / sealed / static class、SOLID、单例 / 工厂 / 观察者 / 策略、仓储模式与依赖注入、ASP.NET Core 中间件管道、EF Code-First 与懒加载 / 预加载
- **本仓库用途**：`csharp-dotnet.md` §1 考点地图（分类与问法），答案要点以 S001–S003 重写
- **备注**：该页部分答案表述偏简化（如“Gen2 即代 3”、以“`==` 比较引用、`Equals` 比较值”概括所有类型），本仓库已在对应条目改写并标注边界

---

## Unity / 游戏客户端

### S010 — Event function execution order（Unity Manual）

- **发布方**：Unity Technologies
- **URL**：https://docs.unity3d.com/Manual/execution-order.html
- **页面版本**：Unity 6.6（6000.6），built 2026-09-10
- **读取状态**：已通读
- **核心主题**：MonoBehaviour 事件函数生命周期图、完整 Player Loop 与 `LowLevel.PlayerLoop` API、自定义 Player Loop、物理步进随 `Physics.simulationMode`（FixedUpdate / Update / Script）落在不同阶段、物理步进包含的内容（碰撞检测、积分、写回 Transform、`OnTrigger*` / `OnCollision*` / `OnJointBreak*` 回调）、动画更新顺序与 `StateMachineBehaviour` 回调、渲染相关回调（`OnPreCull`、`OnBecameVisible`、`OnWillRenderObject`、`OnPreRender`、`OnRenderObject`、`OnPostRender`、`OnRenderImage`、`OnGUI`）及必须挂在同一 Camera 物体上的限制、Built-In Render Pipeline 已进入弃用周期、协程与 `Awaitable` 的恢复点（顺序不保证）、同一脚本不同实例间调用顺序不保证、跨脚本用 Script Execution Order 配置、ECS 系统组并入 Player Loop
- **本仓库用途**：`unity-game.md` §1

### S011 — Optimization（Unity Manual 主题索引）

- **URL**：https://docs.unity3d.com/Manual/analysis.html
- **读取状态**：已通读（索引页）
- **核心主题**：Unity 官方优化主题划分：Memory in Unity、Unity Profiler、Graphics performance and profiling、Runtime performance scaling、Project Auditor、Profiling tools reference；官方 E-Book《Optimize your game performance for mobile, XR, and the web in Unity》《Ultimate guide to profiling Unity games》
- **本仓库用途**：`unity-game.md` §2 工具矩阵与考点边界

### S012 — Memory in Unity — https://docs.unity3d.com/Manual/performance-memory.html
### S013 — Unity Profiler — https://docs.unity3d.com/Manual/Profiler.html
### S014 — Profiler memory module — https://docs.unity3d.com/Manual/ProfilerMemory.html
### S015 — Profiler markers — https://docs.unity3d.com/Manual/profiler-markers.html
### S016 — Script execution order — https://docs.unity3d.com/Manual/script-execution-order.html
### S017 — C# Job System — https://docs.unity3d.com/Manual/job-system.html
### S018 — Asynchronous programming with the Awaitable class — https://docs.unity3d.com/Manual/async-await-support.html
### S019 — IL2CPP scripting backend — https://docs.unity3d.com/Manual/scripting-backends-il2cpp.html
### S020 — SRP Batcher — https://docs.unity3d.com/Manual/SRPBatcher.html
### S021 — GPU instancing — https://docs.unity3d.com/Manual/GPUInstancing.html
### S022 — Occlusion culling — https://docs.unity3d.com/Manual/OcclusionCulling.html
### S023 — AssetBundle 入门 — https://docs.unity3d.com/Manual/AssetBundlesIntro.html
### S024 — Physics optimization（CPU） — https://docs.unity3d.com/Manual/physics-optimization-cpu.html
### S027 — Addressables 包手册 — https://docs.unity3d.com/Packages/com.unity.addressables@2.0/manual/index.html
### S028 — Entities（ECS）包手册 — https://docs.unity3d.com/Packages/com.unity.entities@1.4/manual/index.html

- **发布方**：Unity Technologies
- **读取状态**：以上条目均只验证可访问（200），未逐节通读
- **用途**：作为对应考点的**权威出处**。生成涉及内存分类、Profiler 面板与采样开销、ProfilerMarker、执行顺序配置、Job System 与 `CompletionSource`、`Awaitable`、IL2CPP / AOT 限制、SRP Batcher 生效条件、GPU Instancing 生效条件、遮挡剔除、AssetBundle 加载与卸载语义、物理步进与查询优化、Addressables 引用计数、ECS 系统与 chunk 结构的题目时，指向这些页面核对候选人给出的具体条件、参数名和版本适用范围
- **本仓库用途**：`unity-game.md` §2、§4、§5、§6、§7、§8

### S025 — Advanced programming and code architecture（Unity How-to Guide）

- **URL**：https://unity.com/how-to/advanced-programming-and-code-architecture
- **读取状态**：已通读
- **核心主题**：理解 Player Loop 与脚本生命周期；自定义 Update Manager 以削减 MonoBehavior 消息方法的原生↔托管 interop 调用；最小化每帧代码（必要时按 n 帧执行或做时间切片）；在 `Awake` / `Start` 缓存 `GetComponent` 等引用；2020.2 之后 `GameObject.Find` / `GetComponent` / `Camera.main` 不再是极端昂贵操作但仍不建议每帧调用；避免空事件函数与运行时 `Debug.Log`（用 `[Conditional]` + 预处理宏剥离）；发布版关闭 Stack Trace 日志；使用 `Animator.StringToHash` 与 `Shader.PropertyToID` 代替字符串参数；对象池减少 Instantiate / Destroy 造成的分配与 GC 尖峰，`UnityEngine.Pool` 自 2021 LTS 起提供；ScriptableObject 存放不变配置、避免 GameObject+Transform 额外开销、等价于 flyweight 模式
- **本仓库用途**：`unity-game.md` §3、§4、§7

### S026 — Optimize your game performance for mobile, XR, and the web in Unity（E-Book）

- **URL**：https://unity.com/resources/mobile-xr-web-game-performance-optimization-unity-6
- **读取状态**：仅收录为出处（未下载 PDF）
- **用途**：移动端预算、GPU 与带宽、渲染与纹理压缩等考点的官方扩展阅读
- **本仓库用途**：`unity-game.md` §5

---

## 架构 / 系统设计

### S040 — Application architecture fundamentals（Azure Architecture Center）

- **URL**：https://learn.microsoft.com/en-us/azure/architecture/guide/
- **页面日期**：ms.date 2026-01-30
- **读取状态**：已通读
- **核心主题**：本地部署与云原生设计的典型差异（单体与同址数据 vs 分解与分布式、固定或超配 vs 弹性伸缩、单一关系库 vs 多语言持久化、同步处理 vs 异步、避免故障与 MTBF vs 容忍故障与 MTTR、雪花服务器 vs 不可变基础设施）；架构师职责；Well-Architected 五支柱；架构风格与数据存储模型；云设计模式目录；核心技术选型（计算 / 数据 / 消息 / AI）；参考架构与服务指南；“不为了云而必须微服务”
- **本仓库用途**：`architecture.md` §1、§3、§6

### S041 — Azure Well-Architected Framework — https://learn.microsoft.com/en-us/azure/well-architected/
### S042 — Cloud Design Patterns（Azure Architecture Center） — https://learn.microsoft.com/en-us/azure/architecture/patterns/

- **发布方**：Microsoft Learn
- **读取状态**：仅验证可访问；五支柱名称与“用模式解决分布式常见问题”的定位来自 [S040] 的正文
- **用途**：可靠性 / 安全性 / 成本优化 / 运营卓越 / 性能效率五支柱，以及熔断器、舱壁、竞争消费者、管道与过滤器、事件溯源、CQRS、Saga、Strangler Fig、Cache-Aside 等模式名的权威出处
- **本仓库用途**：`architecture.md` §3、§6

### S043 — 系统设计入门（system-design-primer，简体中文 README）

- **URL**：https://github.com/donnemartin/system-design-primer/blob/master/README-zh-Hans.md
- **读取状态**：已通读（主题索引、面试流程、性能/延迟吞吐/CAP/一致性模式/可用性模式/DNS/CDN/负载均衡/反向代理/应用层/数据库/缓存/异步/通讯/安全章节）
- **核心主题**：系统设计面试四步法（场景与约束 → 高层设计 → 核心组件 → 扩展与瓶颈）与估算法；性能 vs 可扩展性；延迟 vs 吞吐量；CAP 与 CP / AP；弱 / 最终 / 强一致；故障切换（active-passive、active-active）与复制；DNS 记录类型与路由方式；CDN push / pull 与 TTL；负载均衡（L4 与 L7、SSL 终结、会话保持、水平扩展的无状态要求）；反向代理收益；微服务与服务发现；ACID 与 RDBMS 扩展手段（主从、主主、联合、分片、非规范化、SQL 调优：模式、索引、联结、分表、查询缓存）；BASE 与 NoSQL 四类（键值、文档、宽列、图）；缓存层次与更新策略（cache-aside、write-through、write-back、refresh-ahead）；消息队列、任务队列与背压；TCP / UDP / RPC / REST；附录含 2 的次方表与“每个程序员都应该知道的延迟数”；OO 设计题清单（HashMap、LRU、停车场、牌局、呼叫中心、聊天服务）
- **本仓库用途**：`architecture.md` §2、§4、§5

### S044 — Microservice Trade-Offs（Martin Fowler，2015-07-01）

- **URL**：https://martinfowler.com/articles/microservice-trade-offs.html
- **读取状态**：已通读
- **核心主题**：微服务收益（强模块边界、独立部署、技术多样性与库版本隔离）与代价（分布式的延迟与可靠性、最终一致性、运营复杂度与 DevOps 文化要求）；边界划错会让收益变代价；Monolith First 与“微服务溢价”；单体也能做好模块化和持续交付，但要靠纪律；主要取舍之外，按需扩缩与安全隔离是次要因素；软性因素（人的质量与协作）比风格选择更影响项目成败
- **本仓库用途**：`architecture.md` §6

---

## 未采用来源

抓取过程中以下来源不可用，未纳入任何结论：GeeksforGeeks C# 面试页（404）、dotnet.microsoft.com 应用架构页（404）、多个 GitHub 面试仓库（传输失败或 404）、docs.unity3d.com 旧版性能页若干（改名或 404）、Turing / C-Sharp-Corner Unity 题库（403）、InterviewBit Unity 题库（404）、SEI ATAM 页面（404）、ISO/IEC 25010 页面（403）。

如需补充这些方向（尤其是中文软考架构师考点、ATAM / 质量属性场景），必须先取得可访问的权威出处再引用，不得凭印象补写。
