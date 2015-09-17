defmodule PhantomTrain.Subscriber do
  use GenServer

  def start_link(event_manager) do
    GenServer.start_link(
      __MODULE__,
      event_manager,
      []
    )
  end

  defp message_loop(event_manager) do
    receive do
      {port, {:data, message}} ->
        event_manager |> GenEvent.notify(message |> to_string)
        message_loop(event_manager)
      _ ->
        message_loop(event_manager)
    end
  end

  def subscribe(server) do
    GenServer.cast(server, {:subscribe, Application.get_env(:phantom_train, :input_stream)})
  end

  def stop(server) do
    GenServer.call(server, :stop)
  end

  ## Server Callbacks
  def init(event_manager) do
    {:ok, %{msg_process: nil, event_manager: event_manager}}
  end

  def handle_cast({:subscribe, input_stream}, state) do
    pid = spawn_link(fn ->
      port = Port.open(
        {:spawn, input_stream[:command]},
        [:stderr_to_stdout, :in, :exit_status]
      )
      message_loop(state.event_manager)
    end)
    {:noreply, %{state | msg_process: pid}}
  end

  def handle_call(:stop, _from, state) do
    # TODO:
    {:os_pid, opid} = state.port |> Port.info(:os_pid)
    :os.cmd("kill -9 #{opid}" |> String.to_char_list)
    {:stop, :normal, :ok, state}
  end
end
