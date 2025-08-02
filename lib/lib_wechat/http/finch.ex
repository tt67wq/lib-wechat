defmodule LibWechat.Http.Finch do
  @moduledoc """
  Finch HTTP 客户端实现。

  此模块实现了 LibWechat.Http 协议，使用 Finch 作为底层 HTTP 客户端。
  Finch 是一个高性能的 HTTP 客户端，适合用于高并发场景。
  """

  alias LibWechat.Typespecs

  @typedoc """
  Finch HTTP 客户端配置。

  ## 字段
    * `finch_name` - Finch 实例的名称
  """
  @type t :: %__MODULE__{
          finch_name: atom()
        }
  defstruct [:finch_name]
end

defimpl LibWechat.Http, for: LibWechat.Http.Finch do
  @moduledoc """
  Finch HTTP 客户端的 LibWechat.Http 协议实现。

  此实现使用 Finch 作为底层 HTTP 客户端，处理 LibWechat 的 HTTP 请求。
  """

  alias LibWechat.Error
  alias LibWechat.Model.Http
  alias LibWechat.Typespecs

  @spec opts(Typespecs.opts() | nil) :: Typespecs.opts()
  defp opts(nil), do: [receive_timeout: 5000]
  defp opts(options), do: Keyword.put_new(options, :receive_timeout, 5000)

  @doc """
  执行 HTTP 请求。

  ## 参数
    * `finch` - Finch 实例
    * `req` - HTTP 请求

  ## 返回值
    * `{:ok, %Http.Response{}}` - 请求成功
    * `{:error, error}` - 请求失败
  """
  @spec do_request(LibWechat.Http.Finch.t(), Http.Request.t()) ::
          {:ok, Http.Response.t()} | {:error, LibWechat.Error.t()}
  def do_request(%LibWechat.Http.Finch{finch_name: finch_name}, req) do
    opts = opts(req.opts)

    finch_req =
      Finch.build(
        req.method,
        Http.Request.url(req),
        req.headers,
        req.body,
        opts
      )

    finch_req
    |> Finch.request(finch_name)
    |> case do
      {:ok, %Finch.Response{status: status, body: body, headers: headers}}
      when status in 200..299 ->
        {:ok, %Http.Response{status_code: status, body: body, headers: headers}}

      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, Error.new("bad response", %{status: status, body: body})}

      {:error, exception} ->
        {:error, Error.new("bad response", exception)}
    end
  end
end
