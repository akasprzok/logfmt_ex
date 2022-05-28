defmodule LogfmtEx.MixProject do
  use Mix.Project

  @version "0.1.1"
  @url "https://github.com/akasprzok/logfmt_ex"

  def project do
    [
      app: :logfmt_ex,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex-specific
      description: description(),
      package: package(),
      source_url: @url,
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~>0.28", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    LogfmtEx is a formatter for Elixir's :console Logger backend.
    It emits logs in logfmt and is extensible via a value encoder protocol.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @url},
      files: ~w(mix.exs lib README.md LICENSE.md)
    ]
  end

  defp docs do
    [
      main: "LogfmtEx",
      extras: ["README.md"]
    ]
  end
end
