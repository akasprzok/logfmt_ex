![main](https://github.com/akasprzok/logfmt_ex/actions/workflows/main.yml/badge.svg?branch=main)
[![Hex](https://img.shields.io/hexpm/v/logfmt_ex.svg)](https://hex.pm/packages/logfmt_ex/)
[![Hex Docs](https://img.shields.io/badge/hex-docs-informational.svg)](https://hexdocs.pm/logfmt_ex/)
![License](https://img.shields.io/hexpm/l/logfmt_ex)
[![Coverage Status](https://coveralls.io/repos/github/akasprzok/logfmt_ex/badge.svg?branch=main)](https://coveralls.io/github/akasprzok/logfmt_ex?branch=main)

# LogfmtEx

A log formatter for the logfmt format popularized by Heroku.


```elixir
Logger.info("I am a message", user_id: 123)
```
```
level=info msg="I am a message" ts="12:38:38.055 1973-03-12" user_id=123 pid=#PID<0.223.0> file=test/logfmt_ex_test.exs
```

## Installation

The package can be installed
by adding `logfmt_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logfmt_ex, "~> 0.4"}
  ]
end
```

In your app's logger configuration, specify the `LogfmtEx` module and its `format` function to be used to format your logs:

```elixir
config :logger, :console,
  format: {LogfmtEx, :format}
```

You can customize the formatting in your config:

```elixir
config :logfmt_ex, :opts,
  message_key: "msg",
  timestamp_key: "ts",
  timestamp_format: :iso8601
```

## Configuration

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
  * `:epoch_seconds` - outputs an integer representing the number of seconds elapsed since January 1, 1970. Only useful for applications that emit logs sporadically.
  * `:iso8601` - Formats the timestamp according to ISO8601-2019. Example: `2000-02-29T23:00:07`
* `level_key` - the key used for the log level. Defaults to `level`.
* `message_key` - the key used for the message field. Defaults to `message`, but `msg` is a popular alternative.


## Encoding

Structs can be encoded via the `ValueEncoder` protocol.

```elixir
defmodule User do
  defstruct [:email, :name, :id]

  defimpl LogfmtEx.ValueEncoder do
    @doc """
    As we don't want to leak PII into our logs, we encode the struct to just the user's ID.
    """
    def encode(user), do: to_string(user.id)
  end
```

Types for which the protocol is not implemented will fall back to the `to_string/1` function in the `String.Chars` protocol.
If the term being encoded does not implement that protocol, the formatter will fall back to the `Inspect` protocol.

Note that the algebra documents produced by `Kernel.inspect/1` don't lend themselves to logfmt - this fallback is provided to minimize the chance that the formatter fails, instead making a "best effort" at producing usable output. It is recommended to implement either the `LogfmtEx.ValueEncoder` or `String.Chars` protocol for any data structures that might find their way into your logs.

## Testing and Development

This library uses [asdf](https://asdf-vm.com) to manage runtime versions of Elixir and Erlang.
Contributions, issues, and all other feedback is more than welcome!

## Benchmarks

the `/benchmarks` folder includes benchmarks comparing `LogfmtEx` to `Logger.Formatter`.

You can run them with `mix run benchmarks/throughput.exs`.

## Alternatives

LogfmtEx is a simple logfmt formatter specifically for the Elixir console backend.
If you're looking for a library to encode and decode logfmt, take a look at [logfmt-elixir](https://github.com/jclem/logfmt-elixir) instead.
