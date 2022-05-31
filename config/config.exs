import Config

if Mix.env() == :dev do
  config :git_hooks,
    auto_install: true,
    verbose: true,
    hooks: [
      pre_commit: [
        tasks: [
          {:cmd, "mix compile --warnings-as-errors"},
          {:mix_task, :credo, ["--strict"]},
          {:mix_task, :test},
          {:mix_task, :format}
        ]
      ]
    ]
end
