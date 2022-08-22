defmodule LogfmtEx.EncoderTest do
  use ExUnit.Case
  doctest LogfmtEx.Encoder

  import LogfmtEx.Encoder, only: [encode: 2, encode: 3]

  test "encodes an unquoted kv pair" do
    assert encode("foo", "bar") |> IO.iodata_to_binary() == "foo=bar"
  end

  test "can use other delimiters via opts" do
    assert encode(:domain, [:elixir], delimiter: ?:) |> IO.iodata_to_binary() ==
             "domain:[:elixir]"
  end

  test "encodes an empty string" do
    assert encode(:empty, "") |> IO.iodata_to_binary() == ~s(empty=)
  end

  test "encodes quoted values" do
    assert encode("foo", "bar bar") |> IO.iodata_to_binary() == ~s(foo="bar bar")
  end

  test "escapes stuff" do
    assert encode("foo", "bar\t\n\r\"\\bar") |> IO.iodata_to_binary() ==
             ~s(foo="bar\\t\\n\\r\\"\\\\bar")
  end

  test "encodes domain" do
    assert encode(:mfa, {Module, :function, 1}) |> IO.iodata_to_binary() ==
             ~s(mfa=Module.function/1)
  end
end
