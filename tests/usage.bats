bats_require_minimum_version 1.5.0

@test "-h returns short usage" {
    run whatnext -h

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        Usage: whatnext [-h] [--help] [--version] [--dir DIR] [-s] [-a]
                        [--config CONFIG] [--ignore PATTERN] [-q] [-o] [-p] [-b] [-d]
                        [-c] [--priority LEVEL]
                        [match ...]
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "--help returns long usage" {
    run whatnext --help

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        Usage: whatnext [-h] [--help] [--version] [--dir DIR] [-s] [-a]
                        [--config CONFIG] [--ignore PATTERN] [-q] [-o] [-p] [-b] [-d]
                        [-c] [--priority LEVEL]
                        [match ...]

        List tasks found in Markdown files

        Positional arguments:
          match             Only include results from matching file(s), dir(s) or
                            where "match" is in the task text or heading

        Options:
          -h                Show the usage reminder and exit
          --help            Show this help message and exit
          --version         show program's version number and exit
          --dir DIR         Directory to search (default: current directory)
          -s, --summary     Show summary of task counts per file
          -a, --all         Include all tasks and files, not just incomplete
          --config CONFIG   Path to config file (default: .whatnext in search
                            directory)
          --ignore PATTERN  Ignore files matching pattern (can be specified multiple
                            times)
          -q, --quiet       Suppress warnings
          -o, --open        Show only open tasks
          -p, --partial     Show only in progress tasks
          -b, --blocked     Show only blocked tasks
          -d, --done        Show only completed tasks
          -c, --cancelled   Show only cancelled tasks
          --priority LEVEL  Show only tasks of this priority (can be specified
                            multiple times)

        Task States:
          - [ ]     Open (shown by default)
          - [/]     In progress (shown by default)
          - [<]     Blocked (shown by default)
          - [X]     Done (hidden by default)
          - [#]     Cancelled (hidden by default)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}
