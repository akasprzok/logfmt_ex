defmodule LogfmtEx do
  @moduledoc ~S"""
  A convenience for formatting logs in logfmt, to be used with the `Logger.Backends.Console` backend.

  To use, specify the `{LogfmtEx, :format}` tuple in the backend's configuration, replacing the format string:

      config :logger, :console,
        format: {LogfmtEx, :format}

  ## Logfmt

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

  ## Configuration

  Several aspects of the format function can be customized via the application env in a `config/config.exs` file,
  under `config :logfmt_ex, :opts`:

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

  alias LogfmtEx.Encoder

  @unix_epoch 62_167_219_200

  @default_level_key "level"
  @default_message_key "message"
  @default_timestamp_key "timestamp"
  @default_timestamp_format :elixir
  @default_format [:timestamp, :level, :message, :metadata]
  @node "node"

  @typedoc """
  Valid pattern keys. These mostly mimic the pattern keys in `Logger.Formatter`,
  though :time and :date are merged into :timestamp.
  """
  @type pattern_keys :: :timestamp | :level | :message | :metadata | :node

  @typedoc """
  A pattern is a list of valid pattern keys that determines in which order the key=value pairs are printed.
  It defaults to #{inspect(@default_format)}.
  """
  @type pattern :: list(pattern_keys())

  @doc """
  The main formatting function.

  It is invoked by the console backend with four arguments:

    * the log level: an atom (`t:atom/0`)
    * the message: this is usually `t:IO.chardata/0`
    * the current timestamp: a term of type `t:Logger.Formatter.time/0`
    * the metadata: a keyword list (`t:keyword/0`)

  May optionally be passed a list of options that is merged into the Application environment.
  """
  @spec format(Logger.level(), any(), Logger.Formatter.time(), Keyword.t()) :: IO.chardata()
  def format(level, message, {date, time}, metadata, opts \\ []) do
    opts = :logfmt_ex |> Application.get_env(:opts, []) |> Keyword.merge(opts)

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
