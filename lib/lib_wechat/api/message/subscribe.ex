defmodule LibWechat.API.Message.Subscribe do
  @moduledoc """
  订阅消息相关 API 模块。

  小程序、公众号可以通过这些接口，实现向用户发送订阅消息的功能。
  用户在小程序内完成订阅授权后，开发者可以发送订阅消息给该用户。
  """

  alias LibWechat.Internal.Config
  alias LibWechat.Internal.RequestBuilder
  alias LibWechat.Typespecs

  @doc """
  发送订阅消息。

  通过该接口向用户发送订阅消息，用户需要先完成订阅授权。
  每个用户每个模板消息只能发送一次，重复发送会失败。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `payload` - 请求参数，包括：
      * `touser` - 接收者（用户）的 openid
      * `template_id` - 所需下发的订阅模板id
      * `page` - 点击模板卡片后的跳转页面
      * `data` - 模板内容，格式形如 { "key1": { "value": any }, "key2": { "value": any } }
      * `miniprogram_state` - 小程序跳转类型
      * `lang` - 进入小程序查看"的语言类型

  ## 返回值
    * `{:ok, map()}` - 发送成功，返回结果
    * `{:error, error}` - 发送失败

  ## 示例
      iex> LibWechat.API.Message.Subscribe.send(MyApp, token, %{
      ...>   "touser" => "OPENID",
      ...>   "template_id" => "TEMPLATE_ID",
      ...>   "page" => "index",
      ...>   "miniprogram_state" => "developer",
      ...>   "lang" => "zh_CN",
      ...>   "data" => %{
      ...>     "number01" => %{"value" => "339208499"},
      ...>     "date01" => %{"value" => "2015年01月05日"},
      ...>     "site01" => %{"value" => "TIT创意园"},
      ...>     "site02" => %{"value" => "广州市新港中路397号"}
      ...>   }
      ...> })
      {:ok, %{
      ...>   "errcode" => 0,
      ...>   "errmsg" => "ok",
      ...>   "msgid" => 294402298110051942
      ...> }}

  详情参考：https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.send.html
  """
  @spec send(module(), binary(), Typespecs.dict()) ::
          {:ok, Typespecs.dict()} | {:error, LibWechat.Error.t()}
  def send(name, token, payload) do
    config = Config.get(name)

    config
    |> RequestBuilder.post_with_token("/cgi-bin/message/subscribe/send", token, payload)
    |> RequestBuilder.handle_json_response()
  end

  @doc """
  下发统一消息（小程序模板消息+公众号模板消息）。

  该接口用于同时向用户发送小程序和公众号的模板消息，适用于同时拥有小程序和公众号的开发者。
  注意：此接口已被微信官方标记为不再支持。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `payload` - 请求参数，包括：
      * `touser` - 接收者（用户）的 openid
      * `weapp_template_msg` - 小程序模板消息相关的信息
      * `mp_template_msg` - 公众号模板消息相关的信息

  ## 返回值
    * `{:ok, map()}` - 发送成功，返回结果
    * `{:error, error}` - 发送失败

  ## 示例
      iex> LibWechat.API.Message.Subscribe.uniform_send(MyApp, token, %{
      ...>   "touser" => "OPENID",
      ...>   "weapp_template_msg" => %{
      ...>     "template_id" => "TEMPLATE_ID",
      ...>     "page" => "index",
      ...>     "form_id" => "FORMID",
      ...>     "data" => %{
      ...>       "keyword1" => %{"value" => "339208499"},
      ...>       "keyword2" => %{"value" => "2015年01月05日"}
      ...>     },
      ...>     "emphasis_keyword" => "keyword1.DATA"
      ...>   },
      ...>   "mp_template_msg" => %{
      ...>     "appid" => "APPID",
      ...>     "template_id" => "TEMPLATE_ID",
      ...>     "url" => "http://weixin.qq.com/download",
      ...>     "miniprogram" => %{
      ...>       "appid" => "xiaochengxuappid12345",
      ...>       "pagepath" => "index?foo=bar"
      ...>     },
      ...>     "data" => %{
      ...>       "first" => %{"value" => "恭喜你购买成功！", "color" => "#173177"},
      ...>       "keyword1" => %{"value" => "巧克力", "color" => "#173177"}
      ...>     }
      ...>   }
      ...> })
      {:ok, %{"errcode" => 0, "errmsg" => "ok"}}

  详情参考：https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/uniform-message/uniformMessage.send.html
  """
  @deprecated "This API has been unsupported. For more details, please view https://developers.weixin.qq.com/community/develop/doc/000ae8d6348af08e7030bc2546bc01?blockType=1"
  @spec uniform_send(module(), binary(), Typespecs.dict()) ::
          {:ok, Typespecs.dict()} | {:error, LibWechat.Error.t()}
  def uniform_send(name, token, payload) do
    config = Config.get(name)

    config
    |> RequestBuilder.post_with_token("/cgi-bin/message/wxopen/template/uniform_send", token, payload)
    |> RequestBuilder.handle_json_response()
  end
end
