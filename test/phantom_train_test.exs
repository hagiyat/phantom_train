defmodule PhantomTrainTest do
  use ExUnit.Case, async: true

  setup do
    Application.put_env(
      :phantom_train,
      :subscriber,
      module: PhantomTrain.Subscriber.FileStream,
      path: "README.md"
    )
    {:ok, phantom_train} = PhantomTrain.start_link
    {:ok, phantom_train: phantom_train}
  end

  test "start_subscriber" do
    {:ok, manager} = GenEvent.start_link
    assert {:ok, _subscriber} = PhantomTrain.start_subscriber(manager)
  end
end
