# LibWechat

一个用于微信 API 的 Elixir 库，提供小程序、公众号等微信平台的功能接口。

## 特性

- 🔐 **认证管理**: 自动获取和管理 access_token
- 📱 **小程序支持**: 小程序码、URL Link、Scheme 码生成
- 📨 **消息推送**: 订阅消息发送
- 📞 **手机号获取**: 小程序用户手机号获取
- 🔒 **安全检查**: 文本内容安全检测
- 🚀 **高性能**: 基于 Finch HTTP 客户端，支持连接池
- 🛡️ **类型安全**: 完整的类型规范和错误处理

## 安装

### 1. 添加依赖

在 `mix.exs` 文件中添加 `lib_wechat` 到依赖列表：

```elixir
def deps do
  [
    {:lib_wechat, "~> 0.4.0"}
  ]
end
```

### 2. 安装依赖

```bash
mix deps.get
```

### 3. 配置

在你的应用配置文件中（如 `config/config.exs`）添加微信应用的配置：

```elixir
config :my_app, MyApp.Wechat,
  appid: "your_app_id",
  secret: "your_app_secret",
```

### 4. 启动应用
在你的模块中使用
```elixir
defmodule MyApp.Wechat do
  use LibWechat, otp_app: :my_app
end
```
在你的应用监督树中添加Wechat：

```elixir
# 在你的 application.ex 中
def start(_type, _args) do
  children = [
    # 其他子进程...
    MyApp.Wechat
  ]

  opts = [strategy: :one_for_one, name: MyApp.Supervisor]
  Supervisor.start_link(children, opts)
end
```


### 获取 Access Token

```elixir
# 获取 access_token
case MyApp.Wechat.get_access_token() do
  {:ok, %{"access_token" => token, "expires_in" => expires}} ->
    IO.puts("Token: #{token}, Expires in: #{expires}")
  {:error, reason} ->
    IO.puts("获取失败: #{inspect(reason)}")
end
```

### 小程序登录

```elixir
# 使用 code 获取 session
case MyApp.Wechat.jscode_to_session("user_js_code") do
  {:ok, %{"openid" => openid, "session_key" => session_key}} ->
    IO.puts("OpenID: #{openid}")
  {:error, reason} ->
    IO.puts("登录失败: #{inspect(reason)}")
end
```

### 生成小程序码

```elixir
# 获取不限量小程序码
payload = %{
  "scene" => "foo=bar",
  "page" => "pages/index/index",
  "width" => 430,
  "auto_color" => false,
  "line_color" => %{"r" => 0, "g" => 0, "b" => 0},
  "is_hyaline" => false
}

case MyApp.Wechat.get_unlimited_wxacode(token, payload) do
  {:ok, binary_data} ->
    # binary_data 是图片的二进制数据
    File.write!("qrcode.png", binary_data)
  {:error, reason} ->
    IO.puts("生成小程序码失败: #{inspect(reason)}")
end
```

### 生成 URL Link

```elixir
# 获取小程序 URL Link
payload = %{
  "path" => "pages/index/index",
  "query" => "foo=bar",
  "is_expire" => false,
  "expire_type" => 0,
  "expire_time" => 0
}

case MyApp.Wechat.get_urllink(token, payload) do
  {:ok, %{"url_link" => url_link}} ->
    IO.puts("URL Link: #{url_link}")
  {:error, reason} ->
    IO.puts("生成 URL Link 失败: #{inspect(reason)}")
end
```

### 生成 Scheme 码

```elixir
# 获取小程序 scheme 码
payload = %{
  "jump_wxa" => %{
    "path" => "pages/index/index",
    "query" => "foo=bar"
  },
  "is_expire" => false,
  "expire_type" => 0,
  "expire_time" => 0
}

case MyApp.Wechat.generate_scheme(token, payload) do
  {:ok, %{"openlink" => openlink}} ->
    IO.puts("Scheme: #{openlink}")
  {:error, reason} ->
    IO.puts("生成 Scheme 失败: #{inspect(reason)}")
end
```

### 发送订阅消息

```elixir
# 发送订阅消息
payload = %{
  "touser" => "USER_OPENID",
  "template_id" => "TEMPLATE_ID",
  "page" => "index",
  "miniprogram_state" => "developer",
  "lang" => "zh_CN",
  "data" => %{
    "number01" => %{"value" => "339208499"},
    "date01" => %{"value" => "2015年01月05日"},
    "site01" => %{"value" => "TIT创意园"},
    "site02" => %{"value" => "广州市新港中路397号"}
  }
}

case MyApp.Wechat.subscribe_send(token, payload) do
  {:ok, %{"msgid" => msgid}} ->
    IO.puts("消息发送成功，ID: #{msgid}")
  {:error, reason} ->
    IO.puts("消息发送失败: #{inspect(reason)}")
end
```

### 获取用户手机号

```elixir
# 获取用户手机号
case MyApp.Wechat.get_phone_number(token, "phone_code") do
  {:ok, %{"phone_info" => phone_info}} ->
    IO.puts("手机号: #{phone_info["phoneNumber"]}")
  {:error, reason} ->
    IO.puts("获取手机号失败: #{inspect(reason)}")
end
```

### 内容安全检查

```elixir
# 文本内容安全检查
payload = %{
  "openid" => "USER_OPENID",
  "scene" => 1,
  "version" => 2,
  "content" => "要检查的文本内容"
}

case MyApp.Wechat.msg_sec_check(token, payload) do
  {:ok, result} ->
    case result["result"]["suggest"] do
      "pass" -> IO.puts("内容安全")
      "risky" -> IO.puts("内容存在风险")
      _ -> IO.puts("需要人工审核")
    end
  {:error, reason} ->
    IO.puts("安全检查失败: #{inspect(reason)}")
end
```

## 配置选项

| 选项 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `appid` | `string` | 是 | - | 微信应用 ID |
| `secret` | `string` | 是 | - | 微信应用密钥 |
| `service_host` | `string` | 否 | `"api.weixin.qq.com"` | 微信 API 服务器地址 |
| `debug` | `boolean` | 否 | `false` | 开启调试模式，打印 HTTP 请求日志 |

| 选项 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `appid` | `string` | 是 | - | 微信应用 ID |
| `secret` | `string` | 是 | - | 微信应用密钥 |
| `service_host` | `string` | 否 | `"api.weixin.qq.com"` | 微信 API 服务器地址 |

## 错误处理

所有 API 调用都返回 `{:ok, result}` 或 `{:error, error}` 格式的结果：

```elixir
case MyApp.Wechat.some_api_call(params) do
  {:ok, result} ->
    # 处理成功结果
    IO.puts("成功: #{inspect(result)}")
  {:error, %LibWechat.Error{reason: reason, message: message}} ->
    # 处理错误
    IO.puts("错误: #{message} (#{reason})")
end
```

## 开发

### 环境设置

```bash
# 克隆项目
git clone https://github.com/tt67wq/lib-wechat.git
cd lib-wechat

# 安装依赖
mix setup

# 运行测试
mix test

# 代码格式化
mix fmt

# 静态检查
mix lint
```

### 测试

测试需要配置微信应用的测试账号：

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，填入测试账号信息
export TEST_APP_ID="your_test_app_id"
export TEST_APP_SECRET="your_test_app_secret"
```

然后运行测试：

```bash
mix test
```

### 贡献

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 相关链接

- [微信官方文档](https://developers.weixin.qq.com/miniprogram/dev/api-backend/)
- [GitHub 仓库](https://github.com/tt67wq/lib-wechat)
- [Hex 包](https://hex.pm/packages/lib_wechat)

## 更新日志

### v0.4.0
- 重构为模块化架构
- 添加完整的类型规范
- 改进错误处理机制
- 支持 Finch HTTP 客户端

### v0.3.0
- 添加小程序码生成功能
- 添加 URL Link 和 Scheme 码生成
- 添加订阅消息发送功能

### v0.2.0
- 添加用户手机号获取功能
- 添加内容安全检查功能
- 改进配置管理

### v0.1.0
- 初始版本
- 基础认证功能
- Access Token 管理
