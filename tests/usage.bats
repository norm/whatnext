@test "-h returns short usage" {
    run whatnext -h

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        Usage: whatnext [-h] [--help] [--dir DIR] [-s] [-a] [--config CONFIG]
                        [--ignore PATTERN]
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "--help returns long usage" {
    run whatnext --help

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        Usage: whatnext [-h] [--help] [--dir DIR] [-s] [-a] [--config CONFIG]
                        [--ignore PATTERN]

        List tasks found in Markdown files

        Options:
          -h                Show the usage reminder and exit
          --help            Show this help message and exit
          --dir DIR         Directory to search (default: current directory)
          -s, --summary     Show summary of task counts per file
          -a, --all         Include all tasks and files, not just incomplete
          --config CONFIG   Path to config file (default: .whatnext in search
                            directory)
          --ignore PATTERN  Ignore files matching pattern (can be specified multiple
                            times)

        Task States:
          - [ ]     Not started (shown by default)
          - [X]     Done (hidden by default, use --all)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}
