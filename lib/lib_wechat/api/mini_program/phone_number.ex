defmodule LibWechat.API.MiniProgram.PhoneNumber do
  @moduledoc """
  小程序获取手机号相关 API 模块。

  通过此模块可以获取微信用户绑定的手机号，需要先调用接口获取手机号获取凭证，然后通过凭证换取用户手机号。
  """

  alias LibWechat.Internal.Config
  alias LibWechat.Internal.RequestBuilder
  alias LibWechat.Typespecs

  @doc """
  获取用户手机号。

  小程序通过 wx.login 获取 临时登录凭证 code ，并通过调用接口（如 auth.code2Session）换取 用户唯一标识 OpenID 和 会话密钥 session_key。
  接着通过调用 getPhoneNumber 获取手机号获取凭证，然后使用该凭证调用此接口获取用户绑定的手机号。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `code` - 手机号获取凭证

  ## 返回值
    * `{:ok, map()}` - 获取成功，返回手机号信息
    * `{:error, error}` - 获取失败

  ## 示例
      iex> LibWechat.API.MiniProgram.PhoneNumber.get(MyApp, token, code)
      {:ok,
        %{
          "errcode" => 0,
          "errmsg" => "ok",
          "phone_info" => %{
            "phoneNumber" => "xxxxxx",
            "purePhoneNumber" => "xxxxxx",
            "countryCode" => 86,
            "watermark" => %{
              "timestamp" => 1637744274,
              "appid" => "xxxx"
            }
          }
        }
      }

  详情参考：https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/phonenumber/phonenumber.getPhoneNumber.html
  """
  @spec get(module(), binary(), binary()) ::
          {:ok, Typespecs.dict()} | {:error, LibWechat.Error.t()}
  def get(name, token, code) do
    config = Config.get(name)
    payload = %{"code" => code}

    config
    |> RequestBuilder.post_with_token("/wxa/business/getuserphonenumber", token, payload)
    |> RequestBuilder.handle_json_response()
  end
end
