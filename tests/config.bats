setup() {
    mkdir -p "$BATS_TEST_TMPDIR/project"
    echo "- [ ] task one" > "$BATS_TEST_TMPDIR/project/one.md"
    echo "- [ ] task two" > "$BATS_TEST_TMPDIR/project/two.md"
    echo "- [ ] task three" > "$BATS_TEST_TMPDIR/project/three.md"
    mkdir -p "$BATS_TEST_TMPDIR/config"
    echo 'ignore = ["three.md"]' > "$BATS_TEST_TMPDIR/config/whatevernext"
}

@test "baseline" {
    run whatnext \
            --dir "$BATS_TEST_TMPDIR/project"

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        one.md:
            - [ ] task one
        three.md:
            - [ ] task three
        two.md:
            - [ ] task two
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "default config file" {
    echo 'ignore = ["two.md"]' > "$BATS_TEST_TMPDIR/project/.whatnext"

    run whatnext \
            --dir "$BATS_TEST_TMPDIR/project"

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        one.md:
            - [ ] task one
        three.md:
            - [ ] task three
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "config from argument" {
    run whatnext \
            --dir "$BATS_TEST_TMPDIR/project" \
            --config "$BATS_TEST_TMPDIR/config/whatevernext"

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        one.md:
            - [ ] task one
        two.md:
            - [ ] task two
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "config from environment" {
    WHATNEXT_CONFIG="$BATS_TEST_TMPDIR/config/whatevernext" \
        run whatnext \
                --dir "$BATS_TEST_TMPDIR/project"

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        one.md:
            - [ ] task one
        two.md:
            - [ ] task two
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "ignore option" {
    run whatnext \
            --dir "$BATS_TEST_TMPDIR/project" \
            --ignore 'two.md' \
            --ignore 'three.md'

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        one.md:
            - [ ] task one
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "ignore option globs" {
    run whatnext \
            --dir "$BATS_TEST_TMPDIR/project" \
            --ignore 't*.md'

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        one.md:
            - [ ] task one
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "ignore options and config combine" {
    WHATNEXT_CONFIG="$BATS_TEST_TMPDIR/config/whatevernext" \
        run whatnext \
                --dir "$BATS_TEST_TMPDIR/project" \
                --ignore 'two.md'

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        one.md:
            - [ ] task one
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}
