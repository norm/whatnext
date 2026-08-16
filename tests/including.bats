bats_require_minimum_version 1.5.0

@test "included file's contents are substituted at the directive" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/including/list.md:
            - [ ] first in list
            - [ ] from the included file
            - [ ] last in list
        EOF
    )

    run --separate-stderr \
        whatnext \
            tests/including/list.md

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "included file is no longer considered a source" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/including/list.md:
            - [ ] first in list
            - [ ] from the included file
            - [ ] last in list
        EOF
    )

    # included.md is passed alongside list.md, but because list.md includes it
    # it must not appear under its own header, nor its task be shown twice
    run --separate-stderr \
        whatnext \
            tests/including/list.md \
            tests/including/included.md

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "including a non-existent file warns and contributes nothing" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/including/includes-missing.md:
            - [ ] real task
        EOF
    )
    expected_stderr=$(sed -e 's/^        //' <<"        EOF"
        WARNING: tests/including/includes-missing.md: 'ghost.md' does not exist
        EOF
    )

    run --separate-stderr \
        whatnext \
            tests/including/includes-missing.md

    diff -u <(echo "$expected_output") <(echo "$output")
    diff -u <(echo "$expected_stderr") <(echo "$stderr")
    [ $status -eq 0 ]
}
