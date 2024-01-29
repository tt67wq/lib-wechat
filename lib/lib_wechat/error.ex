defmodule LibWechat.Error do
  @moduledoc """
  errors
  """

  @type t :: %__MODULE__{
          message: binary(),
          details: any()
        }

  defexception [:message, :details]

  @spec new(binary(), any()) :: t()
  def new(message, details \\ nil) do
    %__MODULE__{message: message, details: details}
  end

  def message(%__MODULE__{} = exception) do
    pfx = "** (Exception) "

    case exception.message do
      nil -> pfx <> details(exception.details)
      val -> pfx <> val <> details(exception.details)
    end
  end

  defp details(e) when is_map(e), do: ": " <> (e |> Map.to_list() |> inspect())
  defp details(e) when is_binary(e), do: ": " <> e
  defp details(nil), do: ""
  defp details(e), do: ": " <> inspect(e)
end
