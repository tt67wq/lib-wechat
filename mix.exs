defmodule LibWechat.MixProject do
  use Mix.Project

  @name "lib_wechat"
  @version "0.1.1"
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
      {:nimble_options, "~> 0.5"},
      {:jason, "~> 1.4", optional: true},
      {:finch, "~> 0.16"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
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
