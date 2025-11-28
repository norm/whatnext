@test "arg is task search" {
    run whatnext dolor

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
    run whatnext dolore
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # case insensitive
    run whatnext MAGNA
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "search term matches all under a heading" {
    run whatnext dentat

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
    run whatnext MULTI
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "args is additive search" {
    run whatnext dolor empty

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task
            - [ ] empty, this task is outstanding
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # check it will find later parts of the name
    run whatnext dolore mpt
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # case insensitive
    run whatnext MAGNA EMPTY
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is immaterial
    run whatnext empty dolor
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "args can mix tasks and headings" {
    run whatnext dentat empty

    expected_output=$(sed -e 's/^        //' <<"        EOF"
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

    # case insensitive
    run whatnext DENTAT EMPTY
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is immaterial
    run whatnext EMPTY DENTAT
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "arg matching dir restricts input" {
    run whatnext docs

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        basics.md:
            # Indicating the state of a task
            - [ ] empty, this task is outstanding
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        usage.md:
            # Usage
            - [ ] Do something for the sake of it
            - [ ] empty, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            # Usage / Matching
            - [ ] empty, this task is outstanding
            # Usage / Arguments
            - [ ] Do something for the sake of it
            - [ ] empty, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # if you need disambiguation
    run whatnext ./docs
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "args match multiple dirs" {
    run whatnext --all docs archive

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task
            - [ ] empty, this task is outstanding
            - [X] crossed, this task has been completed
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        docs/usage.md:
            # Usage
            - [ ] Do something for the sake of it
            - [ ] empty, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            # Usage / Matching
            - [ ] empty, this task is outstanding
            # Usage / Arguments
            - [ ] Do something for the sake of it
            - [ ] empty, this task is outstanding
            - [X] crossed, this task has been completed
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            - [X] Do the first thing
            - [X] Do the second thing
            - [x] do the last thing all lowercase
        archive/done/tasks.md:
            # Some old stuff
            - [X] Do the first thing
            - [X] Do the second thing
            - [x] do the last thing all lowercase
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is immaterial
    run whatnext --all docs archive
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "dirs plus search" {
    run whatnext docs dolor

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
    run whatnext ./docs dolor
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is immaterial
    run whatnext dolor ./docs
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "duplicate dirs do not duplicate output" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/basics.md:
            # Indicating the state of a task
            - [ ] empty, this task is outstanding
            # Indicating the state of a task / Multiline tasks and indentation
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        docs/usage.md:
            # Usage
            - [ ] Do something for the sake of it
            - [ ] empty, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            # Usage / Matching
            - [ ] empty, this task is outstanding
            # Usage / Arguments
            - [ ] Do something for the sake of it
            - [ ] empty, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        EOF
    )

    run whatnext docs docs
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    run whatnext docs docs docs docs
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "arg matching file restricts input" {
    run whatnext sample.md

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
    run whatnext sample.md docs/usage.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        sample.md:
            # Sample task file
            - [ ] Do something for the sake of it
        docs/usage.md:
            # Usage
            - [ ] Do something for the sake of it
            - [ ] empty, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            # Usage / Matching
            - [ ] empty, this task is outstanding
            # Usage / Arguments
            - [ ] Do something for the sake of it
            - [ ] empty, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is irrelevant
    run whatnext docs/usage.md sample.md
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

    run whatnext sample.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    run whatnext sample.md sample.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "arg file path is respected in output" {
    run whatnext docs/usage.md
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        docs/usage.md:
            # Usage
            - [ ] Do something for the sake of it
            - [ ] empty, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
            # Usage / Matching
            - [ ] empty, this task is outstanding
            # Usage / Arguments
            - [ ] Do something for the sake of it
            - [ ] empty, this task is outstanding
            - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
                  eiusmod tempor incididunt ut labore et dolore magna aliqua.
            - [ ] Ut enim ad minim veniam,
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "files plus search" {
    run whatnext docs/usage.md minim

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
    run whatnext --dir . archive
    [ "$output" = "" ]
    [ $status -eq 0 ]
}

@test "no results is not an error" {
    run whatnext smurf
    diff -u <(echo "") <(echo "$output")
    [ $status -eq 0 ]

    run whatnext docs smurf
    diff -u <(echo "") <(echo "$output")
    [ $status -eq 0 ]

    run whatnext smurf docs
    diff -u <(echo "") <(echo "$output")
    [ $status -eq 0 ]
}

@test "explicit file overrides ignore" {
    # tasks.md is ignored
    grep -q "tasks.md" .whatnext
    run whatnext -all
    [ -z "$(echo "$output" | grep tasks.md)" ]

    # but you can still query it directly
    run whatnext --all tasks.md
    [ -n "$(echo "$output" | grep tasks.md)" ]
    [ $status -eq 0 ]
}
