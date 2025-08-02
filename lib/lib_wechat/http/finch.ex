defmodule LibWechat.Http.Finch do
  @moduledoc false

  @type t :: %__MODULE__{
          finch_name: atom()
        }
  defstruct [:finch_name]
end

defimpl LibWechat.Http, for: LibWechat.Http.Finch do
  @moduledoc false

  alias LibWechat.Error
  alias LibWechat.Model.Http

  defp opts(nil), do: [receive_timeout: 5000]
  defp opts(options), do: Keyword.put_new(options, :receive_timeout, 5000)

  def do_request(%LibWechat.Http.Finch{finch_name: finch_name}, req) do
    opts = opts(req.opts)

    finch_req =
      Finch.build(
        req.method,
        Http.Request.url(req),
        req.headers,
        req.body,
        opts
      )

    finch_req
    |> Finch.request(finch_name)
    |> case do
      {:ok, %Finch.Response{status: status, body: body, headers: headers}}
      when status in 200..299 ->
        {:ok, %Http.Response{status_code: status, body: body, headers: headers}}

      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, Error.new("bad response", %{status: status, body: body})}

      {:error, exception} ->
        {:error, Error.new("bad response", exception)}
    end
  end
end
