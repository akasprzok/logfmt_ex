defmodule LogfmtEx.Encoder do
  @moduledoc """
  Encodes key=value pairs in logfmt.

  Quotes values containing spaces and `=`. For example,
      Logger.info("I am a message with spaces", string: "key=value")

  will be encoded as

      message="I am a message with spaces" string="key=value"

  Escapes newlines, line breaks, backslashes, and carriage returns.
  """

  alias LogfmtEx.ValueEncoder

  @typedoc """
  Metadata keys are atoms.
  Message, timestamp, and level keys are strings.
  """
  @type key :: String.t() | atom()

  @delimiter ?=

  @doc """
  Encodes the given key and value into a key=value pair.
  Returns `t:iodata/0`, an efficient data type for creating large binaries from small chunks.

  A subset of keys from standard Elixir metadata are handled in special ways:
    * `:domain` - encoded using `inspect/1`
    * `:mfa` - formatted using `Exception.format_mfa/3`

  ## Options:

    * `:delimiter` - defaults to =
  """
  @spec encode(key(), term(), keyword()) :: iodata()
  def encode(key, value, opts \\ [])

  def encode(:domain, domain, opts) do
    delimiter = opts |> Keyword.get(:delimiter, @delimiter)

    [encode_key(:domain), delimiter, inspect(domain)]
  end

  def encode(:mfa, {m, f, a}, opts) do
    delimiter = opts |> Keyword.get(:delimiter, @delimiter)

    [encode_key(:mfa), delimiter, Exception.format_mfa(m, f, a)]
  end

  def encode(key, value, opts) do
    delimiter = opts |> Keyword.get(:delimiter, @delimiter)

    [encode_key(key), delimiter, encode_value(value)]
  rescue
    error -> "there was an error: #{inspect(error)}"
  end

  defp encode_value(""), do: ""

  defp encode_value(value) do
    value = value |> ValueEncoder.encode()

    case infer_quotes(value) do
      :unquoted -> value
      :quoted -> ["\"", value, "\""]
      :escaped -> ["\"", escape(value), "\""]
    end
  end

  defp infer_quotes(value), do: infer_quotes(value, :unquoted)
  defp infer_quotes(<<>>, acc), do: acc
  defp infer_quotes(<<" ", rest::binary>>, _acc), do: infer_quotes(rest, :quoted)
  defp infer_quotes(<<"\"", _rest::binary>>, _acc), do: :escaped
  defp infer_quotes(<<"=", rest::binary>>, _acc), do: infer_quotes(rest, :quoted)
  defp infer_quotes(<<"\\", rest::binary>>, :unquoted), do: infer_quotes(rest, :unquoted)
  defp infer_quotes(<<"\\", rest::binary>>, :quoted), do: infer_quotes(rest, :escaped)
  defp infer_quotes(<<_front, rest::binary>>, acc), do: infer_quotes(rest, acc)

  defp encode_key(key) when is_atom(key), do: Atom.to_string(key)
  defp encode_key(key) when is_bitstring(key), do: key

  defp escape(string),
    do: escape(string, "")

  defp escape("", acc), do: acc

  defp escape(<<"\t", rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\t">>)

  defp escape(<<"\n", rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\n">>)

  defp escape(<<"\r", rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\r">>)

  defp escape(<<"\"", rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\\"">>)

  defp escape(<<"\\", rest::binary>>, acc),
    do: escape(rest, <<acc::binary, "\\\\">>)

  defp escape(<<c, rest::binary>>, acc),
    do: escape(rest, <<acc::binary, c>>)
end
