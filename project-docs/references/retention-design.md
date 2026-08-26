# 留存与长期参与分析（Retention Design）

## 0. 用途

用于分析：

- Onboarding
- D1 / D7 / D30
- Return Loop
- 长期目标
- 内容消耗
- 成长
- 社交
- 竞争
- LiveOps

最重要的原则：

> Retention 是结果指标，不是某一个具体机制。

---

## 1. Retention 必须结合上下文

**来源：[S013]**
**性质：行业实践。**

Retention 需要结合：

- Genre
- Business Model
- Audience
- Platform
- UA Channel
- Product Lifecycle
- Content Cadence

### 关于 40/20/10

S013 把 40/20/10 作为常见 baseline/reference，而不是普适定律。

因此禁止：

> D1 不到 40% = 产品失败。

正确：

> 当前 D1 为 X%。需要和该品类、商业模式、历史 Cohort、渠道、生命周期一起判断。

---

## 2. 分阶段看 Retention

**来源基础：[S013][S007]**
**整理方式：本仓库诊断框架。**

### First Session / Onboarding

检查：

- 是否理解核心操作？
- 是否完成第一次有意义成功？
- 是否体验到核心价值？
- 是否有明显阻断？

### Early Retention

常关注：

- Core Loop
- 学习
- 奖励节奏
- 初期成长

### Mid-term

常关注：

- Depth
- Progression
- Collection
- 新目标

### Long-term

常关注：

- Content
- Social
- Competition
- Status
- LiveOps
- 长期身份与投入

这些是诊断维度，不是所有游戏都必须一模一样。

---

## 3. Return Loop

**整理方式：本仓库模型。**

```text
未完成目标
+ 预期价值
+ 合适时间
+ 玩家记得自己要做什么
→ 可能回访
```

检查：

- 玩家离开时是否知道下一目标？
- 下次回来有什么新价值？
- 为什么“以后再来”而不是现在一次做完？
- 等待是否只是阻塞，而非有意义节奏？

---

## 4. 先检查 Core Value，再加 Retention Mechanic

**来源基础：[S013]**
**整理方式：本仓库优先级。**

当 Retention 差时优先诊断：

1. Core Value
2. Comprehension
3. Progression
4. Goal Structure
5. Content
6. Friction
7. Return Trigger

不要看到 D1 低就直接：

- 加签到
- 加 Push
- 加 Guild
- 加 Streak

这些只是可能的 intervention，不是原因诊断。

---

## 5. 新手阶段

**来源基础：[S011][S013]**

检查：

- Time to First Meaningful Action
- Time to First Success
- Time to First Meaningful Reward
- Tutorial Friction
- First-session Goal Clarity
- Failure Recovery
- 过早出现复杂系统
- 过早商业化

证据：

- Funnel
- Step Drop-off
- Session Duration
- Failure Count
- Observation
- Interview

Telemetry 可以告诉你“掉在哪里”。

Observation / Interview 更适合解释“为什么”。[S011]

---

## 6. Progression 是长期目标结构之一

**来源：[S007]**

成长可以提供：

- 新能力
- 新内容
- 更高挑战
- 更强身份
- 收集完成
- 地位

检查：

- 是否只是数字膨胀？
- Milestone 是否可见？
- 成长间隔是否过长？
- 玩家是否知道未来有什么？
- Endgame 是否仍有目标？

---

## 7. 多时间尺度目标

**整理方式：本仓库目标层级模型。**

示例：

```text
分钟：
完成当前操作

Session：
完成一局/一关

天：
完成一个阶段目标

周：
活动/排名目标

长期：
收集、掌握、地位、建设
```

不是所有游戏都必须有 Daily/Weekly。

关键是目标之间是否：

- 互相支持
- 互相冲突
- 形成压力
- 仍然有意义

---

## 8. Collection / Social / Competition

这些可以支持长期参与，但不是自动有效。

### Collection

检查：

- 是否有差异
- 完成度是否可见
- 获取节奏
- 重复品处理
- 收藏是否有用途

### Social

检查：

- 是否真的互动
- 是否存在互惠
- 是否依赖 Critical Mass
- 协作负担
- Toxicity 风险

有好友列表 ≠ 社交留存。

### Competition

检查：

- Fairness
- Matchmaking
- Recoverability
- Ranking Reward
- Season Reset

有排行榜 ≠ 提升留存。

---

## 9. Cohort 分析

**来源：[S013]**

优先按：

- Install Date
- Version
- UA Channel
- Experiment Variant
- Feature Exposure
- Progression State

比较。

问题应改成：

> 哪个 Cohort 从什么时候开始偏离？

而不是：

> 最近 Retention 为什么低？

---

## 10. Retention 与 LTV 一起看

**来源：[S013]**
**性质：行业实践。**

Retention 说明：

> 玩家是否回来。

LTV 说明：

> 这批玩家长期价值如何。

二者应结合，而不是把 Retention 当唯一健康指标。

---

## 11. 实验

**来源基础：[S013][S011]**

在实验前定义：

- Target Cohort
- Primary Metric
- Expected Direction
- Minimum Meaningful Effect
- Guardrail
- Duration
- Decision Rule

不要看到一个很小差异就立即结论。

---

## 12. 提出留存建议前必须回答

1. 具体哪个 Retention 问题？
2. 生命周期哪一段？
3. 什么证据说明原因？
4. 希望改变什么行为？
5. 新机制为什么会改变该行为？
6. 有什么副作用？
7. 怎样验证？

如果 #3 无法回答：

> 只能标记为 Hypothesis，不能标记为已确认 Solution。

---

## 13. 禁止模板化建议

不要直接写：

- D1 低 → 签到
- D7 低 → Guild
- D30 低 → Battle Pass
- Push 越多越好
- 活动越多越好
- 40/20/10 是必须达到的标准

---

## 来源

本文件主要使用：[S007][S011][S013]。
完整来源信息见 `SOURCES.md`。
