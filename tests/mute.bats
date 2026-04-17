bats_require_minimum_version 1.5.0

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
