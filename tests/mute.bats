bats_require_minimum_version 1.5.0

@test "--mute creates mute entry" {
    run whatnext --config "$BATS_TEST_TMPDIR/.whatnext" --mute 1d "apples"

    # check pattern is in file (until timestamp varies)
    diff -u <(echo 'pattern = "apples"') <(grep 'pattern' "$BATS_TEST_TMPDIR/.whatnext.mute")
    [ $status -eq 0 ]
}

@test "--mute appends to existing file" {
    sed -e 's/^        //' > "$BATS_TEST_TMPDIR/.whatnext.mute" <<-EOF
        [[mute]]
        until = 2099-12-31T23:59:59
        pattern = "existing"
	EOF

    run whatnext --config "$BATS_TEST_TMPDIR/.whatnext" --mute 1w "new"

    expected=$(sed -e 's/^        //' <<-EOF
        pattern = "existing"
        pattern = "new"
	EOF
    )
    diff -u <(echo "$expected") <(grep 'pattern' "$BATS_TEST_TMPDIR/.whatnext.mute")
    [ $status -eq 0 ]
}

@test "--mute rejects empty pattern" {
    run --separate-stderr \
        whatnext --config "$BATS_TEST_TMPDIR/.whatnext" --mute 1d ""

    diff -u <(echo "ERROR: pattern cannot be empty") <(echo "$stderr")
    [ $status -eq 1 ]
}

@test "--mute rejects invalid period" {
    run --separate-stderr \
        whatnext --config "$BATS_TEST_TMPDIR/.whatnext" --mute "abc" "pattern"

    diff -u <(echo "ERROR: invalid period 'abc'") <(echo "$stderr")
    [ $status -eq 1 ]
}

@test "muted tasks are excluded from output" {
    sed -e 's/^        //' > "$BATS_TEST_TMPDIR/.whatnext.mute" <<-EOF
        [[mute]]
        until = 2099-12-31T23:59:59
        pattern = "apples"
	EOF

    expected_output=$(sed -e 's/^        //' <<-EOF
        tasks.md:
            # Shopping
            - [ ] buy oranges
            # Gardening
            - [ ] plant seeds
            - [ ] water plants

        (1 task muted)
	EOF
    )

    run --separate-stderr \
        whatnext --config "$BATS_TEST_TMPDIR/.whatnext" tests/mute

    diff -u <(echo "$expected_output") <(echo "$output")
    [[ $status -eq 0 ]]
}

@test "muting matches heading" {
    sed -e 's/^        //' > "$BATS_TEST_TMPDIR/.whatnext.mute" <<-EOF
        [[mute]]
        until = 2099-12-31T23:59:59
        pattern = "shopping"
	EOF

    expected_output=$(sed -e 's/^        //' <<-EOF
        tasks.md:
            # Gardening
            - [ ] plant seeds
            - [ ] water plants

        (2 tasks muted)
	EOF
    )

    run --separate-stderr \
        whatnext --config "$BATS_TEST_TMPDIR/.whatnext" tests/mute

    diff -u <(echo "$expected_output") <(echo "$output")
    [[ $status -eq 0 ]]
}

@test "muting matches filename" {
    sed -e 's/^        //' > "$BATS_TEST_TMPDIR/.whatnext.mute" <<-EOF
        [[mute]]
        until = 2099-12-31T23:59:59
        pattern = "tasks"
	EOF

    # FIXME
    expected_output=$(sed -e 's/^        //' <<-EOF


        (4 tasks muted)
	EOF
    )

    run --separate-stderr \
        whatnext --config "$BATS_TEST_TMPDIR/.whatnext" tests/mute

    diff -u <(echo "$expected_output") <(echo "$output")
    [[ $status -eq 0 ]]
}

@test "multiple patterns exclude multiple tasks" {
    sed -e 's/^        //' > "$BATS_TEST_TMPDIR/.whatnext.mute" <<-EOF
        [[mute]]
        until = 2099-12-31T23:59:59
        pattern = "apples"

        [[mute]]
        until = 2099-12-31T23:59:59
        pattern = "seeds"
	EOF

    expected_output=$(sed -e 's/^        //' <<-EOF
        tasks.md:
            # Shopping
            - [ ] buy oranges
            # Gardening
            - [ ] water plants

        (2 tasks muted)
	EOF
    )

    run --separate-stderr \
        whatnext --config "$BATS_TEST_TMPDIR/.whatnext" tests/mute

    diff -u <(echo "$expected_output") <(echo "$output")
    [[ $status -eq 0 ]]
}

@test "options bypass mute filtering" {
    sed -e 's/^        //' > "$BATS_TEST_TMPDIR/.whatnext.mute" <<-EOF
        [[mute]]
        until = 2099-12-31T23:59:59
        pattern = "apples"
	EOF

    # no count when nothing muted
    expected_output=$(sed -e 's/^        //' <<-EOF
        tasks.md:
            # Shopping
            - [ ] buy apples
            - [ ] buy oranges
            # Gardening
            - [ ] plant seeds
            - [ ] water plants
	EOF
    )

    for flag in --ignore-mute --all --ignore-all; do
        run --separate-stderr \
            whatnext \
                --config "$BATS_TEST_TMPDIR/.whatnext" \
                "$flag" \
                    tests/mute

        diff -u <(echo "$expected_output") <(echo "$output")
        [[ $status -eq 0 ]]
    done
}
