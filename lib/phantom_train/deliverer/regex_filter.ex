defmodule PhantomTrain.Deliverer.RegexFilter do
  use GenServer

  def start_link(stores) do
    GenServer.start_link(__MODULE__, stores)
  end

  def deliver(server, message) do
    GenServer.cast(server, {:deliver, message})
  end

  ## Server Callbacks
  def init(stores) do
    {:ok, %{stores: stores}}
  end

  def handle_cast({:deliver, message}, state) do
    state.stores |> Enum.filter_map(
      fn([{:match, m}|_]) -> m |> Regex.match? message end,
      fn(store) ->
        Task.async(
          store[:module],
          store[:callback],
          [Regex.named_captures(store[:match], message)]
        )
      end
    )
    {:noreply, state}
  end
end
