defmodule LibWechat.Client do
  @moduledoc """
  微信请求request behavior
  """
  alias LibWechat.Client.Error
  @type t :: struct()
  @type opts :: keyword()
  @type method :: Finch.Request.method()
  @type api :: bitstring()
  @type body :: %{String.t() => any()} | nil
  @type params :: %{String.t() => any()} | nil

  @callback new(opts()) :: t()
  @callback start_link(client: t()) :: GenServer.on_start()
  @callback do_request(
              client :: t(),
              method :: method(),
              api :: api(),
              body :: body(),
              params :: params(),
              opts :: opts()
            ) ::
              {:ok, iodata()} | {:error, Error.t()}

  defp delegate(%module{} = client, func, args),
    do: apply(module, func, [client | args])

  @spec do_request(
          client :: t(),
          method :: method(),
          api :: api(),
          body :: body(),
          params :: params(),
          opts :: opts()
        ) :: {:ok, iodata()} | {:error, Error.t()}
  def do_request(client, method, api, body, params, opts \\ []) do
    delegate(client, :do_request, [method, api, body, params, opts])
  end
end

defmodule LibWechat.Client.Error do
  defexception [:message]

  @type t :: %__MODULE__{
          message: String.t()
        }

  def new(message) do
    %__MODULE__{message: message}
  end
end

defmodule LibWechat.Client.Finch do
  @moduledoc """
  requstor implementation using Finch
  """

  alias LibWechat.Client

  @behaviour Client

  @client_opts_schema [
    name: [
      type: :atom,
      doc: "name of this process",
      default: __MODULE__
    ],
    addr: [
      type: :string,
      doc: "address of the server",
      default: "https://api.weixin.qq.com"
    ],
    json_module: [
      type: :atom,
      doc: "module that implements json's encode and decode behavior like Jason",
      default: Jason
    ]
  ]

  # types
  @type t :: %__MODULE__{
          name: GenServer.name(),
          addr: bitstring(),
          json_module: module()
        }
  @type client_opts_t :: keyword(unquote(NimbleOptions.option_typespec(@client_opts_schema)))

  @enforce_keys ~w(name addr json_module)a

  defstruct @enforce_keys

  @impl Client
  def new(opts \\ []) do
    opts = opts |> NimbleOptions.validate!(@client_opts_schema)

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
             (not is_nil(body) && client.json_module.encode!(body)) || "",
             opts
           ) do
      Finch.request(req, client.name)
      |> case do
        {:ok, %Finch.Response{status: 200, body: body}} ->
          {:ok, body}

        {:ok, %Finch.Response{status: status, body: body}} ->
          {:error, %Client.Error{message: "status: #{status}, body: #{body}"}}

        {:error, exception} ->
          raise Client.Error.new(inspect(exception))
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
