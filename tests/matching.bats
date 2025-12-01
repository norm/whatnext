bats_require_minimum_version 1.5.0

@test "arg is task search" {
    run --separate-stderr whatnext dolor

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # check it will find later parts of the name
    run --separate-stderr whatnext dolore
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # case insensitive
    run --separate-stderr whatnext MAGNA
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "search term matches all under a heading" {
    run --separate-stderr whatnext dentat

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # case insensitive
    run --separate-stderr whatnext MULTI
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "args is additive search" {
    run --separate-stderr whatnext dolor open

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task
            - [ ] open, this task is outstanding
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # check it will find later parts of the name
    run --separate-stderr whatnext dolore tstanding
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # case insensitive
    run --separate-stderr whatnext MAGNA OPEN
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is immaterial
    run --separate-stderr whatnext open dolor
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "args can mix tasks and headings" {
    run --separate-stderr whatnext dentat open

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

    # case insensitive
    run --separate-stderr whatnext DENTAT OPEN
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is immaterial
    run --separate-stderr whatnext OPEN DENTAT
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "arg matching dir restricts input" {
    run --separate-stderr whatnext docs

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        prioritisation.md:
            # Prioritisation
            - [ ] super-urgent task
            # do these first
            - [ ] inherently high priority task, because of the header
            - [ ] no extra priority, still listed second
        usage.md:
            # Usage / Arguments
            - [ ] super-urgent task
            - [ ] no extra priority, still listed second

        prioritisation.md:
            # Prioritisation
            - [ ] semi-urgent task
        usage.md:
            # Usage / Arguments
            - [ ] semi-urgent task

        basics.md:
            # Indicating the state of a task
            - [/] in progress, this task is partially complete
            - [ ] open, this task is outstanding
            - [<] blocked, this task needs more input
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        prioritisation.md:
            # Prioritisation
            - [/] not a high priority task
            - [ ] top, but not urgent, task
        usage.md:
            # Usage
            - [/] in progress, this task is partially complete
            - [ ] super-urgent task
            - [ ] inherently high priority task, because of the header
            - [ ] no extra priority, still listed second
            - [ ] header priority cascades down
            - [ ] semi-urgent task
            - [ ] Do something for the sake of it
            - [ ] open, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            - [ ] top, but not urgent, task
            - [ ] not a high priority task
            - [ ] normal priority, new header resets that
            - [<] blocked, this task needs more input
            # Usage / Matching
            - [ ] open, this task is outstanding
            # Usage / Arguments
            - [/] in progress, this task is partially complete
            - [ ] inherently high priority task, because of the header
            - [ ] header priority cascades down
            - [ ] Do something for the sake of it
            - [ ] open, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            - [ ] top, but not urgent, task
            - [ ] not a high priority task
            - [ ] normal priority, new header resets that
            - [<] blocked, this task needs more input
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # if you need disambiguation
    run --separate-stderr whatnext ./docs
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "args match multiple dirs" {
    run --separate-stderr whatnext --all docs archive

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/prioritisation.md:
            # Prioritisation
            - [ ] super-urgent task
            # do these first
            - [ ] inherently high priority task, because of the header
            - [ ] no extra priority, still listed second
            # do these first / grouped, but still highest priority
            - [X] header priority cascades down
        docs/usage.md:
            # Usage / Arguments
            - [ ] super-urgent task
            - [ ] no extra priority, still listed second

        docs/prioritisation.md:
            # Prioritisation
            - [ ] semi-urgent task
        docs/usage.md:
            # Usage / Arguments
            - [ ] semi-urgent task

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
        docs/usage.md:
            # Usage
            - [/] in progress, this task is partially complete
            - [ ] super-urgent task
            - [ ] inherently high priority task, because of the header
            - [ ] no extra priority, still listed second
            - [ ] header priority cascades down
            - [ ] semi-urgent task
            - [ ] Do something for the sake of it
            - [ ] open, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            - [ ] top, but not urgent, task
            - [ ] not a high priority task
            - [ ] normal priority, new header resets that
            - [<] blocked, this task needs more input
            # Usage / Matching
            - [ ] open, this task is outstanding
            # Usage / Arguments
            - [/] in progress, this task is partially complete
            - [ ] inherently high priority task, because of the header
            - [ ] header priority cascades down
            - [ ] Do something for the sake of it
            - [ ] open, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            - [ ] top, but not urgent, task
            - [ ] not a high priority task
            - [ ] normal priority, new header resets that
            - [<] blocked, this task needs more input
            - [X] complete, this task has been finished
            - [X] Do the first thing
            - [X] Do the second thing
            - [X] do the last thing all lowercase
            - [#] cancelled, this task has been scratched
        archive/done/tasks.md:
            # Some old stuff
            - [X] Do the first thing
            - [X] Do the second thing
            - [X] do the last thing all lowercase
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is immaterial
    run --separate-stderr whatnext --all docs archive
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "dirs plus search" {
    run --separate-stderr whatnext docs dolor

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        basics.md:
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
        usage.md:
            # Usage
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            # Usage / Arguments
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # if you need disambiguation
    run --separate-stderr whatnext ./docs dolor
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is immaterial
    run --separate-stderr whatnext dolor ./docs
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "duplicate dirs do not duplicate output" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/prioritisation.md:
            # Prioritisation
            - [ ] super-urgent task
            # do these first
            - [ ] inherently high priority task, because of the header
            - [ ] no extra priority, still listed second
        docs/usage.md:
            # Usage / Arguments
            - [ ] super-urgent task
            - [ ] no extra priority, still listed second

        docs/prioritisation.md:
            # Prioritisation
            - [ ] semi-urgent task
        docs/usage.md:
            # Usage / Arguments
            - [ ] semi-urgent task

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
        docs/usage.md:
            # Usage
            - [/] in progress, this task is partially complete
            - [ ] super-urgent task
            - [ ] inherently high priority task, because of the header
            - [ ] no extra priority, still listed second
            - [ ] header priority cascades down
            - [ ] semi-urgent task
            - [ ] Do something for the sake of it
            - [ ] open, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            - [ ] top, but not urgent, task
            - [ ] not a high priority task
            - [ ] normal priority, new header resets that
            - [<] blocked, this task needs more input
            # Usage / Matching
            - [ ] open, this task is outstanding
            # Usage / Arguments
            - [/] in progress, this task is partially complete
            - [ ] inherently high priority task, because of the header
            - [ ] header priority cascades down
            - [ ] Do something for the sake of it
            - [ ] open, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            - [ ] top, but not urgent, task
            - [ ] not a high priority task
            - [ ] normal priority, new header resets that
            - [<] blocked, this task needs more input
        EOF
    )

    run --separate-stderr whatnext docs docs
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    run --separate-stderr whatnext docs docs docs docs
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "arg matching file restricts input" {
    run --separate-stderr whatnext sample.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        sample.md:
            # Sample task file
            - [ ] Do something for the sake of it
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "multiple files" {
    run --separate-stderr whatnext sample.md docs/usage.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/usage.md:
            # Usage / Arguments
            - [ ] super-urgent task
            - [ ] no extra priority, still listed second

        docs/usage.md:
            # Usage / Arguments
            - [ ] semi-urgent task

        sample.md:
            # Sample task file
            - [ ] Do something for the sake of it
        docs/usage.md:
            # Usage
            - [/] in progress, this task is partially complete
            - [ ] super-urgent task
            - [ ] inherently high priority task, because of the header
            - [ ] no extra priority, still listed second
            - [ ] header priority cascades down
            - [ ] semi-urgent task
            - [ ] Do something for the sake of it
            - [ ] open, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            - [ ] top, but not urgent, task
            - [ ] not a high priority task
            - [ ] normal priority, new header resets that
            - [<] blocked, this task needs more input
            # Usage / Matching
            - [ ] open, this task is outstanding
            # Usage / Arguments
            - [/] in progress, this task is partially complete
            - [ ] inherently high priority task, because of the header
            - [ ] header priority cascades down
            - [ ] Do something for the sake of it
            - [ ] open, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            - [ ] top, but not urgent, task
            - [ ] not a high priority task
            - [ ] normal priority, new header resets that
            - [<] blocked, this task needs more input
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is irrelevant
    run --separate-stderr whatnext docs/usage.md sample.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "duplicate files do not duplicate output" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        sample.md:
            # Sample task file
            - [ ] Do something for the sake of it
        EOF
    )

    run --separate-stderr whatnext sample.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    run --separate-stderr whatnext sample.md sample.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "arg file path is respected in output" {
    run --separate-stderr whatnext docs/usage.md
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/usage.md:
            # Usage / Arguments
            - [ ] super-urgent task
            - [ ] no extra priority, still listed second

        docs/usage.md:
            # Usage / Arguments
            - [ ] semi-urgent task

        docs/usage.md:
            # Usage
            - [/] in progress, this task is partially complete
            - [ ] super-urgent task
            - [ ] inherently high priority task, because of the header
            - [ ] no extra priority, still listed second
            - [ ] header priority cascades down
            - [ ] semi-urgent task
            - [ ] Do something for the sake of it
            - [ ] open, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            - [ ] top, but not urgent, task
            - [ ] not a high priority task
            - [ ] normal priority, new header resets that
            - [<] blocked, this task needs more input
            # Usage / Matching
            - [ ] open, this task is outstanding
            # Usage / Arguments
            - [/] in progress, this task is partially complete
            - [ ] inherently high priority task, because of the header
            - [ ] header priority cascades down
            - [ ] Do something for the sake of it
            - [ ] open, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            - [ ] top, but not urgent, task
            - [ ] not a high priority task
            - [ ] normal priority, new header resets that
            - [<] blocked, this task needs more input
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "files plus search" {
    run --separate-stderr whatnext docs/usage.md minim

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/usage.md:
            # Usage
            - [ ] Ut enim ad minim veniam,
            # Usage / Arguments
            - [ ] Ut enim ad minim veniam,
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "matchers override default search space" {
    run --separate-stderr whatnext --dir . archive
    [ "$output" = "" ]
    [ $status -eq 0 ]
}

@test "no results is not an error" {
    run --separate-stderr whatnext smurf
    diff -u <(echo "") <(echo "$output")
    [ $status -eq 0 ]

    run --separate-stderr whatnext docs smurf
    diff -u <(echo "") <(echo "$output")
    [ $status -eq 0 ]

    run --separate-stderr whatnext smurf docs
    diff -u <(echo "") <(echo "$output")
    [ $status -eq 0 ]
}

@test "explicit file overrides ignore" {
    # tasks.md is ignored
    grep -q "tasks.md" .whatnext
    run --separate-stderr whatnext -all
    [ -z "$(echo "$output" | grep tasks.md)" ]

    # but you can still query it directly
    run --separate-stderr whatnext --all tasks.md
    [ -n "$(echo "$output" | grep tasks.md)" ]
    [ $status -eq 0 ]
}
