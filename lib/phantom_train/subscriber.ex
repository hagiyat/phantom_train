defmodule PhantomTrain.Subscriber do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      {opts[:host], opts[:port], opts[:password] || ""},
      []
    )
  end

  def subscribe(server, channel_name) do
    GenServer.cast(server, {:subscribe, channel_name})
  end

  defp message_loop do
    receive do
      msg ->
        IO.inspect msg
        message_loop
    end
  end

  ## Server Callbacks

  def init({host, port, password}) do
    client = Exredis.Sub.start(host, port, password)
    {:ok, client}
  end

  def handle_cast({:subscribe, channel_name}, client) do
    pid = spawn_link(fn -> message_loop end)
    client |> Exredis.Sub.subscribe(
      channel_name, fn(message) ->
        send(pid, message)
      end
    )
    {:noreply, client}
  end
end
