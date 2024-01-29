<!-- MDOC !-->
# LibWechat

This SDK provides an Elixir interface to interact with Wechat's APIs.

Head to the [API reference](https://hexdocs.pm/lib_wechat/LibWechat.html) for usage details.

## Installation

Add the dependency to your `mix.exs` file:

```elixir
def deps do
  [
    {:lib_wechat, "~> 0.2"}
  ]
end
```

## Usage

1. Create a new instance of `LibWechat` with your appid and secret.

```elixir
wechat =
  LibWechat.new(
    appid: "Your APP ID",
    secret: "Your APP SECRET"
  )
```

2. Add LibWechat to your supervision tree.

```elixir
children = [
  {LibWechat, wechat: wechat}
]

Supervisor.init(children, strategy: :one_for_one)
```

3. Call the API you want to use.

```elixir
# Get access token
LibWechat.get_access_token(wechat)

# Get miniapp session with code
LibWechat.jscode_to_session(wechat, "jscode")

# Get unlimited miniapp wxacode
LibWechat.get_unlimited_wxacode(wechat, token,
    %{"scene" => "foo=bar",
      "page" => "pages/index/index",
      "width" => 430,
      "auto_color" => false,
      "line_color" => %{"r" => 0, "g" => 0, "b" => 0},
      "is_hyaline" => false
    })

#.... see more api in lib_wechat.ex
```


## License
This project is licensed under the MIT License - see the LICENSE file for details