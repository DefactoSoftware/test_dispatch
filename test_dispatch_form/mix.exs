defmodule TestDispatchForm.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_dispatch_form,
      version: "0.1.0",
      elixir: "~> 1.8",
      description: "Helper to test the dispatch of Phoenix forms in Elixir applications",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.26.0"},
      {:phoenix, "~> 1.4"},
      {:test_selector, "~> 0.3.0"}
    ]
  end

  defp package do
    [
      maintainers: ["Marcel Horlings", "Pien van Dalen"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/DefactoSoftware/test_dispatch_form"
        "Docs" => "http://hexdocs.pm/test_dispatch_form/"
      }
    ]
  end
end
