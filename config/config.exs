import Config

config :logger, :console,
  format: {LogfmtEx, :format},
  metadata: [:pid, :mfa, :string, :integer, :float, :user_id, :bogons]

config :logger, utc_log: true
