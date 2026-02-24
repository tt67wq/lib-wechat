# AGENTS.md - LibWechat Development Guide

This file provides guidelines and commands for agents working on the LibWechat project.

---

## Project Overview

LibWechat is an Elixir library for interacting with WeChat APIs (mini programs, official accounts).
- **Elixir**: ~> 1.16
- **Key Dependencies**: Finch, Jason, NimbleOptions

---

## Build Commands

### Development Setup
```bash
# Install dependencies
mix deps.get

# Compile the project
mix compile
```

### Running Tests
```bash
# Run all tests
mix test

# Run a single test file
mix test test/lib_wechat_test.exs

# Run a specific test by name
mix test test/lib_wechat_test.exs:get_access_token

# Run tests with tags (e.g., skip slow tests)
mix test --exclude exec:true
```

### Code Quality
```bash
# Format code (uses Styler plugin)
mix format

# Run Dialyzer for type checking
mix dialyzer

# Run Credo for linting
mix credo

# Run all checks (format, lint, type check)
mix check
```

### Documentation
```bash
# Generate documentation
mix docs
```

---

## Code Style Guidelines

### General Conventions

- **Language**: Elixir (not Ruby-style)
- **Formatting**: Uses `mix format` with Styler plugin
- **Line Length**: 98 characters (default Elixir)
- **Documentation**: Use `@moduledoc` and `@doc` for public APIs

### Module Organization

```elixir
defmodule LibWechat.ModuleName do
  @moduledoc """
  Brief description of the module.
  Optional: more detailed explanation.
  """

  # Constants/config
  @some_constant "value"

  # Types
  @type t :: %__MODULE__{...}

  # Behavior callbacks
  @behaviour SomeBehaviour

  # Public API
  def public_function do
    # ...
  end

  # Private functions (marked with defp)
  defp private_function do
    # ...
  end
end
```

### Imports and Aliases

**Order** (as per Elixir convention):
1. `alias` - longest first
2. `import`
3. `require`

```elixir
alias LibWechat.API.Auth.AccessToken
alias LibWechat.Model.Http
alias LibWechat.Typespecs

require Logger
```

- Avoid wildcard imports (`import Foo, only: :functions`)
- Always use explicit imports when needed

### Types and Specs

- Define types using `@type` and `@spec`
- Use type specs for all public functions
- Define custom type for return values

```elixir
@type t :: %__MODULE__{
        field: String.t(),
        count: non_neg_integer()
      }

@spec my_function(t()) :: {:ok, map()} | {:error, LibWechat.Error.t()}
```

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Modules | PascalCase | `LibWechat.Core` |
| Functions | snake_case | `get_access_token` |
| Variables | snake_case | `user_data` |
| Types | PascalCase or snake_case | `t()`, `error_t()` |
| Constants | SCREAMING_SNAKE_CASE | `@MAX_RETRIES` |

### Structs

```elixir
defmodule LibWechat.Example do
  @type t :: %__MODULE__{
          required_field: String.t(),
          optional_field: integer() | nil
        }

  defstruct required_field: nil, optional_field: nil
end
```

### Error Handling

- Return `{:ok, result}` or `{:error, %LibWechat.Error{}}`
- Use `LibWechat.Error.new/2` for creating errors

```elixir
def my_function do
  case some_operation() do
    {:ok, result} ->
      {:ok, process(result)}

    {:error, reason} ->
      {:error, Error.new("operation failed", reason)}
  end
end
```

- **Never** use empty catch blocks
- **Never** silently swallow errors

### Protocols

Use protocols for extensible behavior:

```elixir
defimpl LibWechat.Http, for: LibWechat.Http.Finch do
  alias LibWechat.Model.Http

  @spec do_request(t(), Http.Request.t()) :: ...
  def do_request(client, request) do
    # Implementation
  end
end
```

### Testing

- Use ExUnit
- Follow naming: `test "describes the behavior"`
- Use `start_supervised!` for starting processes

```elixir
defmodule LibWechatTest do
  use ExUnit.Case

  alias LibWechat.Test.App

  setup do
    # Setup code
    :ok
  end

  test "some behavior" do
    assert {:ok, _} = App.some_function()
  end
end
```

### Strings vs Binaries

- Use `String.t()` for strings
- Use `binary()` for raw bytes
- Use `nil | binary()` when content may be missing

### HTTP Requests

Use the internal request builder:

```elixir
alias LibWechat.Internal.RequestBuilder

# GET with token
RequestBuilder.get_with_token(config, api_path, token, params)

# POST with token
RequestBuilder.post_with_token(config, api_path, token, payload)

# Handle responses
RequestBuilder.handle_json_response(response)
RequestBuilder.handle_binary_response(response)
```

### Dialyzer / Type Safety

- **Never** use type suppression: `as any`, `@ts-ignore`, `@ts-expect-error`
- Run `mix dialyzer` before submitting code
- Fix opaque type issues by using protocol implementations (e.g., `to_string/1` instead of `URI.to_string/1`)

---

## Project Structure

```
lib/
├── lib_wechat.ex              # Main module, use macro
├── lib_wechat/
│   ├── core.ex                # Core API delegation
│   ├── error.ex               # Error struct
│   ├── http_protocol.ex       # HTTP protocol definition
│   ├── supervisor.ex          # Supervisor
│   ├── typespecs.ex           # Shared types
│   ├── debug.ex               # Debug utilities
│   ├── api/
│   │   ├── auth/
│   │   │   └── access_token.ex
│   │   ├── message/
│   │   │   └── subscribe.ex
│   │   └── mini_program/
│   │       ├── phone_number.ex
│   │       ├── security.ex
│   │       └── wxacode.ex
│   ├── http/
│   │   └── finch.ex           # Finch HTTP implementation
│   ├── internal/
│   │   ├── config.ex          # Config management
│   │   └── request_builder.ex # Request building
│   └── model/
│       ├── config.ex          # Config model
│       └── http.ex            # HTTP models
```

---

## Common Tasks

### Adding a New API

1. Create module in `lib/lib_wechat/api/`
2. Use `RequestBuilder` for HTTP calls
3. Add function to `LibWechat.Core`
4. Add delegation in `LibWechat` macro
5. Add typespecs

### Configuration

Users configure via their app's config:

```elixir
config :my_app, MyApp.Wechat,
  appid: "your_app_id",
  secret: "your_app_secret",
  service_host: "api.weixin.qq.com"  # optional
```
