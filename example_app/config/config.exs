import Config

config :logger, :console,
  format: {LogfmtEx, :format},
  metadata: [:user_id, :integer, :float, :fallback, :unimplemented]

config :logfmt_ex, :opts,
  message_key: "msg",
  timestamp_format: :iso8601
