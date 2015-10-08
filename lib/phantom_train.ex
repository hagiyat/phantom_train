defmodule PhantomTrain do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    {:ok, manager} = GenEvent.start_link
    GenEvent.add_mon_handler(manager, PhantomTrain.Forwarder, self)

    stores = Application.get_env(:phantom_train, :stores)
    {:ok, deliverer_module, deliverer} = start_deliverer(stores)

    event_stream = spawn_link fn ->
      for v <- GenEvent.stream(manager), do: deliver(v, deliverer_module, deliverer)
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

  def start_deliverer(stores) do
    [{:module, deliverer_module} | _options] = Application.get_env(:phantom_train, :deliverer)
    {:ok, deliverer} = deliverer_module.start_link(stores)
    {:ok, deliverer_module, deliverer}
  end

  defp deliver(message, deliverer_module, deliverer) do
    deliverer_module.deliver(deliverer, message)
  end
end
