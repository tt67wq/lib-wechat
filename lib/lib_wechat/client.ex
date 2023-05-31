defmodule LibWechat.Client do
  @moduledoc """
  微信请求request behavior
  """
  @type t :: struct()
  @type opts :: keyword()
  @type method :: Finch.Request.method()
  @type api :: bitstring()
  @type body :: %{String.t() => any()}
  @type params :: %{String.t() => any()}

  @callback new(opts()) :: t()
  @callback start_link(client: t()) :: GenServer.on_start()
  @callback do_request(t(), method(), api(), body(), params(), opts()) ::
              {:ok, iodata()} | {:error, any()}

  defp delegate(%module{} = client, func, args),
    do: apply(module, func, [client | args])

  def do_request(client, method, api, body, params, opts \\ []) do
    delegate(client, :do_request, [method, api, body, params, opts])
  end
end

defmodule LibWechat.Client.Finch do
  @moduledoc """
  requstor implementation using Finch
  """

  alias LibWechat.Client

  @behaviour Client

  # types
  @type t :: %__MODULE__{
          name: GenServer.name(),
          addr: bitstring()
        }

  @enforce_keys ~w(name addr)a

  defstruct @enforce_keys

  @impl Client
  def new(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:name, __MODULE__)
      |> Keyword.put_new(:addr, "https://api.weixin.qq.com")

    struct(__MODULE__, opts)
  end

  @impl Client
  def do_request(client, method, api, body, params, opts) do
    with url <- client.addr |> URI.merge(api) |> to_string(),
         url <- url <> "?" <> URI.encode_query(params),
         opts <- Keyword.put_new(opts, :receive_timeout, 2000),
         req <-
           Finch.build(
             method,
             url,
             [{"content-type", "application/json"}],
             (not is_nil(body) && Jason.encode!(body)) || "",
             opts
           ) do
      Finch.request(req, client.name)
      |> case do
        {:ok, %Finch.Response{status: 200, body: body}} ->
          {:ok, body}

        {:ok, %Finch.Response{status: status}} ->
          {:error, {:http_error, status}}

        {:error, _} = error ->
          error
      end
    end
  end

  def child_spec(opts) do
    client = Keyword.fetch!(opts, :client)
    %{id: {__MODULE__, client.name}, start: {__MODULE__, :start_link, [opts]}}
  end

  @impl Client
  def start_link(opts) do
    {client, _opts} = Keyword.pop!(opts, :client)
    Finch.start_link(name: client.name)
  end
end
