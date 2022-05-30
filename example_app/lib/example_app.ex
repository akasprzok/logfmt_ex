defmodule ExampleApp do
  @moduledoc """
  A minimalistic Example Application that showcases how to use LogfmtEx.

  LogfmtEx should be added at the top of the list of children, so it is started before the application begins to emit logs.

  """

  use Application

  def start(_type, _args) do
    children = [
      {LogfmtEx, Application.get_env(LogfmtEx, :opts)},
      ExampleApp.LogSpammer
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
