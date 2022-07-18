defmodule LogfmtEx do
  @moduledoc ~S"""
  GenServer for persistent opts
  """

  use GenServer

  alias LogfmtEx.Formatter

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end

  @impl true
  def handle_call({:format, level, message, {date, time}, metadata}, _from, opts) do
    formatted_log = Formatter.format(level, message, {date, time}, metadata, opts)
    {:reply, formatted_log, opts}
  end

  @spec format(Logger.level(), any(), Logger.Formatter.time(), Keyword.t()) :: iodata()
  def format(level, message, {date, time}, metadata) do
    GenServer.call(__MODULE__, {:format, level, message, {date, time}, metadata})
  end
end
