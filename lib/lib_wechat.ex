defmodule LibWechat do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias LibWechat.Client

  @options_schema [
    name: [
      type: :atom,
      doc: "name of this process",
      default: :wechat
    ],
    client_module: [
      type: :atom,
      doc: "module that implements `LibWechat.Client` behavior",
      default: LibWechat.Client.Finch
    ],
    client: [
      type: :any,
      doc: "client instance",
      default: LibWechat.Client.Finch.new()
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

  # types
  @type t :: %__MODULE__{
          name: GenServer.name(),
          client_module: module(),
          client: Client.t(),
          appid: bitstring(),
          secret: bitstring()
        }
  @type options_t :: keyword(unquote(NimbleOptions.option_typespec(@options_schema)))
  @type json_t :: %{bitstring() => any()}
  @type ok_t(ret) :: {:ok, ret}
  @type err_t(err) :: {:error, err}

  @enforce_keys ~w(name client_module client appid secret)a

  defstruct @enforce_keys

  @doc """
  create an instance of LibWechat
  ## options
  #{NimbleOptions.docs(@options_schema)}
  """
  @spec new(options_t()) :: t()
  def new(opts \\ []) do
    opts =
      opts
      |> NimbleOptions.validate!(@options_schema)

    struct(__MODULE__, opts)
  end

  def child_spec(opts) do
    wechat = Keyword.fetch!(opts, :wechat)
    %{id: {__MODULE__, wechat.name}, start: {__MODULE__, :start_link, [opts]}}
  end

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    {wechat, _opts} = Keyword.pop!(opts, :wechat)
    wechat.client_module.start_link(client: wechat.client)
  end

  @doc """
  获取access_token
  https://developers.weixin.qq.com/doc/offiaccount/Basic_Information/Get_access_token.html


  ## Examples

      {:ok, %{"access_token"=>"xxx"}} = LibWechat.get_access_token(wechat)
  """
  @spec get_access_token(t()) :: ok_t(json_t()) | err_t(Jason.DecodeError.t())
  def get_access_token(wechat) do
    params = %{
      appid: wechat.appid,
      secret: wechat.secret,
      grant_type: "client_credential"
    }

    {:ok, body} = Client.do_request(wechat.client, :get, "/cgi-bin/token", nil, params)

    Jason.decode(body)
  end

  @doc """
  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/login/auth.code2Session.html
  """
  @spec jscode_to_session(t(), String.t()) :: ok_t(json_t()) | err_t(Jason.DecodeError.t())
  def jscode_to_session(wechat, code) do
    params = %{
      appid: wechat.appid,
      secret: wechat.secret,
      js_code: code,
      grant_type: "authorization_code"
    }

    {:ok, body} = Client.do_request(wechat.client, :get, "/sns/jscode2session", nil, params)

    Jason.decode(body)
  end

  @doc """
  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/qr-code/wxacode.getUnlimited.html

  ## Examples

      {:ok, <<255, 216, ...>>} = LibWechat.get_unlimited_wxacode(wechat, token,
        %{"scene" => "foo=bar",
          "page" => "pages/index/index",
          "width" => 430,
          "auto_color" => false,
          "line_color" => %{"r" => 0, "g" => 0, "b" => 0},
          "is_hyaline" => false
        }
      )
  """
  @spec get_unlimited_wxacode(t(), String.t(), json_t()) :: ok_t(binary()) | err_t(any())
  def get_unlimited_wxacode(wechat, token, body) do
    Client.do_request(wechat.client, :post, "/wxa/getwxacodeunlimit", body, %{
      "access_token" => token
    })
  end

  @doc """
  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/url-link/urllink.generate.html

  ## Examples

      {:ok, %{
        "errcode" => 0,
        "errmsg" => "ok",
        "url_link" => "https://wxaurl.cn/bz2LB4RMDVqq"
      }} = LibWechat.get_urllink(wechat, token,
        %{
          "path" => "pages/index/index",
          "query" => "foo=bar",
          "is_expire" => false,
          "expire_type" => 0,
          "expire_time" => 0
        }
      )
  """
  @spec get_urllink(t(), String.t(), json_t()) :: ok_t(json_t()) | err_t(Jason.DecodeError.t())
  def get_urllink(wechat, token, body) do
    {:ok, ret} =
      Client.do_request(wechat.client, :post, "/wxa/generate_urllink", body, %{
        "access_token" => token
      })

    Jason.decode(ret)
  end

  @doc """
  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/url-scheme/urlscheme.generate.html

  ## Examples

      {:ok, %{
        "errcode" => 0,
        "errmsg" => "ok",
        "openlink" => "weixin://dl/business/?t=Akeatr890b"
      }} = LibWechat.generate_scheme(wechat, token,
        %{
          "jump_wxa" => %{
            "path" => "pages/index/index",
            "query" => "foo=bar"
          },
          "is_expire" => false,
          "expire_type" => 0,
          "expire_time" => 0
        }
      )

  """
  @spec generate_scheme(t(), String.t(), json_t()) ::
          ok_t(json_t()) | err_t(Jason.DecodeError.t())
  def generate_scheme(wechat, token, body) do
    {:ok, ret} =
      Client.do_request(wechat.client, :post, "/wxa/generatescheme", body, %{
        "access_token" => token
      })

    Jason.decode(ret)
  end

  @doc """
  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.send.html

  ## Examples

      {:ok, %{
        "errcode" => 0,
        "errmsg" => "ok",
        "msgid" => 294402298110051942
        }} = LibWechat.subscribe_send(wechat, token,
        %{
          "touser" => "OPENID",
          "template_id" => "TEMPLATE_ID",
          "page" => "index",
          "miniprogram_state" => "developer",
          "lang" => "zh_CN",
          "data" => %{
            "number01" => %{"value" => "339208499"},
            "date01" => %{"value" => "2015年01月05日"},
            "site01" => %{"value" => "TIT创意园"},
            "site02" => %{"value" => "广州市新港中路397号"}
          }
        }
      )

  """
  @spec subscribe_send(t(), String.t(), json_t()) :: ok_t(json_t()) | err_t(Jason.DecodeError.t())
  def subscribe_send(wechat, token, body) do
    {:ok, ret} =
      Client.do_request(wechat.client, :post, "/cgi-bin/message/subscribe/send", body, %{
        "access_token" => token
      })

    Jason.decode(ret)
  end

  @doc """
  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/uniform-message/uniformMessage.send.html

  ## Examples

      {:ok, %{"errcode" => 0, "errmsg" => "ok"}} = LibWechat.uniform_send(wechat, token,
        %{
          "touser" => "OPENID",
          "weapp_template_msg" => %{
            "template_id" => "TEMPLATE_ID",
            "page" => "index",
            "form_id" => "FORMID",
            "data" => %{
              "keyword1" => %{"value" => "339208499"},
              "keyword2" => %{"value" => "2015年01月05日"},
              "keyword3" => %{"value" => "粤海喜来登酒店"},
              "keyword4" => %{"value" => "广州市天河区天河路208号"}
            },
            "emphasis_keyword" => "keyword1.DATA"
          },
          "mp_template_msg" => %{
            "appid" => "APPID ",
            "template_id" => "TEMPLATE_ID",
            "url" => "http://weixin.qq.com/download",
            "miniprogram" => %{
              "appid" => "xiaochengxuappid12345",
              "pagepath" => "index?foo=bar"
            },
            "data" => %{
              "first" => %{"value" => "恭喜你购买成功！", "color" => "#173177"},
              "keyword1" => %{"value" => "巧克力", "color" => "#173177"},
              "keyword2" => %{"value" => "39.8元", "color" => "#173177"},
              "keyword3" => %{"value" => "2014年9月22日", "color" => "#173177"},
              "remark" => %{"value" => "欢迎再次购买！", "color" => "#173177"}
            }
          }
        })

  """
  @spec uniform_send(t(), String.t(), json_t()) :: ok_t(json_t()) | err_t(Jason.DecodeError.t())
  def uniform_send(wechat, token, body) do
    {:ok, ret} =
      Client.do_request(
        wechat.client,
        :post,
        "/cgi-bin/message/wxopen/template/uniform_send",
        body,
        %{
          "access_token" => token
        }
      )

    Jason.decode(ret)
  end

  @doc """
  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/phonenumber/phonenumber.getPhoneNumber.html

  ## Examples

      {:ok,
        %{
            "errcode":0,
            "errmsg":"ok",
            "phone_info": {
              "phoneNumber":"xxxxxx",
              "purePhoneNumber": "xxxxxx",
              "countryCode": 86,
              "watermark": {
                  "timestamp": 1637744274,
                  "appid": "xxxx"
              }
            }
          }
        } = get_phone_number(wechat, token, code)
  """
  @spec get_phone_number(t(), String.t(), String.t()) ::
          ok_t(json_t()) | err_t(Jason.DecodeError.t())
  def get_phone_number(wechat, token, code) do
    {:ok, ret} =
      Client.do_request(
        wechat.client,
        :post,
        "/wxa/business/getuserphonenumber",
        %{"code" => code},
        %{
          "access_token" => token
        }
      )

    Jason.decode(ret)
  end
end
