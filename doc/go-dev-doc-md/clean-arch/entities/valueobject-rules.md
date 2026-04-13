# valueobject 包开发规则

> 所属模式：Clean Architecture
> 所属层：Enterprise Business Rules（最内层）
> 包路径：`internal/domain/valueobject`

---

## 1. 创建规则

- 值对象是不可变的，通过值比较而非标识
- 用于描述实体的属性（金额、地址、时间范围等）

## 2. 文件命名规则

值对象名小写，如 `money.go`, `address.go`。

## 3. 代码质量规则

### 【强制】
- 不可变（创建后不可修改）
- 值相等性比较（实现相等判断）
- 零外部依赖

### 【禁止】
- 可变状态
- 依赖外部包

### 【推荐】
- 使用 `type` 别名或小 struct
- 提供工厂函数进行验证

## 4. 代码模板

```go
package valueobject

import (
    "errors"
    "fmt"
)

// Money 金额值对象（不可变）
type Money struct {
    amount   int64 // 使用整数存储，单位：分
    currency string
}

var ErrInvalidMoney = errors.New("money amount cannot be negative")

func NewMoney(amount int64, currency string) (Money, error) {
    if amount < 0 {
        return Money{}, ErrInvalidMoney
    }
    return Money{amount: amount, currency: currency}, nil
}

func (m Money) Amount() int64 {
    return m.amount
}

func (m Money) Currency() string {
    return m.currency
}

func (m Money) Add(other Money) Money {
    return Money{
        amount:   m.amount + other.amount,
        currency: m.currency,
    }
}

func (m Money) Equals(other Money) bool {
    return m.amount == other.amount && m.currency == other.currency
}

func (m Money) String() string {
    return fmt.Sprintf("%d %s", m.amount, m.currency)
}
```
