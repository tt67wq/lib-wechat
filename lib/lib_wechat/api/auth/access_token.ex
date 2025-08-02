defmodule LibWechat.API.Auth.AccessToken do
  @moduledoc """
  AccessToken 管理模块，负责获取和管理微信 API 的 access_token。

  微信 API 的大部分接口都需要使用 access_token 作为调用凭证，开发者需要先获取 access_token，
  才能调用其他 API 接口。

  详情参考：https://developers.weixin.qq.com/doc/offiaccount/Basic_Information/Get_access_token.html
  """

  alias LibWechat.Internal.RequestBuilder
  alias LibWechat.Typespecs

  @doc """
  获取小程序/公众号全局唯一后台接口调用凭据（access_token）。

  调用绝大多数后台接口时都需使用 access_token，开发者需要进行妥善保存，注意定期刷新。

  ## 参数
    * `name` - 应用实例名称

  ## 返回值
    * `{:ok, %{"access_token" => token, "expires_in" => expires}}` - 获取成功
    * `{:error, error}` - 获取失败

  ## 示例
      iex> LibWechat.API.Auth.AccessToken.get(MyApp)
      {:ok, %{"access_token" => "xxx", "expires_in" => 7200}}
  """
  @spec get(module()) :: {:ok, Typespecs.dict()} | {:error, LibWechat.Error.t()}
  def get(name) do
    config = LibWechat.Internal.Config.get(name)

    params = %{
      "appid" => config[:appid],
      "secret" => config[:secret],
      "grant_type" => "client_credential"
    }

    config
    |> RequestBuilder.do_request(:get, "/cgi-bin/token", params, "")
    |> RequestBuilder.handle_json_response()
  end

  @doc """
  登录凭证校验，获取用户唯一标识 openid 和 session_key。

  通过 wx.login 接口获得临时登录凭证 code 后传到开发者服务器调用此接口完成登录流程。

  ## 参数
    * `name` - 应用实例名称
    * `code` - 临时登录凭证

  ## 返回值
    * `{:ok, %{"openid" => openid, "session_key" => session_key}}` - 获取成功
    * `{:error, error}` - 获取失败

  ## 示例
      iex> LibWechat.API.Auth.AccessToken.code2session(MyApp, "code")
      {:ok, %{"openid" => "xxx", "session_key" => "yyy"}}

  详情参考：https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/login/auth.code2Session.html
  """
  @spec code2session(module(), binary()) :: {:ok, Typespecs.dict()} | {:error, LibWechat.Error.t()}
  def code2session(name, code) do
    config = LibWechat.Internal.Config.get(name)

    params = %{
      "appid" => config[:appid],
      "secret" => config[:secret],
      "js_code" => code,
      "grant_type" => "authorization_code"
    }

    config
    |> RequestBuilder.do_request(:get, "/sns/jscode2session", params, "")
    |> RequestBuilder.handle_json_response()
  end
end
