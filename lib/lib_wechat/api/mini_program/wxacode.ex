defmodule LibWechat.API.MiniProgram.WxaCode do
  @moduledoc """
  小程序码相关 API 模块，用于生成和管理小程序码。

  小程序码可以通过微信扫描打开小程序，提供更丰富的线下场景应用。
  此模块封装了获取小程序码的相关接口。
  """

  alias LibWechat.Internal.Config
  alias LibWechat.Internal.RequestBuilder
  alias LibWechat.Typespecs

  @doc """
  获取小程序码，适用于需要的码数量极多的业务场景。

  通过该接口生成的小程序码，永久有效，数量暂无限制。
  用户扫描该码进入小程序后，开发者可获取到扫码的场景值，用于业务逻辑处理。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `payload` - 请求参数，包括：
      * `scene` - 场景值，最大32个可见字符
      * `page` - 跳转页面路径
      * `width` - 二维码宽度（单位：px）
      * `auto_color` - 是否自动配置线条颜色
      * `line_color` - 线条颜色（RGB值）
      * `is_hyaline` - 是否透明底色

  ## 返回值
    * `{:ok, binary()}` - 获取成功，返回图片二进制数据
    * `{:error, error}` - 获取失败

  ## 示例
      iex> LibWechat.API.MiniProgram.WxaCode.get_unlimited(MyApp, token, %{
      ...>   "scene" => "foo=bar",
      ...>   "page" => "pages/index/index",
      ...>   "width" => 430,
      ...>   "auto_color" => false,
      ...>   "line_color" => %{"r" => 0, "g" => 0, "b" => 0},
      ...>   "is_hyaline" => false
      ...> })
      {:ok, <<255, 216, ...>>}

  详情参考：https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/qr-code/wxacode.getUnlimited.html
  """
  @spec get_unlimited(module(), binary(), Typespecs.dict()) ::
          {:ok, binary()} | {:error, LibWechat.Error.t()}
  def get_unlimited(name, token, payload) do
    config = Config.get(name)

    config
    |> RequestBuilder.post_with_token("/wxa/getwxacodeunlimit", token, payload)
    |> RequestBuilder.handle_binary_response()
  end

  @doc """
  获取小程序 URL Link，适用于短信、邮件、网页、微信内等拉起小程序的业务场景。

  通过该接口，可以获取一个小程序的URL Link，适用于短信、邮件、网页、微信内等拉起小程序的业务场景。
  在微信内或外部浏览器中访问该链接时，可打开指定小程序。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `payload` - 请求参数，包括：
      * `path` - 通过URL Link进入的页面路径
      * `query` - 通过URL Link进入小程序时的query
      * `is_expire` - 生成的URL Link是否有效期
      * `expire_type` - 有效期类型
      * `expire_time` - 到期时间

  ## 返回值
    * `{:ok, map()}` - 获取成功，返回URL Link信息
    * `{:error, error}` - 获取失败

  ## 示例
      iex> LibWechat.API.MiniProgram.WxaCode.get_urllink(MyApp, token, %{
      ...>   "path" => "pages/index/index",
      ...>   "query" => "foo=bar",
      ...>   "is_expire" => false,
      ...>   "expire_type" => 0,
      ...>   "expire_time" => 0
      ...> })
      {:ok, %{
      ...>   "errcode" => 0,
      ...>   "errmsg" => "ok",
      ...>   "url_link" => "https://wxaurl.cn/bz2LB4RMDVqq"
      ...> }}

  详情参考：https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/url-link/urllink.generate.html
  """
  @spec get_urllink(module(), binary(), Typespecs.dict()) ::
          {:ok, Typespecs.dict()} | {:error, LibWechat.Error.t()}
  def get_urllink(name, token, payload) do
    config = Config.get(name)

    config
    |> RequestBuilder.post_with_token("/wxa/generate_urllink", token, payload)
    |> RequestBuilder.handle_json_response()
  end

  @doc """
  获取小程序 scheme 码，适用于短信、邮件、外部网页等拉起小程序的业务场景。

  通过该接口，开发者可以获取小程序scheme码，适用于微信外部浏览器打开小程序的业务场景。
  通过scheme码，用户可以快速打开小程序，更便捷地获取小程序的服务。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `payload` - 请求参数，包括：
      * `jump_wxa` - 跳转到的目标小程序信息
      * `is_expire` - 生成的scheme码是否有效期
      * `expire_type` - 有效期类型
      * `expire_time` - 到期时间

  ## 返回值
    * `{:ok, map()}` - 获取成功，返回scheme信息
    * `{:error, error}` - 获取失败

  ## 示例
      iex> LibWechat.API.MiniProgram.WxaCode.generate_scheme(MyApp, token, %{
      ...>   "jump_wxa" => %{
      ...>     "path" => "pages/index/index",
      ...>     "query" => "foo=bar"
      ...>   },
      ...>   "is_expire" => false,
      ...>   "expire_type" => 0,
      ...>   "expire_time" => 0
      ...> })
      {:ok, %{
      ...>   "errcode" => 0,
      ...>   "errmsg" => "ok",
      ...>   "openlink" => "weixin://dl/business/?t=Akeatr890b"
      ...> }}

  详情参考：https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/url-scheme/urlscheme.generate.html
  """
  @spec generate_scheme(module(), binary(), Typespecs.dict()) ::
          {:ok, Typespecs.dict()} | {:error, LibWechat.Error.t()}
  def generate_scheme(name, token, payload) do
    config = Config.get(name)

    config
    |> RequestBuilder.post_with_token("/wxa/generatescheme", token, payload)
    |> RequestBuilder.handle_json_response()
  end
end
