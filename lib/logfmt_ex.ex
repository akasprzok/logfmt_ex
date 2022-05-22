defmodule LogfmtEx do
  @moduledoc """
  Formats logs in logfmt format.

  This module allows developers to specify a list of atoms that
  serves as template for log messages, for example:

  [:timestamp, :level, :message, :metadata]

  Will print an error message as:
    18:43:12 level=error message="oh no spaghettio" user_id=13

  The valid parameters you can use are:
    * :timestamp  The time and date the log message was sent
    * :message    The log message
    * :level      The log level
    * :node       The node that printed the message
    * :metadata   The metadata attached to the log

  """

  alias LogfmtEx.Encoder

  @type time :: {{1970..10000, 1..12, 1..31}, {0..23, 0..59, 0..59, 0..99}}
  @default_level_key "level"
  @default_message_key "message"
  @default_timestamp_key "timestamp"
  @default_timestamp_format :elixir
  @default_format [:timestamp, :level, :message, :metadata]
  @node "node"

  @type pattern_keys :: :timestamp | :level | :message | :metadata | :node
  @type pattern :: list(pattern_keys())

  @spec format(Logger.level(), any(), Logger.Formatter.time(), keyword()) :: iodata()
  def format(level, message, {date, time}, metadata) do
    opts = Application.get_env(__MODULE__, :opts, [])

    format(level, message, {date, time}, metadata, opts)
  end

  @spec format(Logger.level(), any(), Logger.Formatter.time(), keyword(), keyword()) :: iodata()
  def format(level, message, {date, time}, metadata, opts) do
    opts
    |> Keyword.get(:format, @default_format)
    |> Enum.each(&encode(&1, level, message, {date, time}, metadata, opts))
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
    |> Encoder.encode(message)
  end

  defp encode(:node, _level, _message, _date_time, _metadata, _opts),
    do: Encoder.encode(@node, node())

  defp encode(:metadata, _level, _message, _date_time, _metadata, _opts), do: "user_id=123"
end
