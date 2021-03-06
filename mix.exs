defmodule PhantomTrain.Mixfile do
  use Mix.Project

  def project do
    [app: :phantom_train,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      applications: [:logger],
    ]
  end

  # Dependencies can be Hex packages:
  defp deps do
    [
    ]
  end
end
