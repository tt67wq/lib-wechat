defmodule LibWechat.Internal.RequestBuilder do
  @moduledoc """
  请求构建器模块，负责统一处理微信 API 请求的构建。
  该模块处理请求头、请求参数、请求体等的准备工作，以便简化 API 模块的实现。
  """

  alias LibWechat.Model.Config
  alias LibWechat.Model.Http
  alias LibWechat.Typespecs

  require Logger

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

    request = %Http.Request{
      host: config[:service_host],
      method: method,
      path: api,
      headers: headers,
      body: body,
      params: params,
      opts: opts
    }

    if config[:debug] do
      log_request(request)
    end

    result = LibWechat.Http.do_request(config[:finch], request)

    if config[:debug] do
      log_response(result)
    end

    result
  end

  # 辅助函数：记录请求日志
  defp log_request(request) do
    Logger.debug("""
    [LibWechat] Request:
    	Method: #{request.method}
    	URL: #{build_url(request)}
    	Headers: #{inspect(request.headers)}
    	Body: #{truncate_body(request.body)}
    """)
  end

  # 辅助函数：记录响应日志
  defp log_response({:ok, response}) do
    Logger.debug("""
    [LibWechat] Response:
    	Status: #{response.status}
    	Headers: #{inspect(response.headers)}
    	Body: #{truncate_body(response.body)}
    """)
  end

  defp log_response({:error, reason}) do
    Logger.debug("""
    [LibWechat] Response Error:
    	Reason: #{inspect(reason)}
    """)
  end

  # 辅助函数：截断请求体
  defp truncate_body(""), do: "(empty)"
  defp truncate_body(nil), do: "(nil)"

  defp truncate_body(body) when is_binary(body) do
    if String.length(body) > 500 do
      String.slice(body, 0, 500) <> "... [truncated]"
    else
      body
    end
  end

  defp truncate_body(other), do: inspect(other)

  # 辅助函数：构建完整 URL（用于日志）
  defp build_url(request) do
    query_string = URI.encode_query(request.params)
    url = "#{request.host}#{request.path}"

    if query_string != "" do
      url <> "?" <> sanitize(query_string)
    else
      url
    end
  end

  # 辅助函数：脱敏敏感信息
  defp sanitize(text) when is_binary(text) do
    text
    |> String.replace("access_token=[^&]*", "access_token=***")
    |> String.replace("secret=[^&]*", "secret=***")
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
