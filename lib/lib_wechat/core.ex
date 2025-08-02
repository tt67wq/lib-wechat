defmodule LibWechat.Core do
  @moduledoc """
  LibWechat 核心模块，提供对各 API 模块功能的访问。

  此模块作为 LibWechat 库的核心接口层，负责将调用委托给相应的具体 API 模块。
  为了保持向后兼容性，此模块提供了与原有调用方式相同的接口，但内部实现已重构为更模块化的结构。
  """

  alias LibWechat.API.Auth.AccessToken
  alias LibWechat.API.Message.Subscribe
  alias LibWechat.API.MiniProgram.PhoneNumber
  alias LibWechat.API.MiniProgram.Security
  alias LibWechat.API.MiniProgram.WxaCode
  alias LibWechat.Internal.Config
  alias LibWechat.Typespecs

  @type ok_t(m) :: {:ok, m}
  @type err_t :: {:error, LibWechat.Error.t()}

  @doc """
  启动 LibWechat 核心模块的 Agent 进程。

  ## 参数
    * `name` - 应用实例名称
    * `finch` - Finch HTTP 客户端实例
    * `config` - 配置信息

  ## 返回值
    * `{:ok, pid}` - 启动成功
    * `{:error, reason}` - 启动失败
  """
  def start_link({name, finch, config}) do
    Config.start_link({name, finch, config})
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc """
  获取应用实例的配置信息。

  ## 参数
    * `name` - 应用实例名称

  ## 返回值
    * `config` - 配置信息的关键字列表
  """
  def get(name) do
    Config.get(name)
  end

  @doc """
  获取 access_token。

  委托给 `LibWechat.API.Auth.AccessToken.get/1` 处理。

  ## 参数
    * `name` - 应用实例名称

  ## 返回值
    * `{:ok, %{"access_token" => token, "expires_in" => expires}}` - 获取成功
    * `{:error, error}` - 获取失败
  """
  @spec get_access_token(module()) :: {:ok, Typespecs.dict()} | err_t()
  def get_access_token(name) do
    AccessToken.get(name)
  end

  @doc """
  小程序登录凭证校验。

  委托给 `LibWechat.API.Auth.AccessToken.code2session/2` 处理。

  ## 参数
    * `name` - 应用实例名称
    * `code` - 小程序登录时获取的 code

  ## 返回值
    * `{:ok, %{"openid" => openid, "session_key" => session_key}}` - 获取成功
    * `{:error, error}` - 获取失败
  """
  @spec jscode_to_session(module(), binary()) :: {:ok, Typespecs.dict()} | err_t()
  def jscode_to_session(name, code) do
    AccessToken.code2session(name, code)
  end

  @doc """
  获取小程序码。

  委托给 `LibWechat.API.MiniProgram.WxaCode.get_unlimited/3` 处理。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `payload` - 请求参数

  ## 返回值
    * `{:ok, binary()}` - 获取成功，返回图片二进制数据
    * `{:error, error}` - 获取失败
  """
  @spec get_unlimited_wxacode(module(), binary(), Typespecs.dict()) :: {:ok, binary()} | err_t()
  def get_unlimited_wxacode(name, token, payload) do
    WxaCode.get_unlimited(name, token, payload)
  end

  @doc """
  获取小程序 URL Link。

  委托给 `LibWechat.API.MiniProgram.WxaCode.get_urllink/3` 处理。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `payload` - 请求参数

  ## 返回值
    * `{:ok, map()}` - 获取成功，返回 URL Link 信息
    * `{:error, error}` - 获取失败
  """
  @spec get_urllink(module(), binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
  def get_urllink(name, token, payload) do
    WxaCode.get_urllink(name, token, payload)
  end

  @doc """
  获取小程序 scheme 码。

  委托给 `LibWechat.API.MiniProgram.WxaCode.generate_scheme/3` 处理。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `payload` - 请求参数

  ## 返回值
    * `{:ok, map()}` - 获取成功，返回 scheme 信息
    * `{:error, error}` - 获取失败
  """
  @spec generate_scheme(module(), binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
  def generate_scheme(name, token, payload) do
    WxaCode.generate_scheme(name, token, payload)
  end

  @doc """
  发送订阅消息。

  委托给 `LibWechat.API.Message.Subscribe.send/3` 处理。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `payload` - 请求参数

  ## 返回值
    * `{:ok, map()}` - 发送成功，返回结果
    * `{:error, error}` - 发送失败
  """
  @spec subscribe_send(module(), binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
  def subscribe_send(name, token, payload) do
    Subscribe.send(name, token, payload)
  end

  @doc """
  下发统一消息。

  委托给 `LibWechat.API.Message.Subscribe.uniform_send/3` 处理。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `payload` - 请求参数

  ## 返回值
    * `{:ok, map()}` - 发送成功，返回结果
    * `{:error, error}` - 发送失败
  """
  @deprecated "This API has been unsupported. For more details, please view https://developers.weixin.qq.com/community/develop/doc/000ae8d6348af08e7030bc2546bc01?blockType=1"
  @spec uniform_send(module(), binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
  def uniform_send(name, token, body) do
    Subscribe.uniform_send(name, token, body)
  end

  @doc """
  获取用户手机号。

  委托给 `LibWechat.API.MiniProgram.PhoneNumber.get/3` 处理。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `code` - 手机号获取凭证

  ## 返回值
    * `{:ok, map()}` - 获取成功，返回手机号信息
    * `{:error, error}` - 获取失败
  """
  @spec get_phone_number(module(), binary(), binary()) :: {:ok, Typespecs.dict()} | err_t()
  def get_phone_number(name, token, code) do
    PhoneNumber.get(name, token, code)
  end

  @doc """
  检查文本是否含有违法违规内容。

  委托给 `LibWechat.API.MiniProgram.Security.msg_sec_check/3` 处理。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `payload` - 请求参数

  ## 返回值
    * `{:ok, map()}` - 检测成功，返回检测结果
    * `{:error, error}` - 检测失败
  """
  @spec msg_sec_check(module(), binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
  def msg_sec_check(name, token, payload) do
    Security.msg_sec_check(name, token, payload)
  end
end
