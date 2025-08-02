defmodule LibWechat.Internal.Config do
  @moduledoc """
  内部配置管理模块，负责获取和验证配置信息。

  该模块处理应用配置的访问，允许从 Agent 进程中获取配置，
  并提供方便的访问接口。
  """

  alias LibWechat.Model.Config

  @doc """
  从指定的应用实例中获取配置。

  ## 参数
    * `name` - 应用实例名称

  ## 返回值
    * `config` - 配置信息的关键字列表
  """
  @spec get(module()) :: Config.t()
  def get(name) do
    Agent.get(name, & &1)
  end

  @doc """
  更新指定应用实例的配置。

  ## 参数
    * `name` - 应用实例名称
    * `config` - 要更新的配置

  ## 返回值
    * `:ok` - 更新成功
  """
  @spec update(module(), Config.t()) :: :ok
  def update(name, config) do
    config = Config.validate!(config)
    Agent.update(name, fn current_config -> Keyword.merge(current_config, config) end)
  end

  @doc """
  启动配置管理 Agent 进程。

  ## 参数
    * `name` - 应用实例名称
    * `finch` - Finch 实例
    * `config` - 初始配置

  ## 返回值
    * `{:ok, pid}` - 启动成功
    * `{:error, reason}` - 启动失败
  """
  @spec start_link({module(), any(), Config.t()}) :: {:ok, pid()} | {:error, any()}
  def start_link({name, finch, config}) do
    config =
      config
      |> Config.validate!()
      |> Keyword.put(:finch, finch)

    Agent.start_link(fn -> config end, name: name)
  end
end
