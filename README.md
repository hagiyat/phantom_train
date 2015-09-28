PhantomTrain
============

PhantomTrain receives some input that can be streamed, is a platform for any output.
Detailed implementation method, please refer to the [samples](https://github.com/hagiyat/phantom_train_samples).

## Usage

### Set the mix.exs

Add PhantomTrain as a dependency in your `mix.exs` file.

```
defp deps do
  [
    {:phantom_train, git: "https://github.com/hagiyat/phantom_train.git"},
  ]
end
```

You should also update your applications list to include both projects:

```
def application do
  [
    applications: [:phantom_train]
  ]
end
```

After you are done, run `mix deps.get` in your shell to fetch the dependencies.

### Setting the Subscriber and some Storers

- The Subscriber, file stream or system commands are available.
- If prepared even callback function to Storer, any module is available.
For example, it Ecto.Model.
- To capture the Store, you need to filter the messages coming into the stream of input. Set the filter with regular expressions to `match` the items in the Settings.
- In that case, please grant the name to the item you want to get in the message. Dict that was its name in the key will be set to the arguments of the callback function.

```
config :phantom_train, :subscriber,
  module: PhantomTrain.Subscriber.FileStream,
  path: "path/to/any.txt"
  # for system command:
  # module: PhantomTrain.Subscriber.SystemCommand,
  # command: "redis-cli monitor"

config :phantom_train, :stores,
  [
    [
      # When it match, %{"value" => value} is passed as an argument to the callback function.
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
```

## Defining a Storer

Using with Ecto.Model:

```
defmodule SampleTrain.Store.User do
  use Ecto.Model

  schema "users" do
    field :user_id, :string
    field :nickname, :string
    field :contact_id, :string
    timestamps
  end

  @required_field ~w(user_id nickname)
  @optional_field ~w(contact_id)

  def changeset(model, params \\ :empty) do
    model |> cast(params, @required_field, @optional_field)
  end

  @doc"""
  callback
  """
  def append_id(%{"value" => value}) do
    IO.inspect value
  end

  @doc"""
  callback
  """
  def update_details(%{"key" => key, "values" => values}) do
    params = values |> parse_values |> Map.put(:user_id, key)
    {:ok, result} =
      changeset(%SampleTrain.Store.User{}, params)
      |> SampleTrain.Repo.insert
    result
  end

  defp parse_values(values) do
    columns = __struct__ |> Map.keys
    Regex.replace(~r/\"/, values, "")
    |> String.strip
    |> String.split
    |> Enum.chunk(2)
    |> Enum.filter(fn([key, _]) -> columns |> Enum.member?(key |> String.to_atom) end)
    |> List.foldl(
        Map.new,
        fn([key, value], prms) ->
          prms |> Map.put(key |> String.to_atom, value)
        end
      )
  end
end
```
