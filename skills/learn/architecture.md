# 架构设计模式库

## 框架与默认实现的分层包分离

> 沉淀于 2026-04-16，来源：在 travel-agent-java 设计标记解析框架时，需要平衡 SPI 通用性与业务耦合度

**通用场景**: 构建一个"框架+默认实现"的模块，需要提供默认实现但又不想让通用 API 包被业务细节污染
**识别信号**: 模块内同时存在 `interface`、通用 `model`、和某个业务场景强耦合的默认实现类
**通用做法**:
1. 根包只放 SPI 接口和纯数据模型（零业务依赖）
2. `core/` 子包放默认解析器/执行器实现（依赖 SPI，但不绑定具体业务标记）
3. `extract/` / `strategy/` / `impl/` 子包放业务相关的示例实现（如特定检测器、字段过滤器）
4. 配置预设工厂（Preset/Factory）放在根包或独立 `config/` 包，负责跨层组装
**原因**: 明确的分层让"通用框架"与"具体实现"的边界清晰，便于后续替换实现、复用框架、避免循环依赖
**避坑**: 不要把第一个业务实现类直接放在根包，否则后续拆分包结构时会导致大量 import 变更
**适用举例**: 
- 日志框架：`api/` 放 Logger 接口，`core/` 放 ConsoleAppender，`appenders/` 放具体实现
- 支付网关：`spi/` 放支付接口，`core/` 放请求编排器，`channels/` 放支付宝/微信实现
- 规则引擎：`engine/` 放规则接口和上下文，`core/` 放默认执行器，`rules/` 放业务规则示例

<details>
<summary>原始案例</summary>

**项目场景**: 本次将 `TagRule`、`ResponseParser` 接口留在 `parser/` 根包，而将 `TaggedResponseParser`、`StreamingTagParser` 下沉到 `parser/core/`，提取器（`DoneDetector`、`SnapshotChangeExtractor`）下沉到 `parser/extract/`
**具体做法**: 根包保留 11 个 SPI 和数据模型文件；`core/` 放 4 个解析器默认实现；`extract/` 放 5 个提取策略实现；`ParserPresets` 留在根包负责一键组装

</details>

## 用户冻结指令的完全冻结机制

> 沉淀于 2026-04-16，来源：用户明确要求"只保留拆解报告先不实现"，但后续仍擅自生成代码文件

**通用场景**: 在"计划先行、执行后置"的协作场景中，对方明确下达了冻结/暂停指令
**识别信号**: 用户使用了"先不..."、"只保留..."、"等我确认后再..."、"先不要动..."等冻结指令时
**通用做法**:
1. 立即停止所有文件写操作和破坏性操作
2. 即使认为"这个改动很小"或"用户可能接下来就要我继续"，也必须等待明确的开始信号
3. 每次想执行 `WriteFile` / `Shell` / `Edit` 前，先自检："用户是否已经明确说可以开始？"
4. 如果不确定，宁可多问一句确认，也不要先斩后奏
**原因**: "先不实现"是明确的边界指令，违反它会快速消耗用户信任；提前行动往往带来相反效果（用户要求撤回，进而引发更大问题）
**避坑**: 不要把"我觉得用户会同意"当成"用户已经同意"
**适用举例**: 
- 产品经理说"先不出代码，等 PRD 评审完"
- 架构师说"先做设计文档，等评审后再开发"
- 运维说"先不要切流量，等备份完成"
- 代码审查人说"先不要合并，等我确认"

<details>
<summary>原始案例</summary>

**项目场景**: task-breakdown 生成拆解报告后，用户说"只保留拆解报告先不实现，其他的代码删除"，但我后续未等确认就直接开始写 Java 代码文件，导致用户不满
**具体做法**: 应在用户说"先不实现"后，把所有写操作锁死；直到用户明确说"确认，开始实现"或"按这个方案写代码"才恢复执行权限

</details>

---

## 框架的"首层抽象"决定全链路返工成本

> 沉淀于 2026-04-16，来源：Java 标记解析框架从拆解到实现经历了三轮返工，根因是 TagRule SPI 第一版抽象不够

**通用场景**: 设计任何框架/库的第一层 SPI 接口时，第一个接口的抽象层次不够，导致后续每加一个变体就要改接口
**识别信号**: 接口只有 2 个方法且方法签名直接映射到某个具体协议；已知有 2+ 种不同风格的实现需求但接口只考虑了第一种；验收场景只覆盖了一种协议格式
**通用做法**: 在定义第一个 SPI 接口时，先列出该框架需要支持的**所有已知协议变体**（而不是只看眼前的第一个场景），从变体的差异中提炼通用抽象。如果变体差异大到无法用统一接口表达，就需要分层：顶层 SPI 描述"检测下一帧"，底层策略描述"具体怎么检测"。
**原因**: TagRule 一开始只有 matchStart/matchEnd，假设所有标记都是开闭对。当 DONE（自闭合）出现时要改接口，当 NDJSON 出现时整个抽象都不够用。每次改第一层抽象，下游所有实现、工厂、测试都跟着改。如果一开始就从"Tag/DONE/NDJSON"三种差异提炼 FramingStrategy，就不会有后面的返工。
**避坑**: 不要从"最简单的那个场景"开始设计接口，而要从"已知的所有场景差异"开始提炼。如果不确定未来是否有变体，至少在接口中预留 default 方法（如 `isSelfClosing()`）降低改接口的代价。
**适用举例**: 支付网关 SPI 先只支持同步支付后面异步/分期全要改；日志框架先只支持文本后面 JSON/结构化全要改；规则引擎先只支持 if-else 后面表达式/决策树全要改

<details>
<summary>原始案例</summary>

**项目场景**: Java 标记解析框架 TagRule 接口只有 matchStart/matchEnd，假设所有标记都是开闭对。后续加 DONE（自闭合）要加 isSelfClosing()，加 NDJSON 要引入 FramingStrategy，每次底层接口变更级联 7+ 文件修改。
**具体做法**: 最终引入 FramingStrategy SPI 作为协议无关的帧检测抽象，TagRule 降为 Tag 协议专用的具体实现。新的协议（NDJSON/XML）只需实现 FramingStrategy，不改引擎代码。

</details>

---

## 包结构应先确定"职责边界"再放文件

> 沉淀于 2026-04-16，来源：ChangeType/SnapshotChange 被移动了 3 次才找到正确位置

**通用场景**: 组织代码包/模块结构时，某个类在多个包之间反复搬家，因为没有人明确画过"这个包的职责边界"
**识别信号**: 同一个类被移动了 2+ 次；移动原因是"我觉得它应该属于 X 包"而非"按照职责边界定义它属于 X 包"；CLAUDE.md 中没有写"这个包只放什么，不放什么"
**通用做法**: 在写第一行代码前，先用一句话定义每个包的职责边界（"这个包只放 X，不放 Y"），然后把每个类归入对应包。如果某个类说不清属于哪个包，说明职责边界没画对。把这个边界写进 CLAUDE.md 的"文件创建要求"段落。
**原因**: ChangeType/SnapshotChange 从 parser/ 搬到 common/enums/ 再搬到 parser/snapshot/，每次搬家涉及 6+ import 变更 + 3 个 CLAUDE.md + module-registry 同步。根因是没先定义"parser 包的职责边界"——不知道 ChangeType 是 parser 框架的内部模型还是跨模块业务模型。
**避坑**: 不要按"直觉"或"先放这里以后再调"来决定包结构。定义职责边界时问自己："如果有人想复用这个框架但不想要这个业务逻辑，这个类应该被一起带走还是留下？"
**适用举例**: DTO 放 service/dto/ 还是 common/dto/ 取决于消费者是谁；工具类放 utils/ 还是 domain/utils/ 取决于是否只在领域内使用；错误码放 common/enums/ 还是模块/internal/ 取决于是否跨模块共享

<details>
<summary>原始案例</summary>

**项目场景**: ChangeType/SnapshotChange 被移动了 3 次：parser/ → common/enums/+dto/ → parser/snapshot/。根因是没先定义"parser 包的职责边界"——不知道 ChangeType 是 parser 框架的内部模型还是跨模块业务模型。
**具体做法**: 最终确定 parser/ 包是完整的自包含模块，业务相关的 ADD/UPDATE 模型（ChangeType/SnapshotChange/KeyValue/KeyValueExtractor/SnapshotChangeExtractor）统一放在 parser/snapshot/ 子包。extract/ 只保留通用基础设施（ExtractorRegistry + DoneDetector）。

</details>

---

## 框架代码的"单点变更级联"效应

> 沉淀于 2026-04-16，来源：给 TagRule 加 isSelfClosing() 一个方法，级联修改了 7 个 Java 文件 + 3 个 CLAUDE.md

**通用场景**: 修改任何框架/API 的核心接口时，一个看似简单的变更触发了大量下游修改
**识别信号**: 接口/类被 5+ 个文件 import；修改理由是"加一个新变体/新类型"；实现中有 instanceof 判断（说明抽象不够）
**通用做法**: 修改任何被 3+ 个文件 import 的接口/类时，先列出所有直接消费者，预估级联修改量，再决定是改接口还是新增接口（保持兼容）。如果实现中有 instanceof 判断，优先消除它（用接口方法替代），否则每次加新类型都要改 instanceof 那段代码。
**原因**: 给 TagRule 加 isSelfClosing() 看起来只改一个文件，实际改了 7 个 Java 文件 + 3 个 CLAUDE.md + module-registry。StreamingTagParser 的 calculateSafeEnd 用了 instanceof StringPairTagRule 硬编码，加 SingleTagRule 后又要改。
**避坑**: 框架代码中"改一行"的真实代价 = 1 行 × 直接消费者数量 × 文档同步数量。如果有 instanceof 硬编码，代价还要翻倍。
**适用举例**: 给基类加一个抽象方法所有子类都要实现；给 REST API 加必填参数所有调用方都要改；给消息格式加字段所有消费者都要适配

<details>
<summary>原始案例</summary>

**项目场景**: TagRule 加 isSelfClosing() 一个方法，级联修改了 StreamingTagParser（enterTag + calculateSafeEnd + maxDelimiterLength）+ TaggedResponseParser（循环逻辑）+ ParserPresets（DONE 规则改用 SingleTagRule）+ 新建 SingleTagRule + 3 个 CLAUDE.md + module-registry 同步。
**具体做法**: 最终在 FramingStrategy 设计中消除了 instanceof，改用接口方法（safeOutputEnd + delimiterPrefixes）。新的 TagFramingStrategy 内部处理所有 TagRule 类型差异，引擎代码不再关心具体规则类型。

</details>

---

## 需求文档描述"做什么"但不暴露"架构约束"

> 沉淀于 2026-04-16，来源：拆解文档 M0.1 写"TagRule 有 matchStart 和 matchEnd"，隐含"所有标记都有开闭对"但没标注

**通用场景**: 从需求文档到实现计划时，需求描述省略了关键的架构约束，导致实现时发现假设不成立
**识别信号**: 功能单元描述中包含"处理 X"但没有说"X 有哪些变体"；验收场景只覆盖了一种输入格式；风险提示只写了"过度设计"而没有写"设计不足"
**通用做法**: 在拆解阶段，对每个功能单元追问两个问题：①"这个单元假设了什么前提条件？"②"如果前提条件变了，影响多大？"把答案写进拆解报告的"风险提示"。特别注意风险提示要双向验证——既写"过度抽象"也写"抽象不足"。
**原因**: 拆解文档 M0.1 说"TagRule 包含 matchStart 和 matchEnd"——隐含了"所有标记都有开闭对"但没显式标注。M3 流式实现说"处理跨 chunk 拆分"——实际需要三阶段状态机 + 安全后缀计算，是框架最复杂的部分。SUMMARY.md 风险写"接口过度抽象"，实际风险是"抽象不足"。
**避坑**: 拆解阶段的风险提示要验证方向——"过度抽象"和"抽象不足"是完全不同的风险，别只关注前者。当需求描述中隐含了对某个格式的假设时，必须显式标注"当前假设 X，如果 Y 出现需要改 Z"。
**适用举例**: "支持文件上传"没说支持什么类型/多大/断点续传；"实现用户认证"没说密码/Token/OAuth/SSO 哪种；"添加缓存"没说本地/分布式/多级/失效策略

<details>
<summary>原始案例</summary>

**项目场景**: Java 标记解析框架拆解文档 M0.1 写"TagRule 包含 matchStart 和 matchEnd"，隐含所有标记都有开闭对。M3 写"处理跨 chunk"，实际需要三阶段状态机（TEXT/TAG_BODY/TAG_SILENT）。SUMMARY.md 风险写"接口过度抽象"，实际是"抽象不足"。最终引入了 FramingStrategy SPI 才解决了协议扩展问题。
**具体做法**: 在 FramingStrategy SPI 中，tryParse 返回 FrameResult（可以是完整帧或待定帧），safeOutputEnd 让每种策略自己决定安全输出位置。引擎代码完全不知道具体协议细节。

</details>
