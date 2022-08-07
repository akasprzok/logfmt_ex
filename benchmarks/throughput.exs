message = "I am a log message of some length"


# "\n$time $metadata[$level] $message\n"
default_pattern = Logger.Formatter.compile(nil)
timestamp = {{1977, 01, 28}, {13, 29, 00, 000}}

three_metadata = [user_id: 123, float: 1.234, string: "I am a string"]
six_metadata = three_metadata ++ [ref: make_ref(), pid: self(), atom: :econnrefused]

Benchee.run(
    %{
        "logger" => fn metadata -> Logger.Formatter.format(default_pattern, :info, message, timestamp, metadata) end,
        "logfmt" => fn metadata -> LogfmtEx.format(:info, message, timestamp, metadata) end,
    },
    inputs: %{
        "no_metadata" => [],
        "little_metadata" => three_metadata,
        "lots_metadata" => six_metadata
    },
    warmup: 1,
    time: 5,
    memory_time: 5,
    reduction_time: 2
)