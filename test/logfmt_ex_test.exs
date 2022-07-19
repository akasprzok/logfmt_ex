defmodule LogfmtExTest do
  use ExUnit.Case
  doctest LogfmtEx

  import LogfmtEx

  setup do
    time = {{1973, 3, 12}, {12, 38, 38, 55}}
    {:ok, time: time}
  end

  test "integration test", %{time: time} do
    assert format(:info, [["I"], " am a message", ?!], time, meta: "data")
           |> IO.iodata_to_binary() ==
             ~s(ts=1973-03-12T12:38:38.055 level=info msg="I am a message!" meta=data\n)
  end
end
