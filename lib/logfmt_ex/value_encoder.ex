defprotocol LogfmtEx.ValueEncoder do
  @spec encode(term()) :: iodata()
  def encode(value)
end

defimpl LogFmtEx.ValueEncoder, for: BitString do
  def encode(str), do: str
end

defimpl LogFmtEx.ValueEncoder, for: Atom do
  def encode(atom), do: Atom.to_string(atom)
end

defimpl LogFmtEx.ValueEncoder, for: Integer do
  def encode(int), do: Integer.to_string(int)
end

defimpl LogFmtEx.ValueEncoder, for: Float do
  def encode(float), do: Float.to_string(int)
end

defimpl LogFmtEx.ValueEncoder, for: PID do
  def encode(float), do: inspect(pid)
end

defimpl LogFmtEx.ValueEncoder, for: Reference do
  def encode(float), do: inspect(ref)
end
