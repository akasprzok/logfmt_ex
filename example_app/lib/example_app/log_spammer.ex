defmodule ExampleApp.LogSpammer do
  @moduledoc """
  A simple GenServer that periodically emits logs.
  """
  use GenServer
  import Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    spam_log()

    {:ok, state}
  end

  @impl true
  def handle_info(:log, state) do
    Logger.log(:info, "I am a log message", [user_id: 123])
    spam_log()
    {:noreply, state}
  end

  def spam_log do
    Process.send_after(self(), :log, :timer.seconds(1))
  end

end
