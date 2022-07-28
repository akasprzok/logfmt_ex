defprotocol LogfmtEx.ValueEncoder do
  @moduledoc ~S"""
  Protocol for encoding data types.

  Example:

      defmodule User do
        defstruct [:email, :name, :id]

        defimpl LogfmtEx.ValueEncoder do
          def encode(user), do: to_string(user.id)
        end
      end

  If there is no protocol for a data type passed as metadata,
  then encoding will fall back to the `String.Chars` protocol.
  If that protocol isn't specified either, the formatter will fall
  back to `Kernel.inspect/1`.

  Note that the algebra documents produced by `Kernel.inspect/1`
  don't lend themselves to logfmt - this fallback is provided to
  minimize the chance that the formatter fails, instead making a
  "best effort" at producing usable output. It is recommended to
  implement either the `LogfmtEx.ValueEncoder` or `String.Chars` protocol
  for any data types that might find their way into your logs.
  """

  @fallback_to_any true
  @spec encode(term()) :: iodata()
  def encode(value)
end

defimpl LogfmtEx.ValueEncoder, for: BitString do
  def encode(str), do: str
end

defimpl LogfmtEx.ValueEncoder, for: Atom do
  def encode(atom), do: Atom.to_string(atom)
end

defimpl LogfmtEx.ValueEncoder, for: Integer do
  def encode(int), do: Integer.to_string(int)
end

defimpl LogfmtEx.ValueEncoder, for: Float do
  def encode(float), do: Float.to_string(float)
end

defimpl LogfmtEx.ValueEncoder, for: PID do
  def encode(pid), do: inspect(pid)
end

defimpl LogfmtEx.ValueEncoder, for: Reference do
  def encode(ref), do: inspect(ref)
end

defimpl LogfmtEx.ValueEncoder, for: Any do
  def encode(any) do
    to_string(any)
  rescue
    Protocol.UndefinedError -> inspect(any)
  end
end
