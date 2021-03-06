defmodule UnionType.MixProject do
  use Mix.Project

  def project do
    [
      app: :union_type,
      version: "0.1.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A library for defining and using union types",
      package: package()
    ]
  end

  defp package do
    [
      maintainers: ["MainShayne233"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/MainShayne233/union_type"}
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
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
