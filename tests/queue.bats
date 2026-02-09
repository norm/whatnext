bats_require_minimum_version 1.5.0

@test "a @queue file shows only one task" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                example/projects/fountain.md

    expected_output=$(sed -e 's/^        //' <<-'EOF'
        example/projects/fountain.md:
            - [ ] nigredo, the blackening or melanosis
	EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "a directory listing" {
    run --separate-stderr \
        whatnext \
            tests/queue

    expected_output=$(sed -e 's/^        //' <<-'EOF'
        prioritised.md:
            # HIGH
            Highest priority open task shown.
            - [ ] high priority task

        blocked.md:
            Falls back to blocked when no open tasks.
            - [<] blocked task
        in-progress.md:
            More than one in-progress tasks shows all.
            - [/] first in progress
            - [/] second in progress
        normal.md:
            A normal task file with multiple tasks.
            - [ ] first task
            - [ ] second task
	EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "queue shows nothing when all complete" {
    run --separate-stderr \
        whatnext \
            tests/queue/all-complete.md

    [ "$output" = "" ]
    [ $status -eq 0 ]
}
