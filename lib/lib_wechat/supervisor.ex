defmodule LibWechat.Supervisor do
  @moduledoc false

  use Supervisor

  alias LibWechat.Typespecs

  @doc """
  启动 LibWechat 监督树。

  ## 参数
    * `name` - 应用实例名称
    * `config` - 配置信息

  ## 返回值
    * `{:ok, pid}` - 启动成功
    * `{:error, reason}` - 启动失败
  """
  @spec start_link(Typespecs.name(), Typespecs.config()) :: Typespecs.on_start()
  def start_link(name, config) do
    Supervisor.start_link(__MODULE__, {name, config}, name: supervisor_name(name))
  end

  @doc false
  @impl Supervisor
  @spec init({Typespecs.name(), Typespecs.config()}) :: {:ok, {Supervisor.sup_flags(), [Supervisor.child_spec()]}}
  def init({name, config}) do
    children =
      [
        {Finch, name: finch_name(name)},
        {LibWechat.Core, {name, %LibWechat.Http.Finch{finch_name: finch_name(name)}, config}}
      ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec supervisor_name(Typespecs.name()) :: atom()
  defp supervisor_name(name) do
    Module.concat(name, Supervisor)
  end

  @spec finch_name(Typespecs.name()) :: atom()
  defp finch_name(name) do
    Module.concat(name, Finch)
  end
end
