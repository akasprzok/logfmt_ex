defmodule ExampleApp do
  @moduledoc """
  A minimalistic Example Application that showcases how to use LogfmtEx.

  LogfmtEx should be added at the top of the list of children, so it is started before the application begins to emit logs.

  """

  use Application

  def start(_type, _args) do
    logfmt_ex_opts = Application.get_env(:logfmt_ex, :opts)

    children = [
      {LogfmtEx, logfmt_ex_opts},
      {Blabbermouth, [interval: {Enum, :random, [100..10_000]}]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
