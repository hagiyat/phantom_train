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
      mod: {PhantomTrain, []},
      applications: [:logger, :ecto, :exredis],
    ]
  end

  # Dependencies can be Hex packages:
  defp deps do
    [
      {:ecto, "~> 1.0.2"},
      {:mariaex, "~> 0.4.2"},
      {:exredis, "~> 0.2.0"},
      {:exrm, "~> 0.18.1"}
    ]
  end
end
