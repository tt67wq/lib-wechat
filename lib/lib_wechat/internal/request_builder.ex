defmodule LibWechat.Internal.RequestBuilder do
  @moduledoc """
  请求构建器模块，负责统一处理微信 API 请求的构建。
  该模块处理请求头、请求参数、请求体等的准备工作，以便简化 API 模块的实现。
  """

  alias LibWechat.Model.Config
  alias LibWechat.Model.Http
  alias LibWechat.Typespecs

  @doc """
  执行 HTTP 请求。

  ## 参数
    * `config` - 配置信息
    * `method` - HTTP 方法 (:get, :post 等)
    * `api` - API 路径
    * `params` - URL 查询参数
    * `body` - 请求体
    * `opts` - 请求选项

  ## 返回值
    * `{:ok, %Http.Response{}}` - 请求成功
    * `{:error, error}` - 请求失败
  """
  @spec do_request(Config.t(), Typespecs.method(), binary(), Typespecs.params(), Typespecs.body(), Keyword.t()) ::
          {:ok, Http.Response.t()} | {:error, LibWechat.Error.t()}
  def do_request(config, method, api, params, body, opts \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]

    LibWechat.Http.do_request(config[:finch], %Http.Request{
      host: config[:service_host],
      method: method,
      path: api,
      headers: headers,
      body: body,
      params: params,
      opts: opts
    })
  end

  @doc """
  构建带有 access_token 的 GET 请求。

  ## 参数
    * `config` - 配置信息
    * `api` - API 路径
    * `token` - access_token
    * `params` - 额外的查询参数

  ## 返回值
    * `{:ok, %Http.Response{}}` - 请求成功
    * `{:error, error}` - 请求失败
  """
  @spec get_with_token(Config.t(), binary(), binary(), map()) ::
          {:ok, Http.Response.t()} | {:error, LibWechat.Error.t()}
  def get_with_token(config, api, token, params \\ %{}) do
    params_with_token = Map.put(params, "access_token", token)
    do_request(config, :get, api, params_with_token, "")
  end

  @doc """
  构建带有 access_token 的 POST 请求。

  ## 参数
    * `config` - 配置信息
    * `api` - API 路径
    * `token` - access_token
    * `payload` - POST 请求体（将被转换为 JSON）

  ## 返回值
    * `{:ok, %Http.Response{}}` - 请求成功
    * `{:error, error}` - 请求失败
  """
  @spec post_with_token(Config.t(), binary(), binary(), map()) ::
          {:ok, Http.Response.t()} | {:error, LibWechat.Error.t()}
  def post_with_token(config, api, token, payload) do
    case Jason.encode(payload) do
      {:ok, body} ->
        do_request(config, :post, api, %{"access_token" => token}, body)

      error ->
        error
    end
  end

  @doc """
  处理 JSON 响应体。

  ## 参数
    * `response` - HTTP 响应

  ## 返回值
    * `{:ok, map()}` - 解析成功
    * `{:error, error}` - 解析失败
  """
  @spec handle_json_response({:ok, Http.Response.t()} | {:error, any()}) ::
          {:ok, map()} | {:error, any()}
  def handle_json_response({:ok, %Http.Response{body: body}}) do
    Jason.decode(body)
  end

  def handle_json_response(error), do: error

  @doc """
  处理二进制响应体（如图片数据）。

  ## 参数
    * `response` - HTTP 响应

  ## 返回值
    * `{:ok, binary()}` - 处理成功
    * `{:error, error}` - 处理失败
  """
  @spec handle_binary_response({:ok, Http.Response.t()} | {:error, any()}) ::
          {:ok, binary()} | {:error, any()}
  def handle_binary_response({:ok, %Http.Response{body: body}}) do
    {:ok, body}
  end

  def handle_binary_response(error), do: error
end
