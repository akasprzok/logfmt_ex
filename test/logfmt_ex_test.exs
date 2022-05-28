defmodule LogfmtExTest do
  use ExUnit.Case
  doctest LogfmtEx

  import LogfmtEx, only: [format: 4, format: 5]

  setup do
    time = {{1973, 3, 12}, {12, 38, 38, 55}}
    {:ok, time: time}
  end

  test "encodes the level", %{time: time} do
    assert format(:info, "I won't be printed", time, [i_wont: "be_printed"], format: [:level])
           |> IO.iodata_to_binary() ==
             "level=info\n"
  end

  test "encodes the timestamp", %{time: time} do
    assert format(:doesntmatter, "I won't be printed", time, [barbara: "streisand"],
             format: [:timestamp]
           )
           |> IO.iodata_to_binary() ==
             ~s(timestamp="12:38:38.055 1973-03-12"\n)
  end

  test "encodes the message", %{time: time} do
    message =
      "quirked up white boy with a little bit of swag busts it down coding style.. is he goated with the sauce?"

    assert format(:error, message, time, [meta: "data"], format: [:message])
           |> IO.iodata_to_binary() == "message=\"" <> message <> "\"\n"
  end

  test "encodes basic metadata", %{time: time} do
    ref = make_ref()
    string = "a thing!"
    pid = self()

    assert format(
             :huzzah,
             "really thoughtful thoughts",
             time,
             [bitstring: string, atom: :atom, integer: 1, float: 1.2, pid: pid, reference: ref],
             format: [:metadata]
           )
           |> IO.iodata_to_binary() ==
             "bitstring=\"a thing!\" atom=atom integer=1 float=1.2 pid=" <>
               inspect(pid) <> " reference=" <> inspect(ref) <> "\n"
  end

  test "encodes node", %{time: time} do
    node = node()

    assert format(
             :huzzah,
             "really thoughtful thoughts",
             time,
             [user_id: 123],
             format: [:node]
           )
           |> IO.iodata_to_binary() == "node=" <> Atom.to_string(node) <> "\n"
  end

  test "encodes the whole owl", %{time: time} do
    ref = make_ref()
    string = "a thing!"
    pid = self()

    assert format(
             :huzzah,
             "really thoughtful thoughts",
             time,
             bitstring: string,
             atom: :atom,
             integer: 1,
             float: 1.2,
             pid: pid,
             reference: ref
           )
           |> IO.iodata_to_binary() ==
             ~s(timestamp=\"12:38:38.055 1973-03-12\" level=huzzah message=\"really thoughtful thoughts\" bitstring=\"a thing!\" atom=atom integer=1 float=1.2 pid=) <>
               inspect(pid) <> " reference=" <> inspect(ref) <> "\n"
  end

  test "README example", %{time: time} do
    pid = self()

    assert format(
             :info,
             "I am a message",
             time,
             [user_id: 123, pid: pid, file: "test/logfmt_ex_test.exs"],
             format: [:level, :message, :timestamp, :metadata],
             timestamp_key: "ts",
             message_key: "msg"
           )
           |> IO.iodata_to_binary() ==
             ~s(level=info msg=\"I am a message\" ts=\"12:38:38.055 1973-03-12\" user_id=123 pid=) <>
               inspect(pid) <> " file=test/logfmt_ex_test.exs\n"
  end
end
