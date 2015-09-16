defmodule PhantomTrain.PollingAgent do
  def start_link do
    Agent.start_link(fn ->
      redis_conf = Application.get_env(Exredis, :redis_host)
      redis = case redis_conf |> is_list do
        true ->
          Exredis.start(
            redis_conf[:host],
            redis_conf[:port] || 6379,
            redis_conf[:database] || 1,
            redis_conf[:password] || ""
          )
        _ ->
          Exredis.start
      end
      {:ok, redis}
    end)
  end

  def get(redis) do
    require IEx; IEx.pry
    #Agent.get(redis, &Exredis.API
  end
end
