defmodule LogfmtEx.Encoder do
  @moduledoc """
  Encodes key/value pairs.
  """

  alias LogfmtEx.ValueEncoder

  @type key :: String.t() | atom()

  @delimiter ?=

  @spec encode(key(), term(), keyword()) :: iodata()
  def encode(key, value, opts \\ []) do
    delimiter = opts |> Keyword.get(:delimiter, @delimiter)

    [encode_key(key), delimiter, encode_value(value)]
  end

  defp encode_value(""), do: ~s("")

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
  defp infer_quotes(<<front, _rest::binary>>, _acc) when front <= 0x1F, do: :escaped
  defp infer_quotes(<<" ", rest::binary>>, _acc), do: infer_quotes(rest, :quoted)
  defp infer_quotes(<<"\"", _rest::binary>>, _acc), do: :escaped
  defp infer_quotes(<<"=", rest::binary>>, _acc), do: infer_quotes(rest, :quoted)
  defp infer_quotes(<<"\\", rest::binary>>, :unquoted), do: infer_quotes(rest, :unquoted)
  defp infer_quotes(<<"\\", rest::binary>>, :quoted), do: infer_quotes(rest, :escaped)
  defp infer_quotes(<<_front, rest::binary>>, acc), do: infer_quotes(rest, acc)

  defp encode_key(key) when is_atom(key), do: Atom.to_string(key)
  defp encode_key(key) when is_bitstring(key), do: key

  defp escape(value), do: value
end
