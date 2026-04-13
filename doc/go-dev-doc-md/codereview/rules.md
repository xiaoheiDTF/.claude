# Go Code Review 规则

> 适用于所有架构模式（标准分层 / Clean Architecture / 微服务）
> 最后更新：2026-04-11

---

## 一、Review 核心原则

> 只要代码确实改善了系统健康度，就应该批准通过，即使它不完美。
> —— [Google Engineering Practices](https://google.github.io/eng-practices/review/reviewer/standard.html)

- 没有"完美代码"，只有"更好的代码"
- 追求**持续改进**，而非一次到位
- 技术事实和数据优先于个人偏好
- 不影响代码健康度的建议，加 **"Nit:"** 前缀表示可选
- 不要让 PR 因为意见分歧而无限期挂起

---

## 二、Review Checklist（审查清单）

### P0 — 必须检查（阻塞合并）

#### 2.1 功能正确性
- [ ] 代码是否正确实现了需求
- [ ] 边界条件是否处理
- [ ] 并发场景是否安全（共享资源、锁、channel）
- [ ] 所有 error 返回值是否检查
- [ ] nil 指针解引用风险是否消除

#### 2.2 安全性
- [ ] 用户输入是否验证和清理
- [ ] SQL 是否参数化（无 SQL 注入风险）
- [ ] 是否有路径遍历风险
- [ ] 敏感信息是否出现在日志或响应中
- [ ] 密码/密钥是否正确加密存储
- [ ] 是否使用 `crypto/rand` 而非 `math/rand` 生成安全随机数

#### 2.3 错误处理
- [ ] 所有 error 是否已检查（无 `_` 丢弃）
- [ ] 错误是否使用 `%w` 包装保留上下文
- [ ] 错误信息是否小写开头、无标点结尾
- [ ] 是否有 panic 用于正常业务流程（应该用 error）
- [ ] 错误是否只处理一次（没有既 log 又 return）

#### 2.4 资源管理
- [ ] HTTP Response Body 是否 `defer resp.Body.Close()`
- [ ] 文件句柄是否 `defer f.Close()`
- [ ] 数据库连接/事务是否正确关闭
- [ ] 是否有资源泄漏风险

### P1 — 重要检查（建议修复）

#### 2.5 并发安全
- [ ] goroutine 是否有明确的退出机制
- [ ] 是否存在 data race（共享可变状态无保护）
- [ ] sync 原语是否通过指针使用（非拷贝）
- [ ] channel 使用是否正确（发送方关闭，非接收方）
- [ ] context 是否正确传递取消信号

#### 2.6 设计合理性
- [ ] 接口是否定义在消费者侧
- [ ] 接口是否足够小（1-3 个方法）
- [ ] 函数是否接受接口、返回具体类型
- [ ] 分层依赖是否清晰（无反向依赖）
- [ ] 是否有不必要的复杂度

#### 2.7 代码质量
- [ ] 命名是否符合 Go 惯例（camelCase/PascalCase）
- [ ] 函数长度是否合理（≤ 80 行）
- [ ] 是否有重复代码（DRY）
- [ ] 是否有魔法值
- [ ] 是否有未使用的变量或 import

#### 2.8 性能
- [ ] 循环中是否有冗余内存分配
- [ ] slice/map 是否预分配容量
- [ ] 是否有不必要的 string↔[]byte 转换
- [ ] 是否有潜在的 goroutine 泄漏

### P2 — 建议检查（不阻塞合并）

- [ ] 代码格式是否通过 gofmt
- [ ] 注释是否符合 godoc 规范
- [ ] 测试覆盖率是否达标
- [ ] 是否使用了更好的设计模式
- [ ] 是否可以简化为表驱动测试

---

## 三、Review 流程规则

### 3.1 提交者（Author）

- 【强制】PR 描述包含：做了什么、为什么做、如何测试
- 【强制】一个 PR 只做一件事，建议 < 400 行
- 【强制】`go vet` 和 `golangci-lint` 检查通过
- 【推荐】自审一遍再提交

### 3.2 审查者（Reviewer）

- 【强制】24 小时内完成 Review
- 【推荐】反馈要具体可操作，不只说"不好"
- 【推荐】区分 "必须改" 和 "建议改"，后者加 "Nit:"
- 【推荐】以学习心态 Review

### 3.3 冲突解决

1. PR 评论中基于文档达成共识
2. 评论无法解决 → 视频会议沟通
3. 仍无法解决 → 升级 Tech Lead
4. **绝对不要让 PR 无限挂起**

---

## 四、Go 特有 Review 关注点

| 关注点 | 说明 | 参考资料 |
|--------|------|---------|
| interface 定义位置 | 消费者侧定义，不在实现侧 | [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments#interfaces) |
| context 传递 | 第一个参数，不放入 struct | [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments#contexts) |
| error 包装 | 使用 `%w` 保留错误链 | [Go Blog](https://go.dev/blog/go1.13-errors) |
| goroutine 生命周期 | 启动必须明确退出策略 | [Uber Guide](https://github.com/uber-go/guide/blob/master/style.md) |
| channel 方向 | 尽量使用方向标注 `chan<-` / `<-chan` | [Effective Go](https://go.dev/doc/effective_go) |
| slice 边界拷贝 | 函数修改传入 slice 的需注意 | [Uber Guide](https://github.com/uber-go/guide/blob/master/style.md) |
| 包命名 | 避免 util/common/misc | [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments#package-names) |
| 导出注释 | 以名称开头，完整句子 | [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments) |

---

## 五、常见 Review 陷阱

| 陷阱 | 规避方法 |
|------|---------|
| 走马观花 | 专门留时间，保持 PR 小 |
| 只盯语法 | 优先关注功能和设计，格式交给 gofmt |
| 吹毛求疵 | 区分 "Nit:" 和必须修改项 |
| 无建设性反馈 | 提供具体改进建议 |
| 无视规范 | 用 golangci-lint 自动化 |
| 用 Java 思维写 Go | 关注 Go 惯用写法（error 而非 exception） |

---

## 六、Review 工具链

| 工具 | 用途 |
|------|------|
| GitHub PR | 代码审查平台 |
| golangci-lint | 综合静态分析 |
| go vet | 编译器级别检查 |
| go test -race | 竞态检测 |
| gocover | 测试覆盖率 |
| SonarQube | 持续代码质量检查 |
| staticcheck | 高级静态分析 |

> 核心参考来源：
> - [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments) (A — Go 官方)
> - [Google Engineering Practices](https://google.github.io/eng-practices/review/) (A — Google)
> - [Go Concurrency Code Review Checklist](https://github.com/code-review-checklists/go-concurrency) (B)
> - [Best Practices for Go Code Review](https://kodus.io/en/golang-code-review-practices/) (B)
