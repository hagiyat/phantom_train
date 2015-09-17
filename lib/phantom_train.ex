defmodule PhantomTrain do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    {:ok, manager} = GenEvent.start_link
    GenEvent.add_mon_handler(manager, PhantomTrain.Forwarder, self)
    event_stream = spawn_link fn ->
      for v <- GenEvent.stream(manager), do: store(v)
    end

    {:ok, subscriber} = PhantomTrain.Subscriber.start_link(manager)
    subscriber |> PhantomTrain.Subscriber.subscribe

    {:ok, %{event_manager: manager, subscriber: subscriber, event_stream: event_stream}}
  end

  def test(server) do
    GenServer.cast(server, :test)
  end

  def handle_cast(:test, state) do
    require IEx; IEx.pry
    {:noreply, state}
  end

  defp store(message) do
    IO.inspect("in storer:#{message}")
  end
end
