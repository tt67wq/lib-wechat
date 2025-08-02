defmodule LibWechat.Debug do
  @moduledoc """
  调试工具模块

  提供一系列便捷的调试函数，用于在开发过程中调试和日志记录。
  这些函数用于输出调试信息和跟踪代码执行，帮助开发者定位问题。
  """
  require Logger

  @doc """
  输出调试信息到日志。

  该函数将传入的值记录到日志中，并返回该值，允许在管道操作中使用。

  ## 参数
    * `msg` - 要记录的任意值

  ## 返回值
    * 返回传入的值

  ## 示例
      iex> x = LibWechat.Debug.debug("测试")
      iex> x
      "测试"
  """
  @spec debug(any()) :: any()
  def debug(msg), do: tap(msg, fn msg -> Logger.debug("[DEBUGING!!!!] => #{inspect(msg)}") end)

  @doc """
  输出调试信息和当前调用栈到日志。

  该函数记录传入的值和当前函数调用栈到日志中，并返回该值，
  允许在管道操作中使用。这对于追踪程序执行路径特别有用。

  ## 参数
    * `msg` - 要记录的任意值

  ## 返回值
    * 返回传入的值

  ## 示例
      iex> x = LibWechat.Debug.stacktrace("测试调用栈")
      iex> x
      "测试调用栈"
  """
  @spec stacktrace(any()) :: any()
  def stacktrace(msg) do
    tap(msg, fn msg ->
      self()
      |> Process.info(:current_stacktrace)
      |> then(fn {:current_stacktrace, stacktrace} -> stacktrace end)
      # ignore the first two stacktrace
      |> Enum.drop(2)
      |> Enum.map_join("\n", fn {mod, fun, arity, [file: file, line: line]} ->
        "\t#{mod}.#{fun}/#{arity} #{file}:#{line}"
      end)
      |> then(fn stacktrace ->
        Logger.debug("[DEBUGING!!!!] => #{inspect(msg)} \n#{stacktrace}")
      end)
    end)
  end
end
