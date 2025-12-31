# Project Context

## Purpose
LibWechat 是一个用于与微信 API 交互的 Elixir 库，提供小程序、公众号等微信平台的功能接口。

主要功能：
- 认证管理：自动获取和管理 access_token、小程序登录
- 小程序码生成：不限量小程序码、URL Link、Scheme 码
- 消息推送：订阅消息发送
- 用户信息：获取用户手机号
- 安全检查：文本内容安全检测

## Tech Stack
- **语言**: Elixir (~> 1.16)
- **HTTP 客户端**: Finch (~> 0.20)
- **JSON 解析**: Jason (~> 1.4)
- **配置验证**: NimbleOptions (~> 1.1)
- **代码格式化**: Elixir 标准格式 + Styler (~> 0.11)
- **静态检查**: Credo (~> 1.7)
- **类型检查**: Dialyxir (~> 1.4)
- **文档生成**: ExDoc (~> 0.38)

## Project Conventions

### Code Style
- 使用 `mix format` 进行代码格式化（已配置 Styler 插件）
- 遵循 Elixir 官方代码风格指南
- 命名约定：
  - 模块名使用 PascalCase（如 `LibWechat.Core`）
  - 函数名使用 snake_case
  - 私有函数以 `_` 开头（如 `_fetch_token`）
- 错误处理统一返回 `{:ok, result}` 或 `{:error, %LibWechat.Error{}}`

### Architecture Patterns
- **模块化架构**：核心功能在 `LibWechat.Core`，配置在 `LibWechat.Model.Config`
- **Supervisor 模式**：使用动态Supervisor管理 Finch 连接池
- **委托模式**：API 调用通过 `delegate/2` 委托给 `LibWechat.Core`
- **类型规范**：所有公共函数必须有完整的 `@spec` 类型定义

### Testing Strategy
- 使用 ExUnit 进行单元测试
- 测试文件位于 `test/` 目录
- 测试需要配置微信测试账号（通过 `.env` 文件）
- 运行测试：`mix test`
- 运行静态检查：`mix lint`（包含 credo + dialyxir）

### Git Workflow
- 主分支：`master`
- 功能分支命名：`feature/xxx`
- 提交信息使用中文或英文描述变更内容

## Domain Context
- 微信小程序/公众号 API 的封装库
- 微信 API 基础地址：`api.weixin.qq.com`
- Access Token 需要全局缓存管理（7200秒过期）
- 所有 API 响应遵循微信标准格式（包含 `errcode` 和 `errmsg`）

## Important Constraints
- Elixir 版本要求 >= 1.16
- 必须在 OTP 应用 supervision tree 中启动
- 依赖 Finch HTTP 客户端，不支持其他 HTTP 库

## External Dependencies
- **微信 API 服务器**: `api.weixin.qq.com` - 微信小程序/公众号 API 端点
