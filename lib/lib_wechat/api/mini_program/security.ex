defmodule LibWechat.API.MiniProgram.Security do
  @moduledoc """
  小程序内容安全相关 API 模块。

  提供内容安全检测相关的接口，包括文本内容安全检测等功能。
  开发者可以通过调用这些接口，检测用户输入的内容是否包含违规信息。
  """

  alias LibWechat.Internal.Config
  alias LibWechat.Internal.RequestBuilder
  alias LibWechat.Typespecs

  @doc """
  检查一段文本是否含有违法违规内容。

  通过该接口，可以检测用户输入的文本是否包含违法违规内容，如政治敏感、色情、辱骂性等内容。
  适用于各类用户内容的安全检测，如聊天文本、评论、留言、昵称等场景。

  ## 参数
    * `name` - 应用实例名称
    * `token` - 接口调用凭证
    * `payload` - 请求参数，包括：
      * `content` - 要检测的文本内容，长度不超过2000字符
      * `openid` - 用户的openid（用户需在近两小时访问过小程序）
      * `scene` - 场景枚举值（1：资料，2：评论，3：论坛，4：社交日志）
      * `version` - 版本号，2为当前最新版本

  ## 返回值
    * `{:ok, map()}` - 检测成功，返回检测结果
    * `{:error, error}` - 检测失败

  ## 示例
      iex> payload = %{
      ...>   "openid" => "OPENID",
      ...>   "scene" => 1,
      ...>   "version" => 2,
      ...>   "content" => "hello world!"
      ...> }
      iex> LibWechat.API.MiniProgram.Security.msg_sec_check(MyApp, token, payload)
      {:ok, %{
      ...>   "errcode" => 0,
      ...>   "errmsg" => "ok",
      ...>   "result" => %{
      ...>     "suggest" => "risky",
      ...>     "label" => 20001
      ...>   },
      ...>   "detail" => [
      ...>     %{
      ...>       "strategy" => "content_model",
      ...>       "errcode" => 0,
      ...>       "suggest" => "risky",
      ...>       "label" => 20006,
      ...>       "prob" => 90
      ...>     },
      ...>     %{
      ...>       "strategy" => "keyword",
      ...>       "errcode" => 0,
      ...>       "suggest" => "pass",
      ...>       "label" => 20006,
      ...>       "level" => 20,
      ...>       "keyword" => "命中的关键词1"
      ...>     }
      ...>   ],
      ...>   "trace_id" => "60ae120f-371d5872-7941a05b"
      ...> }}

  详情参考：https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/sec-center/sec-check/msgSecCheck.html
  """
  @spec msg_sec_check(module(), binary(), Typespecs.dict()) ::
          {:ok, Typespecs.dict()} | {:error, LibWechat.Error.t()}
  def msg_sec_check(name, token, payload) do
    config = Config.get(name)

    config
    |> RequestBuilder.post_with_token("/wxa/msg_sec_check", token, payload)
    |> RequestBuilder.handle_json_response()
  end
end
