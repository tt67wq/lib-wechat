defmodule LibWechat do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias LibWechat.Http
  alias LibWechat.Typespecs

  @external_resource "README.md"
  @options_schema [
    name: [
      type: :atom,
      doc: "name of this process",
      default: :wechat
    ],
    client: [
      type: :any,
      doc: "http client instance which implements LibWechat.Http behavior",
      default: Http.Default.new()
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
          client: Client.t(),
          appid: binary(),
          secret: binary()
        }
  @type options_t :: keyword(unquote(NimbleOptions.option_typespec(@options_schema)))
  @type ok_t(m) :: {:ok, m}
  @type err_t :: {:error, LibWechat.Error.t()}
  @type token_t :: String.t()

  defstruct name: :wechat,
            client: nil,
            appid: "",
            secret: ""

  @doc """
  create an instance of LibWechat
  ## options
  #{NimbleOptions.docs(@options_schema)}
  """
  @spec new(options_t()) :: t()
  def new(opts \\ []) do
    opts =
      NimbleOptions.validate!(opts, @options_schema)

    struct(__MODULE__, opts)
  end

  def child_spec(opts) do
    wechat = Keyword.fetch!(opts, :wechat)
    %{id: {__MODULE__, wechat.name}, start: {__MODULE__, :start_link, [opts]}}
  end

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    {wechat, _opts} = Keyword.pop!(opts, :wechat)
    Http.start_link(wechat.client)
  end

  @doc """
  获取access_token
  https://developers.weixin.qq.com/doc/offiaccount/Basic_Information/Get_access_token.html


  ## Examples

      {:ok, %{"access_token"=>"xxx"}} = LibWechat.get_access_token(wechat)
  """
  @spec get_access_token(t()) :: ok_t(Typespecs.string_dict()) | err_t()
  def get_access_token(%__MODULE__{client: client, appid: appid, secret: secret}) do
    params = %{
      "appid" => appid,
      "secret" => secret,
      "grant_type" => "client_credential"
    }

    with {:ok, resp} <-
           Http.do_request(
             client,
             Http.Request.new(
               method: :get,
               path: "/cgi-bin/token",
               params: params
             )
           ) do
      Http.Response.json(resp)
    end
  end

  @doc """
  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/login/auth.code2Session.html
  """
  @spec jscode_to_session(t(), String.t()) :: ok_t(Typespecs.string_dict()) | err_t()
  def jscode_to_session(wechat, code) do
    params = %{
      "appid" => wechat.appid,
      "secret" => wechat.secret,
      "js_code" => code,
      "grant_type" => "authorization_code"
    }

    with {:ok, resp} <-
           Http.do_request(
             wechat.client,
             Http.Request.new(
               method: :get,
               path: "/sns/jscode2session",
               params: params
             )
           ) do
      Http.Response.json(resp)
    end
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
  @spec get_unlimited_wxacode(t(), token_t(), Typespecs.string_dict()) :: ok_t(binary()) | err_t()
  def get_unlimited_wxacode(%__MODULE__{client: client}, token, payload) do
    with {:ok, body} <- Jason.encode(payload),
         {:ok, resp} <-
           Http.do_request(
             client,
             Http.Request.new(
               method: :post,
               path: "/wxa/getwxacodeunlimit",
               body: body,
               headers: [{"Content-Type", "application/json"}],
               params: %{"access_token" => token}
             )
           ) do
      {:ok, Http.Response.body(resp)}
    end
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
  @spec get_urllink(t(), token_t(), Typespecs.string_dict()) :: ok_t(Typespecs.string_dict()) | err_t()
  def get_urllink(%__MODULE__{client: client}, token, payload) do
    with {:ok, body} <- Jason.encode(payload),
         {:ok, resp} <-
           Http.do_request(
             client,
             Http.Request.new(
               method: :post,
               path: "/wxa/generate_urllink",
               body: body,
               headers: [{"Content-Type", "application/json"}],
               params: %{"access_token" => token}
             )
           ) do
      Http.Response.json(resp)
    end
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
  @spec generate_scheme(t(), token_t(), Typespecs.string_dict()) ::
          ok_t(Typespecs.string_dict()) | err_t()
  def generate_scheme(%__MODULE__{client: client}, token, payload) do
    with {:ok, body} <- Jason.encode(payload),
         {:ok, resp} <-
           Http.do_request(
             client,
             Http.Request.new(
               method: :post,
               path: "/wxa/generatescheme",
               body: body,
               headers: [{"Content-Type", "application/json"}],
               params: %{"access_token" => token}
             )
           ) do
      Http.Response.json(resp)
    end
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
  @spec subscribe_send(t(), token_t(), Typespecs.string_dict()) :: ok_t(Typespecs.string_dict()) | err_t()
  def subscribe_send(%__MODULE__{client: client}, token, payload) do
    with {:ok, body} <- Jason.encode(payload),
         {:ok, resp} <-
           Http.do_request(
             client,
             Http.Request.new(
               method: :post,
               path: "/cgi-bin/message/subscribe/send",
               body: body,
               headers: [{"Content-Type", "application/json"}],
               params: %{"access_token" => token}
             )
           ) do
      Http.Response.json(resp)
    end
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
  @spec uniform_send(t(), token_t(), Typespecs.string_dict()) :: ok_t(Typespecs.string_dict()) | err_t()
  def uniform_send(wechat, token, body) do
    with {:ok, body} <- Jason.encode(body),
         {:ok, resp} <-
           Http.do_request(
             wechat.client,
             Http.Request.new(
               method: :post,
               path: "/cgi-bin/message/wxopen/template/uniform_send",
               body: body,
               headers: [{"Content-Type", "application/json"}],
               params: %{"access_token" => token}
             )
           ) do
      Http.Response.json(resp)
    end
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
  @spec get_phone_number(t(), token_t(), String.t()) ::
          ok_t(Typespecs.string_dict()) | err_t()
  def get_phone_number(wechat, token, code) do
    with {:ok, resp} <-
           Http.do_request(
             wechat.client,
             Http.Request.new(
               method: :post,
               path: "/wxa/business/getuserphonenumber",
               body: Jason.encode!(%{"code" => code}),
               headers: [{"Content-Type", "application/json"}],
               params: %{"access_token" => token}
             )
           ) do
      Http.Response.json(resp)
    end
  end

  @doc """
  https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/sec-center/sec-check/msgSecCheck.html

  ## Examples

      iex> payload = %{
        "openid"=> "OPENID",
        "scene"=> 1,
        "version"=> 2,
        "content"=> "hello world!"
      }
      iex> LibWechat.msg_sec_check(wechat, token, payload)
      {
         "errcode"=> 0,
         "errmsg"=> "ok",
         "result"=> %{
             "suggest"=> "risky",
             "label"=> 20001
         },
         "detail"=> [
             %{
                 "strategy"=> "content_model",
                 "errcode"=> 0,
                 "suggest"=> "risky",
                 "label"=> 20006,
                 "prob"=> 90
             },
             %{
                 "strategy": "keyword",
                 "errcode": 0,
                 "suggest": "pass",
                 "label": 20006,
                 "level": 20,
                 "keyword": "命中的关键词1"
             },
             {
                 "strategy": "keyword",
                 "errcode": 0,
                 "suggest": "risky",
                 "label": 20006,
                 "level": 90,
                 "keyword": "命中的关键词2"
             }
         ],
         "trace_id": "60ae120f-371d5872-7941a05b"
      }
  """
  @spec msg_sec_check(t(), token_t(), Typespecs.string_dict()) :: ok_t(Typespecs.string_dict()) | err_t()
  def msg_sec_check(%__MODULE__{client: client}, token, payload) do
    with {:ok, body} <- Jason.encode(payload),
         {:ok, resp} <-
           Http.do_request(
             client,
             Http.Request.new(
               method: :post,
               path: "/wxa/msg_sec_check",
               body: body,
               headers: [{"Content-Type", "application/json"}],
               params: %{"access_token" => token}
             )
           ) do
      Http.Response.json(resp)
    end
  end
end
