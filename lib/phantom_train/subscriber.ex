defmodule PhantomTrain.Subscriber do
  use GenServer

  def start_link(event_manager, opts) do
    GenServer.start_link(
      __MODULE__,
      {event_manager, opts[:host], opts[:port], opts[:password] || ""},
      []
    )
  end

  def subscribe(server, channel_name) do
    GenServer.cast(server, {:subscribe, channel_name})
  end

  defp message_loop(event_manager) do
    receive do
      {:message, _channel_name, msg, _from} ->
        GenEvent.notify(event_manager, msg)
        message_loop(event_manager)
      {:subscribed, channel_name, _from} ->
        # TODO: logger
        message_loop(event_manager)
      _ ->
        message_loop(event_manager)
    end
  end

  ## Server Callbacks
  def init({event_manager, host, port, password}) do
    client = Exredis.Sub.start(host, port, password)
    {:ok, %{client: client, event_manager: event_manager}}
  end

  def handle_cast({:subscribe, channel_name}, state) do
    pid = spawn_link(fn -> message_loop(state.event_manager) end)
    state.client
    |> Exredis.Sub.subscribe(
      channel_name, fn(message) ->
        send(pid, message)
      end
    )
    {:noreply, state}
  end
end
