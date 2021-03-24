defmodule TestDispatch.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_dispatch,
      deps: deps(),
      docs: docs(),
      description: "Helper to test dispatches of Phoenix forms and links in Elixir applications",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "TestDispatch",
      package: package(),
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test],
      source_url: "https://github.com/DefactoSoftware/test_dispatch",
      start_permanent: Mix.env() == :test,
      test_coverage: [tool: ExCoveralls],
      dialyzer: [plt_add_apps: [:mix, :ex_unit], check_plt: true],
      version: "0.2.4"
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
      {:dialyxir, "~> 1.1", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.7", only: :test},
      {:floki, "> 0.28.0"},
      {:phoenix, "~> 1.4"},
      {:plug, "~> 1.5"},
      {:test_selector, "~> 0.3.0"}
    ]
  end

  defp package do
    [
      maintainers: ["Marcel Horlings", "Pien van Dalen"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/DefactoSoftware/test_dispatch",
        "Docs" => "http://hexdocs.pm/test_dispatch/"
      }
    ]
  end

  defp docs do
    [
      extra_section: "GUIDES",
      formatters: ["html", "epub"],
      extras: ["guides/testing-with-test-dispatch.md"],
      groups_for_extras: [
        "How to": "guides/testing-with-test-dispatch.md"
      ]
    ]
  end
end
