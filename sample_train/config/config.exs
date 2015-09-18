# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :phantom_train, :subscriber,
  module: PhantomTrain.Subscriber.SystemCommand,
  command: "redis-cli monitor"

config :sample_train, SampleTrain.Repo,
  adapter: Ecto.Adapters.MySQL,
  database: "dummy",
  username: "foo",
  password: "password"

