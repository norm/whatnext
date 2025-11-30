bats_require_minimum_version 1.5.0

@test "list tasks" {
    run --separate-stderr whatnext

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/prioritisation.md:
            # Prioritisation
            - [ ] super-urgent task
            # **do these first**
            - [ ] inherently high priority task, because of the header
            - [ ] no extra priority, still listed second

        docs/prioritisation.md:
            # Prioritisation
            - [ ] semi-urgent task

        sample.md:
            # Sample task file
            - [ ] Do something for the sake of it
        docs/basics.md:
            # Indicating the state of a task
            - [/] in progress, this task is partially complete
            - [ ] open, this task is outstanding
            - [<] blocked, this task needs more input
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        docs/prioritisation.md:
            # Prioritisation
            - [/] not a high priority task
            - [ ] top, but not urgent, task
        tests/headerless.md:
            - [ ] I am not a task, I am a free list!
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")

    expected_stderr="WARNING: ignoring invalid state '@' in 'no idea what this means',"
    expected_stderr+=" docs/basics.md line 12"
    diff -u <(echo "$expected_stderr") <(echo "$stderr")

    [ $status -eq 0 ]
}

@test "list tasks, changes width" {
    COLUMNS=40 run --separate-stderr whatnext

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/prioritisation.md:
            # Prioritisation
            - [ ] super-urgent task
            # **do these first**
            - [ ] inherently high priority task,
                  because of the header
            - [ ] no extra priority, still
                  listed second

        docs/prioritisation.md:
            # Prioritisation
            - [ ] semi-urgent task

        sample.md:
            # Sample task file
            - [ ] Do something for the sake of
                  it
        docs/basics.md:
            # Indicating the state of a task
            - [/] in progress, this task is
                  partially complete
            - [ ] open, this task is outstanding
            - [<] blocked, this task needs more
                  input
            # Indicating the state of a task /
              Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet,
                  consectetur adipisicing elit,
                  sed do eiusmod tempor
                  incididunt ut labore et dolore
                  magna aliqua.
            - [ ] Ut enim ad minim veniam,
        docs/prioritisation.md:
            # Prioritisation
            - [/] not a high priority task
            - [ ] top, but not urgent, task
        tests/headerless.md:
            - [ ] I am not a task, I am a free
                  list!
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "list all tasks" {
    run --separate-stderr whatnext -a

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/prioritisation.md:
            # Prioritisation
            - [ ] super-urgent task
            # **do these first**
            - [ ] inherently high priority task, because of the header
            - [ ] no extra priority, still listed second
            # **do these first** / grouped, but still highest priority
            - [X] header priority cascades down

        docs/prioritisation.md:
            # Prioritisation
            - [ ] semi-urgent task

        sample.md:
            # Sample task file
            - [ ] Do something for the sake of it
        docs/basics.md:
            # Indicating the state of a task
            - [/] in progress, this task is partially complete
            - [ ] open, this task is outstanding
            - [<] blocked, this task needs more input
            - [X] complete, this task has been finished
            - [#] cancelled, this task has been scratched
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        docs/prioritisation.md:
            # Prioritisation
            - [/] not a high priority task
            - [ ] top, but not urgent, task
            # more tasks
            - [#] normal priority, new header resets that
        tests/headerless.md:
            - [ ] I am not a task, I am a free list!
        archive/done/tasks.md:
            # Some old stuff
            - [X] Do the first thing
            - [X] Do the second thing
            - [X] do the last thing all lowercase
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "list tasks with --dir" {
    cp -r . "$BATS_TEST_TMPDIR/project"

    run --separate-stderr whatnext --dir "$BATS_TEST_TMPDIR/project"

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/prioritisation.md:
            # Prioritisation
            - [ ] super-urgent task
            # **do these first**
            - [ ] inherently high priority task, because of the header
            - [ ] no extra priority, still listed second

        docs/prioritisation.md:
            # Prioritisation
            - [ ] semi-urgent task

        sample.md:
            # Sample task file
            - [ ] Do something for the sake of it
        docs/basics.md:
            # Indicating the state of a task
            - [/] in progress, this task is partially complete
            - [ ] open, this task is outstanding
            - [<] blocked, this task needs more input
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        docs/prioritisation.md:
            # Prioritisation
            - [/] not a high priority task
            - [ ] top, but not urgent, task
        tests/headerless.md:
            - [ ] I am not a task, I am a free list!
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "warnings suppressed with --quiet" {
    run --separate-stderr whatnext --quiet
    [ $status -eq 0 ]
    [ -z "$stderr" ]
}

@test "warnings suppressed with WHATNEXT_QUIET=1" {
    WHATNEXT_QUIET=1 run --separate-stderr whatnext
    [ $status -eq 0 ]
    [ -z "$stderr" ]
}

@test "--open filters to open tasks" {
    run --separate-stderr whatnext --open docs/basics.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task
            - [ ] open, this task is outstanding
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # short flag
    run --separate-stderr whatnext -o docs/basics.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "--partial filters to in progress tasks" {
    run --separate-stderr whatnext --partial docs/basics.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task
            - [/] in progress, this task is partially complete
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # short flag
    run --separate-stderr whatnext -p docs/basics.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "--blocked filters to blocked tasks" {
    run --separate-stderr whatnext --blocked docs/basics.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task
            - [<] blocked, this task needs more input
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # short flag
    run --separate-stderr whatnext -b docs/basics.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "--done filters to completed tasks" {
    run --separate-stderr whatnext --done docs/basics.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task
            - [X] complete, this task has been finished
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # short flag
    run --separate-stderr whatnext -d docs/basics.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "--cancelled filters to cancelled tasks" {
    run --separate-stderr whatnext --cancelled docs/basics.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task
            - [#] cancelled, this task has been scratched
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # short flag
    run --separate-stderr whatnext -c docs/basics.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "state filters can be combined" {
    run --separate-stderr whatnext -bc docs/basics.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task
            - [<] blocked, this task needs more input
            - [#] cancelled, this task has been scratched
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    run --separate-stderr whatnext -op docs/basics.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task
            - [/] in progress, this task is partially complete
            - [ ] open, this task is outstanding
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    run --separate-stderr whatnext -bcdop docs/basics.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task
            - [/] in progress, this task is partially complete
            - [ ] open, this task is outstanding
            - [<] blocked, this task needs more input
            - [X] complete, this task has been finished
            - [#] cancelled, this task has been scratched
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "state filter combines with search" {
    run --separate-stderr whatnext --open lorem docs/basics.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}
