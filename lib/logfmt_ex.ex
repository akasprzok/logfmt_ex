defmodule LogfmtEx do
  @moduledoc ~S"""
  A convenience for formatting logs in logfmt.

  In logfmt, each line consists of a single level of key=value
  pairs, densely packed together.

  For example:
      Logger.info("I am a message", user_id: 123)

  given the configuration

      config :logger, :console,
        format: {LogfmtEx, :format},
        metadata: [:user_id, :pid, :file]

      config :logfmt_ex, :opts,
        message_key: "msg",
        timestamp_key: "ts",
        timestamp_format: :iso8601


  would emit:

      level=info msg="I am a message" ts="12:38:38.055 1973-03-12" user_id=123 pid=#PID<0.223.0> file=myapp/some_module.exs

  The valid configuration parameters are:

  * `:delimiter` - defaults to `=`.
  * `:format` - A list of atoms that defines the order in which key/value pairs will written to the log line. Defaults to `[:timestamp, :level, :message, :metadata]`. Valid parameters are
    * `:timestamp` - the timestamp of the log message
    * `:level` - the log level
    * `:message` - the log message itself
    * `:metadata` - metadata as key=value paris
    * `:node` - the node name
  * `timestamp_key` - changes the key used for the timestamp field. Defaults to `timestamp`.
  * `timestamp_format` - How the timestamp is formatted. Defaults to `:elixir`. The options are
    * `:elixir` - Uses the same formatting functions found in the standard elixir log formatter. Example: `"12:38:38.055 1973-03-12"`
    * `:epoch_seconds` - outputs an integer representing the number of seconds elapsed since January 1, 1970. Only useful for applications that emit logs sporadically.
    * `:iso8601` - Formats the timestamp according to ISO8601-2019. Example: `2000-02-29T23:00:07`
  * `level_key` - the key used for the log level. Defaults to `level`.
  * `message_key` - the key used for the message field. Defaults to `message`, but `msg` is a popular alternative.

  For encoding your own structs and types, see the `LogfmtEx.ValueEncoder` protocol.

  """

  use GenServer

  alias LogfmtEx.Encoder

  @unix_epoch 62_167_219_200

  @default_level_key "level"
  @default_message_key "message"
  @default_timestamp_key "timestamp"
  @default_timestamp_format :elixir
  @default_format [:timestamp, :level, :message, :metadata]
  @node "node"

  @type pattern_keys :: :timestamp | :level | :message | :metadata | :node
  @type pattern :: list(pattern_keys())

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end

  @impl true
  def handle_call({:format, level, message, {date, time}, metadata}, _from, opts) do
    formatted_log = format(level, message, {date, time}, metadata, opts)
    {:reply, formatted_log, opts}
  end

  @spec format(Logger.level(), any(), Logger.Formatter.time(), Keyword.t()) :: iodata()
  def format(level, message, {date, time}, metadata) do
    GenServer.call(__MODULE__, {:format, level, message, {date, time}, metadata})
  end

  @spec format(Logger.level(), any(), Logger.Formatter.time(), Keyword.t(), Keyword.t()) ::
          iodata()
  def format(level, message, {date, time}, metadata, opts \\ []) do
    opts
    |> Keyword.get(:format, @default_format)
    |> Enum.map(&encode(&1, level, message, {date, time}, metadata, opts))
    |> Enum.intersperse(" ")
    |> add_newline()
  end

  @spec format_time({0..23, 0..59, 0..59, 0..999}) :: IO.chardata()
  defp format_time({hh, mi, ss, ms}) do
    [pad2(hh), ?:, pad2(mi), ?:, pad2(ss), ?., pad3(ms)]
  end

  defp format_date({yy, mm, dd}) do
    [Integer.to_string(yy), ?-, pad2(mm), ?-, pad2(dd)]
  end

  defp pad2(int) when int < 10, do: [?0, Integer.to_string(int)]
  defp pad2(int), do: Integer.to_string(int)

  defp pad3(int) when int < 10, do: [?0, ?0, Integer.to_string(int)]
  defp pad3(int) when int < 100, do: [?0, Integer.to_string(int)]
  defp pad3(int), do: Integer.to_string(int)

  defp add_newline(log) do
    [log | "\n"]
  end

  defp encode_timestamp(:elixir, {time, date}) do
    [format_time(time), " ", format_date(date)]
  end

  defp encode_timestamp(:iso8601, date_and_time) do
    date_and_time |> to_datetime() |> NaiveDateTime.to_iso8601()
  end

  defp encode_timestamp(:epoch_seconds, date_and_time) do
    {seconds, _microseconds} =
      date_and_time |> to_datetime() |> NaiveDateTime.to_gregorian_seconds()

    seconds - @unix_epoch
  end

  defp to_datetime({{hour, minute, second, millisecond}, {year, month, day}}) do
    date = Date.new!(year, month, day)
    time = Time.new!(hour, minute, second, {millisecond * 1000, 3})
    NaiveDateTime.new!(date, time)
  end

  defp encode(:timestamp, _level, _message, {date, time}, _metadata, opts) do
    timestamp_key = opts |> Keyword.get(:timestamp_key, @default_timestamp_key)

    timestamp =
      opts
      |> Keyword.get(:timestamp_format, @default_timestamp_format)
      |> encode_timestamp({time, date})

    Encoder.encode(timestamp_key, timestamp)
  end

  defp encode(:level, level, _message, _date_time, _metadata, opts) do
    opts
    |> Keyword.get(:level_key, @default_level_key)
    |> Encoder.encode(level)
  end

  defp encode(:message, _level, message, _date_time, _metadata, opts) do
    opts
    |> Keyword.get(:message_key, @default_message_key)
    # find a better way to handle IOData input for message.
    # Maybe all these encode functions should live in encoder.ex
    |> Encoder.encode(message |> IO.iodata_to_binary())
  end

  defp encode(:node, _level, _message, _date_time, _metadata, _opts),
    do: Encoder.encode(@node, node())

  defp encode(:metadata, _level, _message, _date_time, metadata, opts) do
    metadata
    |> Enum.map(fn {key, value} -> Encoder.encode(key, value, opts) end)
    |> Enum.intersperse(" ")
  end
end
