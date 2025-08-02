defprotocol LibWechat.Http do
  @doc """
  Perform an HTTP request.
  """
  @spec do_request(
          http :: LibWechat.Http.t(),
          req :: LibWechat.Model.Http.Request.t()
        ) ::
          {:ok, LibWechat.Model.Http.Response.t()} | {:error, LibWechat.Error.t()}
  def do_request(http, req)
end
