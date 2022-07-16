import Logger
opts = Application.get_env(:logfmt_ex, :opts)
{:ok, pid} = LogfmtEx.start_link(opts)
