defmodule Phenol.MixProject do
  use Mix.Project

  def project do
    [
      app: :phenol,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:nimble_parsec, "~> 0.3.2"},
      {:benchee, "~> 0.11", only: :dev},
      {:html_sanitize_ex, "~> 1.3.0-rc3", only: :dev}
    ]
  end
end
