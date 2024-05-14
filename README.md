<!-- MDOC !-->
# LibWechat

This SDK provides an Elixir interface to interact with Wechat's APIs.

Head to the [API reference](https://hexdocs.pm/lib_wechat/LibWechat.html) for usage details.

## Installation

Add the dependency to your `mix.exs` file:

```elixir
def deps do
  [
    {:lib_wechat, "~> 0.3"}
  ]
end
```

## Usage

1. Create a new instance using `LibWechat`.

```elixir
defmodule MyApp do
  use LibWechat, otp_app: :my_app
end
```

2. Configure your app.

```elixir
config :my_app, MyApp
  appid: "your appid",
  secret: "your secret" 
```
3. Add your app to supervisor tree.
```Elixir
children = [
  MyApp
]

Supervisor.init(children, strategy: :one_for_one)
```
4. Start your journey!

```elixir
# Get access token
MyApp.get_access_token()

# Get miniapp session with code
MyApp.jscode_to_session("jscode")

# Get unlimited miniapp wxacode
MyApp.get_unlimited_wxacode(token,
    %{"scene" => "foo=bar",
      "page" => "pages/index/index",
      "width" => 430,
      "auto_color" => false,
      "line_color" => %{"r" => 0, "g" => 0, "b" => 0},
      "is_hyaline" => false
    })

#.... see more api in lib_wechat.ex
```

## Supportted APIs

- [x] get_access_token
- [x] jscode_to_session
- [x] get_unlimited_wxacode
- [x] get_urllink
- [x] generate_scheme
- [x] subscribe_send
- [x] uniform_send
- [x] get_phone_number
- [x] msg_sec_check

## License
This project is licensed under the MIT License - see the LICENSE file for details