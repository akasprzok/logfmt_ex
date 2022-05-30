defmodule ExampleApp do
  @moduledoc """
  Documentation for `ExampleApp`.
  """

  use Application

  def start(_type, _args) do
    children = [
      LogfmtEx,
      ExampleApp.LogSpammer
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
