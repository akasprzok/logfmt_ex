import Config

config :logger, :console,
  format: {LogfmtEx, :format},
  metadata: [:user_id, :pid, :mfa]
