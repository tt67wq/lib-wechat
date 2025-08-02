defmodule LibWechat.Typespecs do
  @moduledoc """
  LibWechat 类型规范模块

  此模块定义了 LibWechat 库中使用的各种类型规范，用于提高代码的可读性和类型安全性。
  类型规范有助于开发者理解函数的输入和输出类型，也有助于静态分析工具（如 Dialyzer）检查代码中的类型错误。
  """

  # 基础类型
  @type name :: atom() | {:global, term()} | {:via, module(), term()}
  @type opts :: keyword()
  @type method :: :get | :post | :head | :patch | :delete | :options | :put
  @type headers :: [{String.t(), String.t()}]
  @type body :: iodata() | nil
  @type params :: %{String.t() => binary()} | nil
  @type http_status :: non_neg_integer()
  @type on_start ::
          {:ok, pid()}
          | :ignore
          | {:error, {:already_started, pid()} | term()}

  @type dict :: %{String.t() => any()}

  # 微信 API 相关类型
  @type access_token :: String.t()
  @type appid :: String.t()
  @type secret :: String.t()
  @type code :: String.t()
  @type openid :: String.t()
  @type session_key :: String.t()

  # 响应和错误处理类型
  @type api_response :: {:ok, dict()} | {:error, LibWechat.Error.t()}
  @type binary_response :: {:ok, binary()} | {:error, LibWechat.Error.t()}

  # 配置相关类型
  @type config :: keyword()
  @type service_host :: String.t()

  # 小程序相关类型
  @type wxa_payload :: dict()
  @type scene :: integer() | String.t()
  @type page :: String.t()
  @type path :: String.t()

  # 消息相关类型
  @type template_id :: String.t()
  @type message_payload :: dict()

  # 安全相关类型
  @type security_payload :: dict()

  # HTTP 客户端相关类型
  @type finch_instance :: module()
  @type http_client :: module()
  @type url :: String.t()
  @type query_params :: %{String.t() => String.t()} | keyword()
end
