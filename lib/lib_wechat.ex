defmodule LibWechat do
  @moduledoc """
  LibWechat - 微信 API Elixir 库

  这是一个用于与微信 API 交互的 Elixir 库，提供了小程序、公众号等微信平台的功能接口。

  ## 使用方法

  在你的模块中 `use LibWechat` 来获得所有微信 API 功能：

      defmodule MyApp.Wechat do
        use LibWechat, otp_app: :my_app
      end

  然后在配置文件中设置微信应用信息：

      config :my_app, MyApp.Wechat,
        appid: "your_app_id",
        secret: "your_app_secret"

  ## 可用功能

  - 认证管理：获取 access_token、小程序登录
  - 小程序码：生成不限量小程序码
  - 链接生成：URL Link、Scheme 码
  - 消息推送：订阅消息发送
  - 用户信息：获取手机号
  - 安全检查：文本内容安全检测

  ## 启动

      {:ok, _pid} = MyApp.Wechat.start_link()

  ## 示例

      # 获取 access_token
      {:ok, token_info} = MyApp.Wechat.get_access_token()

      # 小程序登录
      {:ok, session} = MyApp.Wechat.jscode_to_session("user_code")

      # 生成小程序码
      {:ok, qrcode} = MyApp.Wechat.get_unlimited_wxacode(token, payload)

  更多详细使用说明请参考 [README.md](README.md) 文件。
  """
  @external_resource "README.md"

  defmacro __using__(opts) do
    quote do
      alias LibWechat.Core
      alias LibWechat.Typespecs

      @type ok_t(ret) :: {:ok, ret}
      @type err_t() :: {:error, LibWechat.Error.t()}

      def init(config) do
        {:ok, config}
      end

      defoverridable init: 1

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor
        }
      end

      def start_link(config \\ []) do
        otp_app = unquote(opts[:otp_app])

        {:ok, cfg} =
          otp_app
          |> Application.get_env(__MODULE__, config)
          |> init()

        LibWechat.Supervisor.start_link(__MODULE__, cfg)
      end

      defp delegate(method, args), do: apply(Core, method, [__MODULE__ | args])

      @doc """
      获取access_token
      https://developers.weixin.qq.com/doc/offiaccount/Basic_Information/Get_access_token.html


      ## Examples
          iex> LibWechat.get_access_token()
          {:ok, %{"access_token" => "xxx", "expires_in" => 7200}}
      """
      @spec get_access_token() :: {:ok, Typespecs.dict()} | err_t()
      def get_access_token, do: delegate(:get_access_token, [])

      @doc """
      https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/login/auth.code2Session.html
      """
      @spec jscode_to_session(binary()) :: {:ok, Typespecs.dict()} | err_t()
      def jscode_to_session(js_code), do: delegate(:jscode_to_session, [js_code])

      @doc """
      https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/qr-code/wxacode.getUnlimited.html

      ## Examples
          iex> LibWechat.get_unlimited_wxacode(token,
            %{"scene" => "foo=bar",
              "page" => "pages/index/index",
              "width" => 430,
              "auto_color" => false,
              "line_color" => %{"r" => 0, "g" => 0, "b" => 0},
              "is_hyaline" => false
            }
          )
          {:ok, <<255, 216, ...>>}
      """
      @spec get_unlimited_wxacode(binary(), Typespecs.dict()) :: {:ok, binary()} | err_t()
      def get_unlimited_wxacode(token, payload) do
        delegate(:get_unlimited_wxacode, [token, payload])
      end

      @doc """
      https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/url-link/urllink.generate.html

      ## Examples
          iex> LibWechat.get_urllink(token,
            %{
              "path" => "pages/index/index",
              "query" => "foo=bar",
              "is_expire" => false,
              "expire_type" => 0,
              "expire_time" => 0
            }
          )
          {:ok, %{
            "errcode" => 0,
            "errmsg" => "ok",
            "url_link" => "https://wxaurl.cn/bz2LB4RMDVqq"
          }}
      """
      @spec get_urllink(binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
      def get_urllink(token, payload) do
        delegate(:get_urllink, [token, payload])
      end

      @doc """
      https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/url-scheme/urlscheme.generate.html

      ## Examples
          iex> generate_scheme(token,
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
          {:ok, %{
            "errcode" => 0,
            "errmsg" => "ok",
            "openlink" => "weixin://dl/business/?t=Akeatr890b"
          }}
      """
      @spec generate_scheme(binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
      def generate_scheme(token, payload) do
        delegate(:generate_scheme, [token, payload])
      end

      @doc """
      https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.send.html

      ## Examples
          iex> subscribe_send(token, %{
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
           })
         {:ok, %{
           "errcode" => 0,
           "errmsg" => "ok",
           "msgid" => 294402298110051942
           }}
      """
      @spec subscribe_send(binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
      def subscribe_send(token, payload) do
        delegate(:subscribe_send, [token, payload])
      end

      @doc """
      https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/uniform-message/uniformMessage.send.html

      ## Examples
          iex> LibWechat.uniform_send(token,
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
          {:ok, %{"errcode" => 0, "errmsg" => "ok"}}
      """
      @deprecated "This API has been unsupported. For more details, please view https://developers.weixin.qq.com/community/develop/doc/000ae8d6348af08e7030bc2546bc01?blockType=1"
      @spec uniform_send(binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
      def uniform_send(token, body) do
        delegate(:uniform_send, [token, body])
      end

      @doc """
      https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/phonenumber/phonenumber.getPhoneNumber.html

      ## Examples
          iex> get_phone_number(token, code)
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
            }
      """
      @spec get_phone_number(binary(), binary()) :: {:ok, Typespecs.dict()} | err_t()
      def get_phone_number(token, code) do
        delegate(:get_phone_number, [token, code])
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
          iex> msg_sec_check(token, payload)
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
      @spec msg_sec_check(binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
      def msg_sec_check(token, payload) do
        delegate(:msg_sec_check, [token, payload])
      end
    end
  end
end
