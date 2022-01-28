defmodule Vial.MixProject do
  use Mix.Project

  def project do
    [
      app: :vial,
      description: "A library for staged processing and event handling.",
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Rosa Richter"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Cantido/vial",
        "Sponsor" => "https://liberapay.com/rosa"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
