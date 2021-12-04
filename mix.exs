defmodule Bagg.MixProject do
  use Mix.Project

  def project do
    [
      app: :bagg,
      version: "0.1.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:timex, "~> 3.7.3"},
      {:jason, "~> 1.2"},

      {:credo, "~> 1.6.1", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
