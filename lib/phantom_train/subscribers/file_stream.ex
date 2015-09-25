defmodule PhantomTrain.Subscriber.FileStream do
  use GenServer

  def start_link(event_manager) do
    GenServer.start_link(__MODULE__, event_manager)
  end

  def subscribe(server, options) do
    GenServer.cast(server, {:subscribe, options})
  end

  ## Server Callbacks
  def init(event_manager) do
    {:ok, %{msg_process: nil, event_manager: event_manager}}
  end

  def handle_cast({:subscribe, options}, state) do
    pid = spawn_link(fn ->
      File.stream!(options[:path])
      |> Stream.map(
        fn(line) ->
          state.event_manager |> GenEvent.notify(line |> String.strip)
        end)
      |> Stream.run
    end)
    {:noreply, %{state | msg_process: pid}}
  end
end
