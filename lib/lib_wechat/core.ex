defmodule LibWechat.Core do
  @moduledoc false

  use Agent

  alias LibWechat.Model.Config
  alias LibWechat.Model.Http
  alias LibWechat.Typespecs

  @type ok_t(m) :: {:ok, m}
  @type err_t :: {:error, LibWechat.Error.t()}

  @http_impl LibWechat.Http.Finch

  def start_link({name, http_name, config}) do
    config =
      config
      |> Config.validate!()
      |> Keyword.put(:http_name, http_name)

    Agent.start_link(fn -> config end, name: name)
  end

  def get(name) do
    Agent.get(name, & &1)
  end

  defp call_http(name, req) do
    apply(@http_impl, :do_request, [name, req])
  end

  @spec do_request(Config.t(), Typespecs.method(), binary(), Typespecs.params(), Typespecs.body(), Keyword.t()) ::
          {:ok, Http.Response.t()} | err_t()
  defp do_request(config, method, api, params, body, opts \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]

    call_http(config[:http_name], %Http.Request{
      host: config[:service_host],
      method: method,
      path: api,
      headers: headers,
      body: body,
      params: params,
      opts: opts
    })
  end

  @spec get_access_token(module()) :: {:ok, Typespecs.dict()} | err_t()
  def get_access_token(name) do
    config = get(name)

    params = %{
      "appid" => config[:appid],
      "secret" => config[:secret],
      "grant_type" => "client_credential"
    }

    with {:ok, %Http.Response{body: body}} <- do_request(config, :get, "/cgi-bin/token", params, "") do
      Jason.decode(body)
    end
  end

  @spec jscode_to_session(module(), binary()) :: {:ok, Typespecs.dict()} | err_t()
  def jscode_to_session(name, code) do
    config = get(name)

    params = %{
      "appid" => config[:appid],
      "secret" => config[:secret],
      "js_code" => code,
      "grant_type" => "authorization_code"
    }

    with {:ok, %Http.Response{body: body}} <- do_request(config, :get, "/sns/jscode2session", params, "") do
      Jason.decode(body)
    end
  end

  @spec get_unlimited_wxacode(module(), binary(), Typespecs.dict()) :: {:ok, binary()} | err_t()
  def get_unlimited_wxacode(name, token, payload) do
    config = get(name)

    with {:ok, body} <- Jason.encode(payload),
         {:ok, %Http.Response{body: body}} <-
           do_request(config, :post, "/wxa/getwxacodeunlimit", %{"access_token" => token}, body) do
      {:ok, body}
    end
  end

  @spec get_urllink(module(), binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
  def get_urllink(name, token, payload) do
    config = get(name)

    with {:ok, body} <- Jason.encode(payload),
         {:ok, %Http.Response{body: body}} <-
           do_request(config, :post, "/wxa/generate_urllink", %{"access_token" => token}, body) do
      Jason.decode(body)
    end
  end

  @spec generate_scheme(module(), binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
  def generate_scheme(name, token, payload) do
    config = get(name)

    with {:ok, body} <- Jason.encode(payload),
         {:ok, %Http.Response{body: body}} <-
           do_request(config, :post, "/wxa/generatescheme", %{"access_token" => token}, body) do
      Jason.decode(body)
    end
  end

  @spec subscribe_send(module(), binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
  def subscribe_send(name, token, payload) do
    config = get(name)

    with {:ok, body} <- Jason.encode(payload),
         {:ok, %Http.Response{body: body}} <-
           do_request(config, :post, "/cgi-bin/message/subscribe/send", %{"access_token" => token}, body) do
      Jason.decode(body)
    end
  end

  @spec uniform_send(module(), binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
  def uniform_send(name, token, body) do
    config = get(name)

    with {:ok, body} <- Jason.encode(body),
         {:ok, %Http.Response{body: body}} <-
           do_request(config, :post, "/cgi-bin/message/wxopen/template/uniform_send", %{"access_token" => token}, body) do
      Jason.decode(body)
    end
  end

  @spec get_phone_number(module(), binary(), binary()) :: {:ok, Typespecs.dict()} | err_t()
  def get_phone_number(name, token, code) do
    config = get(name)

    {:ok, body} = Jason.encode(%{"code" => code})

    with {:ok, %Http.Response{body: body}} <-
           do_request(config, :post, "/wxa/business/getuserphonenumber", %{"access_token" => token}, body) do
      Jason.decode(body)
    end
  end

  @spec msg_sec_check(module(), binary(), Typespecs.dict()) :: {:ok, Typespecs.dict()} | err_t()
  def msg_sec_check(name, token, payload) do
    config = get(name)

    with {:ok, body} <- Jason.encode(payload),
         {:ok, %Http.Response{body: body}} <-
           do_request(config, :post, "/wxa/msg_sec_check", %{"access_token" => token}, body) do
      Jason.decode(body)
    end
  end
end
