defmodule LibWechat.MixProject do
  @moduledoc false
  use Mix.Project

  @name "lib_wechat"
  @version "0.2.2"
  @repo_url "https://github.com/tt67wq/lib-wechat"
  @description "A library for WeChat API"

  def project do
    [
      app: :lib_wechat,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @repo_url,
      name: @name,
      package: package(),
      description: @description
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_options, "~> 1.1"},
      {:jason, "~> 1.4"},
      {:finch, "~> 0.18"},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false},
      {:styler, "~> 0.11", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @repo_url
      }
    ]
  end
end
