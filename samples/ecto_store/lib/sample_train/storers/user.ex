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

  def append_id(%{"value" => value}) do
    IO.inspect value
  end

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
