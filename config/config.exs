import Config

config :logger, :console,
  format: {LogfmtEx, :format},
  metadata: [:pid, :mfa, :string, :integer, :float]

config :logger, utc_log: true

config :logfmt_ex, :opts,
  message_key: "msg",
  timestamp_key: "ts",
  timestamp_format: :iso8601
