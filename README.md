![main](https://github.com/akasprzok/logfmt_ex/actions/workflows/main.yml/badge.svg?branch=main)
[![Hex](https://img.shields.io/hexpm/v/logfmt_ex.svg)](https://hex.pm/packages/logfmt_ex/)
[![Hex Docs](https://img.shields.io/badge/hex-docs-informational.svg)](https://hexdocs.pm/logfmt_ex/)
![License](https://img.shields.io/hexpm/l/logfmt_ex)


# LogfmtEx

A log formatter for the logfmt format popularized by Heroku.

## Installation

The package can be installed
by adding `logfmt_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logfmt_ex, "~> 0.2"}
  ]
end
```

In your app's logger configuration, specify the `LogfmtEx` module and its `format` function to be used to format your logs:

```elixir
config :logger, :console,
  format: {LogfmtEx, :format}
```

Additionally, add `LogfmtEx` to your `application.ex` with any [Configuration](#configuration) values as additional options.

```elixir
defmodule MyApp do
  use Application

  def start(_type, _args) do
    children = [
      # first entry, so formatter is available to all following modules.
      {LogfmtEx, [message_key: "msg", timestamp_format: :iso8601],
      MyApp.Web,
      MyApp.CoolThing,
      ...
```

## Configuration

The following options are available to be passed to Logfmt.start_link/1:

* `:delimiter` - defaults to `=`.
* `:format` - A list of atoms that defines the order in which key/value pairs will written to the log line. Defaults to `[:timestamp, :level, :message, :metadata]`. Valid parameters are
  * `:timestamp` - the timestamp of the log message
  * `:level` - the log level
  * `:message` - the log message itself
  * `:metadata` - metadata as key=value paris
  * `:node` - the node name
* `timestamp_key` - changes the key used for the timestamp field. Defaults to `timestamp`.
* `timestamp_format` - How the timestamp is formatted. Defaults to `:elixir`. The options are
  * `:elixir` - Uses the same formatting functions found in the standard elixir log formatter. Example: `"12:38:38.055 1973-03-12"`
  * `:iso8601` - Formats the timestamp according to ISO8601-2019. Example: `2000-02-29T23:00:07`
* `level_key` - the key used for the log level. Defaults to `level`.
* `message_key` - the key used for the message field. Defaults to `message`, but `msg` is a popular alternative.

If you want to use application configuration for the logger, you can easily pull in the formatting options:

config.exs:
```elixir
config :logger, :console,
  format: {LogfmtEx, :format},
  metadata: [:user_id, :pid, :file]

config LogfmtEx, :opts,
  format: [:level, :message, :node, :timestamp, :metadata],
  timestamp_key: "ts",
  message_key: "msg"
```

application.ex:
```elixir
defmodule MyApp do

  use Application

  def start(_type, _args) do
    children = [
      {LogfmtEx, Application.get_env(LogfmtEx, :opts)},
      MyApp.Web
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

for which `Logger.info("I am a message", user_id: 123)` would ouput something along the lines of

```
level=info msg="I am a message" ts="12:38:38.055 1973-03-12" user_id=123 pid=#PID<0.223.0> file=test/logfmt_ex_test.exs\n
```

## Encoding

Structs can be encoded via the [LogfmtEx.ValueEncoder](lib/logfmt_ex/value_encoder.ex) protocol.

```elixir
  defimpl LogfmtEx.ValueEncoder, for: Regex do
    def encode(regex), do: inspect(regex)
  end
```

## Testing and Development

This library uses [asdf](https://asdf-vm.com) to manage runtime versions of Elixir and Erlang.

## Alternatives

LogfmtEx is a simple logfmt formatter specifically for the Elixir console backend.
If you're looking for a library to encode and decode logfmt, take a look at [logfmt-elixir](https://github.com/jclem/logfmt-elixir) instead.
