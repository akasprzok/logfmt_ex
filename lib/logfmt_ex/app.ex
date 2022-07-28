defmodule LogfmtEx.App do
  @moduledoc false
  use Application

  @doc false
  def start(_type, _args) do
    opts = Application.get_env(:logfmt_ex, :opts, [])

    children = [
      {LogfmtEx, opts}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
