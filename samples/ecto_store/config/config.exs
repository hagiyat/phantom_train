# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :sample_train, SampleTrain.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "sample_train_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"


config :phantom_train, :subscriber,
  module: PhantomTrain.Subscriber.SystemCommand,
  command: "redis-cli monitor"

config :phantom_train, :stores,
  [
    [
      match: ~r/"set"\s+"user:id"\s+"(?<value>\w+)"/i,
      module: SampleTrain.Store.User,
      callback: :append_id
    ],
    [
      match: ~r/"hmset"\s+"user:(?<key>\w+):details"(?<values>(\s+"\w+"\s+"\w+")+)/i,
      module: SampleTrain.Store.User,
      callback: :update_details
    ],
  ]

config :sample_train, SampleTrain.Repo,
  adapter: Ecto.Adapters.MySQL,
  database: "dummy",
  username: "foo",
  password: "password"

