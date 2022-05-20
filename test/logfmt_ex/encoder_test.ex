defmodule LogfmtEx.EncoderTest do
  use ExUnit.Case
  doctest LogfmtEx.Encoder

  import LogfmtEx.Encoder, only: [encode: 2, encode: 3]

  test "encodes an unquoted kv pair" do
    assert encode("foo", "bar") == "foo=bar"
  end


end
