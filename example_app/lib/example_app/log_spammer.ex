defmodule ExampleApp.LogSpammer do
  @moduledoc """
  A simple GenServer that periodically emits logs.
  """
  use GenServer
  require Logger

  @log_levels [:debug, :info, :warn, :error]
  @default_messages [
    "I am a message",
    "woah you won't believe what happened",
    "beep boop",
    "I'll be back!",
    "Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtag"
  ]
  @default_interval :timer.seconds(1)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    spam_log(opts)
    schedule_log(opts)

    {:ok, opts}
  end

  @impl true
  def handle_info(:log, opts) do
    spam_log(opts)
    schedule_log(opts)
    {:noreply, opts}
  end

  def spam_log(opts) do
    message =
      opts
      |> Keyword.get(:messages, @default_messages)
      |> Enum.random()

    @log_levels
    |> Enum.random()
    |> Logger.log(message, user_id: 123)

  end

  def schedule_log(opts) do
    interval = opts |> Keyword.get(:interval, @default_interval)
    Process.send_after(self(), :log, interval)
  end
end
