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

    {:ok, subscriber} = start_subscriber(manager)

    {:ok, %{event_manager: manager, subscriber: subscriber, event_stream: event_stream}}
  end

  def start_subscriber(event_manager) do
    [{:module, subscriber_module} | options] = Application.get_env(:phantom_train, :subscriber)

    {:ok, subscriber} = subscriber_module.start_link(event_manager)
    subscriber |> subscriber_module.subscribe(options)

    {:ok, subscriber}
  end

  defp store(message) do
    IO.inspect("in storer:#{message}")
  end
end
