defprotocol LogfmtEx.ValueEncoder do
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
