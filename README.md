# LogfmtEx

Yet another logfmt log formatter for Elixir's :console logger backend.

In your app's logger configuration, specify the `LogfmtEx` module and its `format` function to be used to format your logs:

```elixir
config :logger, :console,
  format: {LogfmtEx, :format}
```

## Installation

The package can be installed
by adding `logfmt_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logfmt_ex, "~> 0.1.0"}
  ]
end
```

## Configuration

While the [library guidelines](https://hexdocs.pm/elixir/main/library-guidelines.html) discourages [application configuration](https://hexdocs.pm/elixir/main/library-guidelines.html#avoid-application-configuration), we have no way to pass a config to the formatter, so we have to rely on application config.

The following configuration options are available under `LogfmtEx, :opts`:

* `:delimiter` - defaults to `=`.
* `:format` - A list of atoms that defines the order in which key/value pairs will written to the log line. Defaults to `[:timestamp, :level, :message, :metadata]`. Valid parameters are
  * `:timestamp` - the timestamp of the log message
  * `:level` - the log level
  * `:message` - the log message itself
  * `:metadata` - metadata as key=value paris
  * `:node` - the node name
* `timestamp_key` - changes the key used for the timestamp field. Defaults to `timestamp`.
* `timestamp_format` - How the timestamp is formatted. Defaults to `:elixir`. The options are
  * `:elixir` - Uses the same formatting functions found in the standard elixir log formatter.
* `level_key` - the key used for the log level. Defaults to `level`.
* `message_key` - the key used for the message field. Defaults to `message`, but `msg` is a popular alternative.

An example configuration would then look like

```elixir
config :logger, :console,
  format: {LogfmtEx, :format},
  metadata: [:user_id, :pid, :file]

config LogfmtEx, :opts,
  format: [:level, :message, :node, :timestamp, :metadata],
  timestamp_key: "ts",
  message_key: "msg"
```

for which `Logger.info("I am a message", user_id: 123)` would ouput something along the lines of

```
level=info msg="I am a message" ts="12:38:38.055 1973-03-12" user_id=123 pid=#PID<0.223.0> file=test/logfmt_ex_test.exs\n
```


**Note**

When specifying a function for the `:console` logger's `:format` option, there is no way to pass in additional config, so these configuration options are read for every call to the logger.

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