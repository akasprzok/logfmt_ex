# logfmt_ex

A logfmt log formatter for Elixir's `:console` logger backend.

## Commands

```bash
mix test
mix format
mix credo
mix dialyzer
mix run benchmarks/throughput.exs
```

## Notes

- Custom struct encoding is done via the `LogfmtEx.ValueEncoder` protocol.
