# 证据、推断与建议规范（Evidence and Recommendations）

## 0. 用途

**任何需要给产品建议的任务，优先读取本文件。**

目标：

- 防止把猜测写成事实
- 防止从代码推导玩家心理
- 防止从一个机制直接推导 Retention / Revenue
- 防止把 Benchmark 当目标
- 防止照抄竞品
- 防止“先想解决方案，再找问题”

---

## 1. 证据能证明什么

**来源基础：[S011][S012]**
**整理方式：本仓库 Evidence Hierarchy。**

### 已批准项目文档

可以证明：

- 明确意图
- 已确认规则
- Scope

不能证明：

- 实现正确
- 玩家理解
- 玩家喜欢
- 指标效果

### Code

可以证明：

- 实现逻辑
- 条件
- 状态变化
- 默认行为

不能证明：

- 线上 Config 一定相同
- Server 行为一定相同
- 玩家体验

### Runtime Config / Server Data

可以证明：

- 当前真实可调数值
- Feature Gate
- Reward Table
- Experiment Variant

不能证明：

- 玩家为什么这么做

### Telemetry / Analytics

可以证明：

- 实际行为
- Funnel
- Frequency
- Retention
- Conversion
- Progression

通常不能单独证明：

- Motivation
- Mental Model
- Emotion
- Causal Mechanism

### Observation

**来源：[S011]**

擅长：

- 玩家实际怎么操作
- 卡在哪里
- 错误 mental model
- 非预期行为

### Interview

擅长：

- 玩家如何解释自己的体验
- Motivation
- Mental Model

限制：

- 自我报告偏差
- 事后合理化

### Survey

擅长：

- 大规模 Opinion
- Rating
- Perceived Difficulty

限制：

- “为什么”通常较弱
- Opinion 不等于实际行为

### A/B Test

在设计正确时可以提供更强的因果证据。

但仍需检查：

- Sample
- Allocation
- Metric Definition
- Effect Size
- Guardrail

---

## 2. Claim Taxonomy

**整理方式：本仓库规范。**

所有重要结论尽量标记为：

### Fact

直接有证据。

> 当前线上 Config 中，升级价格为 500 Coins。

### Inference

从事实推导。

> 按当前中位收入速度，约需要 3 次 Session。

必须标假设。

### Hypothesis

合理但未确认。

> 过长等待可能是该阶段流失原因之一。

### Recommendation

行动建议。

> 建议针对该 Cohort 测试更短等待。

### Validation

验证结论。

> Variant B 在预定义样本和窗口内将完成率提高 X，且 Guardrail 无显著恶化。

---

## 3. Confidence

### High

- 直接权威证据
- 多个独立来源一致
- Runtime + Telemetry 支持
- 实验支持

### Medium

- 证据合理
- 依赖少量假设
- 有一致 Playtest 结果

### Low

- 证据稀少
- 竞品类比
- 行业 heuristic
- 推测玩家心理

必须解释低 Confidence 的原因。

---

## 4. 先定义 Research Objective

**来源：[S011][S012]**

先问：

> 我们到底想知道什么？

例如：

- 玩家在哪里失败？
- 为什么失败？
- 这个功能是否被理解？
- 哪个策略是 dominant？
- 新版本是否提高 D7？
- Offer 是否带来 Repeat Purchase？

---

## 5. Measurement vs Understanding

**来源：[S011]**

### Measurement

适合回答：

- 有多少
- 多久
- 多频繁
- 哪一步
- 什么比例

### Understanding

适合回答：

- 为什么
- 玩家怎么理解
- Mental Model 是什么

不要用 Analytics 强行回答 Motivation。

---

## 6. Behaviour vs Opinion

**来源：[S011]**

### Behaviour

玩家实际做了什么。

### Opinion

玩家说自己怎么想。

两者都重要，但不能互相替代。

例如：

> 玩家说这个功能“很有趣”

不能直接推出：

> 玩家以后会持续使用。

---

## 7. 方法选择

**来源：[S011][S012]**

### Observation

适合：

- Usability
- 实际行为
- 首次体验

### Interview

适合：

- 理解原因
- Mental Model

### Analytics

适合：

- Scale
- Funnel
- Usage
- Retention

### Survey

适合：

- Scaled Opinion
- Benchmark Perception

### Mixed Methods

更强的方式：

```text
Analytics
→ 找异常位置

Observation
→ 看实际行为

Interview
→ 理解原因

改设计
→ A/B / Telemetry

验证规模化效果
```

---

## 8. 因果链不能省略

**来源基础：[S009][S011]**
**整理方式：本仓库 Causal Chain。**

错误：

```text
Daily Mission
→ Retention
```

正确：

```text
Daily Mission
→ 提供刷新/未完成目标
→ 某些玩家可能形成次日目标
→ 可能增加回访概率
→ 是否真的影响 Retention 需要 Cohort/Experiment 验证
```

每个箭头都可能失败。

---

## 9. Benchmark 只能是 Context

**来源：[S013]**
**性质：行业实践。**

任何 Benchmark 应记录：

- 来源
- 日期
- Genre
- Platform
- Geography
- Business Model
- Metric Definition

禁止：

```text
行业平均
→ 项目必须达到
```

---

## 10. Competitor 只能证明“有人这样做过”

竞品可以用于：

- 发现方案
- 了解实现模式
- 形成 Hypothesis

不能用于：

> 竞品有，所以我们必须有。

还需要比较：

- Audience
- Core Loop
- Economy
- Scale
- Lifecycle
- Monetization

---

## 11. Recommendation 标准格式

每条建议至少包含：

### Finding

### Evidence

### Interpretation

### Recommendation

### Expected Mechanism

### Risk

### Validation

示例：

```text
Finding:
首次进入活动时，计分规则只在第一次提交后出现。

Evidence:
当前 UI Flow + Config。

Interpretation:
玩家第一次不可逆决策前缺少关键结果信息。

Recommendation:
在首次提交前展示计分规则。

Expected Mechanism:
让第一次决策具有更强 Player Intention。

Risk:
增加首次进入的信息负担。

Validation:
观察首局误操作、理解率和首次完成率。
```

---

## 12. 建议语气与证据强度匹配

### 强证据

> 建议将 X 从 A 调整到 B，并观察 Guardrail Y。

### 中证据

> 现有证据表明 X 可能是主要因素，建议优先测试 B。

### 弱证据

> X 是一个合理假设，但当前证据不足。建议先收集 Y，再决定是否修改系统。

---

## 13. 明确这些边界

**整理方式：本仓库核心 Guardrail。**

- Code 证明实现，不证明体验。
- Config 证明数值，不证明平衡。
- Telemetry 证明行为，不必然证明动机。
- Interview 证明主观表达，不等于未来行为。
- Benchmark 提供背景，不是目标。
- Competitor 提供案例，不是因果证据。
- Design Doc 证明意图，不证明结果。
- Statistical Significance 不等于 Product Significance。

---

## 14. 缺证据时不要停摆，也不要装确定

正确流程：

1. 说缺什么。
2. 说为什么重要。
3. 给 provisional inference。
4. 降低 Confidence。
5. 给最便宜有效的验证方式。

例如：

> 当前没有首局 Telemetry，因此不能确认玩家是否普遍不理解该步骤。
> 但 UI 只有失败后才展示条件，因此存在可理解性风险。
> Confidence：Medium-Low。
> 建议先做 5–8 人 Observation 或增加 Step Funnel。

---

## 15. 证据冲突时

不要把冲突“平均掉”。

检查：

- Cohort
- Version
- 时间
- Config
- Metric Definition
- Sample
- Behaviour vs Opinion

例如：

```text
Survey 满意度高
但 Usage 低
```

可能意味着：

- 喜欢的人很喜欢，但人数少
- Discoverability 差
- Sample Bias
- 功能价值只对特定 Segment 成立

---

## 16. 最终输出建议结构

### Executive Conclusion

结论 + Confidence。

### Confirmed Facts

只写证据支持的事实。

### Findings

证据 + 解释。

### Unknowns

缺什么。

### Recommendations

建议 + 机制 + 优先级。

### Risks

副作用。

### Validation Plan

怎么验证。

### Sources

项目来源 + 外部方法论来源。

---

## 来源

本文件主要使用：[S009][S011][S012][S013][S014]。
完整来源信息见 `SOURCES.md`。
