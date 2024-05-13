defmodule LibWechat.Model.Config do
  @moduledoc false

  @options_schema [
    service_host: [
      type: :string,
      default: "api.weixin.qq.com",
      doc: "服务地址"
    ],
    appid: [
      type: :string,
      required: true,
      doc: "第三方用户唯一凭证"
    ],
    secret: [
      type: :string,
      required: true,
      doc: "第三方用户唯一凭证密钥，即appsecret"
    ]
  ]

  @type t :: keyword(unquote(NimbleOptions.option_typespec(@options_schema)))

  def validate(config) do
    NimbleOptions.validate(config, @options_schema)
  end

  def validate!(config) do
    NimbleOptions.validate!(config, @options_schema)
  end
end
