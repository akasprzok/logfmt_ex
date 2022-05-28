import Config

if Mix.env() != :prod do
  config :git_hooks,
    auto_install: true,
    verbose: true,
    hooks: [
      pre_commit: [
        tasks: [
          {:mix_task, :format}
        ]
      ],
      pre_push: [
        tasks: [
          {:mix_task, :compile, ["--warnings-as-errors"]},
          {:mix_task, :credo, ["--strict"]},
          {:mix_task, :test}
        ]
      ]
    ],
    extra_success_returns: [
      {:ok, []}
    ]
end
