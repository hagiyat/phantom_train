defmodule PhantomTrain.Storer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      opts,
      []
    )
  end

  def init(opts) do
    {:ok, manager} = GenEvent.start_link
    {:ok, subscriber} = PhantomTrain.Subscriber.start_link(
      manager, Application.get_env(Exredis, :redis_host)
    )
    subscriber |> PhantomTrain.Subscriber.subscribe("test_channel")
    GenEvent.add_mon_handler(manager, PhantomTrain.Forwarder, self)

    event_stream = spawn_link fn ->
      for v <- GenEvent.stream(manager), do: store(v)
    end

    {:ok, %{event_manager: manager, subscriber: subscriber, event_stream: event_stream}}
  end

  defp store(message) do
    IO.inspect("in storer:#{message}")
  end
end
