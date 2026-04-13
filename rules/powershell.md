---
paths:
  - "**/*.ps1"
  - "**/*.psm1"
  - "**/*.psd1"
---

# PowerShell 编码规范

> 综合 PowerShell Best Practices / The PoshCode Book / PowerShell团队指南 / PSScriptAnalyzer

## 命名规范

- 函数/命令：PascalCase（`Get-UserInfo`, `New-UserService`）
- 变量：camelCase 或 PascalCase（`$userName`, `$ItemCount`）
- 常量：UPPER_SNAKE_CASE（`$MAX_RETRY_COUNT`）
- 模块：PascalCase（`UserService`）
- 文件名：PascalCase（`UserService.psm1`, `UserService.psd1`）
- 脚本文件：kebab-case 或 PascalCase（`deploy-app.ps1`）
- 使用标准动词（`Get-`, `Set-`, `New-`, `Remove-`, `Invoke-`, `Start-`, `Stop-`）
- 参数名：PascalCase（`-UserName`, `-FilePath`）

## 代码格式

- 缩进：4 空格
- 行宽：建议 120 字符
- 使用 `PSScriptAnalyzer` 静态分析
- 左花括号不换行
- 使用 `#region` / `#endregion` 组织代码块

## 核心规范

- 使用 `cmdletbinding()` 声明高级函数
- 使用 `[Parameter()]` 属性标注参数
- 支持 `ShouldProcess`（`-WhatIf`, `--Confirm`）用于破坏性操作
- 使用 `Write-Error` / `Write-Warning` / `Write-Verbose` 输出不同级别信息
- 避免使用 `Write-Host`（使用 `Write-Output` 或适当的 Write cmdlet）
- 使用 `try/catch/finally` 处理错误
- 使用 `-ErrorAction Stop` 将非终止错误转为终止错误
- 输出对象而非文本（管道友好）
- 使用 `PSCustomObject` 创建自定义对象

## 错误处理

- 使用 `try { ... } catch { ... } finally { ... }`
- 使用 `$ErrorActionPreference = 'Stop'`
- 检查 `$?` 判断上一步成功
- 使用 `throw` 抛出终止错误
- 使用 `Write-Error` 输出非终止错误

## 模块化

- 使用 `.psm1` 定义模块，`.psd1` 定义清单
- 使用 `Export-ModuleMember` 控制导出
- 使用 `RequiredModules` 声明依赖
- 使用 `FunctionsToExport` 显式导出函数

## 测试

- 框架：Pester
- 测试文件：`<Name>.Tests.ps1`
- 使用 `Describe` / `Context` / `It` 组织
- 使用 `BeforeAll` / `BeforeEach` 准备数据
- 使用 `Should` 断言（`$result | Should -Be $expected`）
