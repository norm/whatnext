bats_require_minimum_version 1.5.0

function setup {
    cd tests/config
}

@test "default config is in the dir root" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        apples.md:
            # Apples
            - [ ] pick apples
            - [ ] make cider
        EOF
    )

    run --separate-stderr \
        whatnext

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}


@test "config arg is also relative to the dir root" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        oranges.md:
            # Oranges
            - [ ] squeeze oranges
            - [ ] make marmalade
        EOF
    )

    run --separate-stderr \
        whatnext \
            --config .whatnext.alt

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "config arg from environment" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        oranges.md:
            # Oranges
            - [ ] squeeze oranges
            - [ ] make marmalade
        EOF
    )

    WHATNEXT_CONFIG=.whatnext.alt \
        run --separate-stderr \
            whatnext

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "absolute config is relative to running dir" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        apples.md:
            # Apples
            - [ ] pick apples
            - [ ] make cider
        oranges.md:
            # Oranges
            - [ ] squeeze oranges
            - [ ] make marmalade
        EOF
    )

    run --separate-stderr \
        whatnext \
            --config ../config-external

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    WHATNEXT_CONFIG=../config-external \
        run --separate-stderr \
            whatnext

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}
