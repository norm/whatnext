bats_require_minimum_version 1.5.0

@test "force colour output" {
    WHATNEXT_TODAY=2025-12-25 \
        run --separate-stderr \
            whatnext \
                --color \
                --priority overdue \
                example/projects/obelisk.md

    expected_output=$(printf '\033[1m\033[35m%s\033[0m' "$(sed -e 's/^        //' <<"        EOF"
        example/projects/obelisk.md:
            # Project Obelisk / OVERDUE 31y 2m
            - [<] watch archaeologists discover (needs time machine)
        EOF
    )")
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    WHATNEXT_TODAY=2025-12-25 \
    WHATNEXT_COLOR=1 \
        run --separate-stderr \
            whatnext \
                --priority overdue \
                example/projects/obelisk.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "disable colour output" {
    WHATNEXT_TODAY=2025-12-25 \
    WHATNEXT_COLOR=1 \
        run --separate-stderr \
            whatnext \
                --no-color \
                --priority overdue \
                example/projects/obelisk.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        example/projects/obelisk.md:
            # Project Obelisk / OVERDUE 31y 2m
            - [<] watch archaeologists discover (needs time machine)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    WHATNEXT_TODAY=2025-12-25 \
    WHATNEXT_COLOR=0 \
        run --separate-stderr \
            whatnext \
                --priority overdue \
                example/projects/obelisk.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}
