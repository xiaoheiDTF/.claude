# dto 包开发规则（六层模式）

> 与三层模式 dto-vo-rules.md 完全一致。
> 六层模式下额外注意：
> - Service ↔ Manager 之间也使用 DTO 传参
> - Manager 可直接操作 DO，但返回给 Service 时封装为 DTO
