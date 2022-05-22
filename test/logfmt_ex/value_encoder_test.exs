defmodule LogfmtEx.ValueEncoderTest do
  use ExUnit.Case
  doctest LogfmtEx.ValueEncoder

  import LogfmtEx.ValueEncoder, only: [encode: 1]

  test "encodes BitString" do
    assert encode("foo") == "foo"
  end

  test "encodes Atom" do
    assert encode(:foo) == "foo"
  end

  test "encodes integer" do
    assert encode(1) == "1"
  end

  test "encodes float" do
    assert encode(1.2) == "1.2"
  end

  test "encodes PID" do
    pid = self()
    assert encode(pid) == inspect(pid)
  end

  test "encodes Reference" do
    ref = make_ref()
    value = inspect(ref)
    assert encode(ref) == value
  end
end
