defmodule PhantomTrain.Subscriber.SystemCommand do
  use GenServer

  def start_link(event_manager) do
    GenServer.start_link(__MODULE__, event_manager)
  end

  def subscribe(server, options) do
    GenServer.cast(server, {:subscribe, options})
  end

  defp message_loop(event_manager) do
    receive do
      {_port, {:data, message}} ->
        event_manager |> GenEvent.notify(message |> to_string)
        message_loop(event_manager)
      _ ->
        message_loop(event_manager)
    end
  end

  ## Server Callbacks
  def init(event_manager) do
    {:ok, %{msg_process: nil, event_manager: event_manager}}
  end

  def handle_cast({:subscribe, options}, state) do
    pid = spawn_link(fn ->
      Port.open(
        {:spawn, options[:command]},
        [:stderr_to_stdout, :in, :exit_status]
      )
      message_loop(state.event_manager)
    end)
    {:noreply, %{state | msg_process: pid}}
  end

  def terminate(_reason, state) do
    # TODO
    {:os_pid, opid} = state.port |> Port.info(:os_pid)
    :os.cmd("kill -9 #{opid}" |> String.to_char_list)
    :ok
  end
end
