@test "list tasks" {
    run whatnext

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        sample.md:
            # Sample task file
            - [ ] Do something for the sake of it
        docs/basics.md:
            # Indicating the state of a task
            - [ ] empty, this task is outstanding
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "list tasks, changes width" {
    COLUMNS=40 run whatnext

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        sample.md:
            # Sample task file
            - [ ] Do something for the sake of
                  it
        docs/basics.md:
            # Indicating the state of a task
            - [ ] empty, this task is
                  outstanding
            # Indicating the state of a task /
              Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet,
                  consectetur adipisicing elit,
                  sed do eiusmod tempor
                  incididunt ut labore et dolore
                  magna aliqua.
            - [ ] Ut enim ad minim veniam,
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "list all tasks" {
    run whatnext -a

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        sample.md:
            # Sample task file
            - [ ] Do something for the sake of it
        docs/basics.md:
            # Indicating the state of a task
            - [ ] empty, this task is outstanding
            - [X] crossed, this task has been completed
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        archive/done/tasks.md:
            # Some old stuff
            - [X] Do the first thing
            - [X] Do the second thing
            - [x] do the last thing all lowercase
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise bar" {
    run whatnext -s

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        ░░░░░░░░░░░░░░                                             0/1  sample.md
        ██████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1/4  docs/basics.md
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise bar, changes width" {
    COLUMNS=40 run whatnext -s

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        ░░░░               0/1  sample.md
        ████░░░░░░░░░░░░░  1/4  docs/basics.md
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise, relative bars" {
    run whatnext -s -a

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        ░░░░░░░░░░░░                                        0/1  sample.md
        ████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1/4  docs/basics.md
        ██████████████████████████████████████              3/3  archive/done/tasks.md
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise, relative bars, changes width" {
    COLUMNS=40 run whatnext -s -a

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        ░░          0/1  sample.md
        ██░░░░░░░░  1/4  docs/basics.md
        ████████    3/3  archive/done/tasks.md
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "list tasks with --dir" {
    cp -r . "$BATS_TEST_TMPDIR/project"

    run whatnext --dir "$BATS_TEST_TMPDIR/project"

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        sample.md:
            # Sample task file
            - [ ] Do something for the sake of it
        docs/basics.md:
            # Indicating the state of a task
            - [ ] empty, this task is outstanding
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}
