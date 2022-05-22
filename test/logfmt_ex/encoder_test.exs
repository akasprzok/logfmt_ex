defmodule LogfmtEx.EncoderTest do
  use ExUnit.Case
  doctest LogfmtEx.Encoder

  import LogfmtEx.Encoder, only: [encode: 2, encode: 3]

  test "encodes an unquoted kv pair" do
    assert encode("foo", "bar") |> IO.iodata_to_binary == "foo=bar"
  end

  test "can use other delimiters via opts" do
    assert encode("foo", "bar", [delimiter: ?:]) |> IO.iodata_to_binary == "foo:bar"
  end

  test "encodes an empty string" do
    assert encode(:empty, "") |> IO.iodata_to_binary == ~s(empty="")
  end
end
