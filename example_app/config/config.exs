import Config

config :logger, :console,
  format: {LogfmtEx, :format},
  metadata: [:user_id]

config LogfmtEx, :opts,
  message_key: "msg",
  timestamp_format: :iso8601
