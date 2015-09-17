use Mix.Config

config PhantomTrain.Storer, :users,
  channel: "test_channel",
  redis_type: :hash,
  store_table: "users",
  take_key: ~r/user:(?<id>[a-z0-9]+?):details/,
  primary_key: "id",
  scheme: %{id: :_take_key, }


config PhantomTrain.Storer, :fuga,
  channel: "test_channel2",
  redis_type: :hash,
  store_table: "messages",
  scheme: %{}
