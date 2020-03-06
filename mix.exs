defmodule TestDispatchForm.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_dispatch_form,
      deps: deps(),
      description: "Helper to test the dispatch of Phoenix forms in Elixir applications",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "TestDispatchForm",
      package: package(),
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test],
      source_url: "https://github.com/DefactoSoftware/test_dispatch_form",
      start_permanent: Mix.env() == :test,
      test_coverage: [tool: ExCoveralls],
      dialyzer: [plt_add_apps: [:mix, :ex_unit], check_plt: true],
      version: "0.1.0"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.7", only: :test},
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
        "GitHub" => "https://github.com/DefactoSoftware/test_dispatch_form",
        "Docs" => "http://hexdocs.pm/test_dispatch_form/"
      }
    ]
  end
end
