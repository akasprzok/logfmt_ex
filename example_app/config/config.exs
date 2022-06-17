import Config

config :logger, :console,
  format: {LogfmtEx, :format},
  metadata: [:user_id, :integer, :float, :string, :atom, :list, :tuple]

config :logfmt_ex, :opts,
  message_key: "msg",
  timestamp_format: :iso8601
