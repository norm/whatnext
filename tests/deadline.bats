bats_require_minimum_version 1.5.0

@test "before any deadline window, all tasks normal priority" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                example/projects/tinsel.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        example/projects/tinsel.md:
            # Project Tinsel
            - [ ] send Christmas cards
            # Project Tinsel / Christmas dinner
            - [ ] book Christmas delivery
            - [ ] prep the make-ahead gravy
            - [ ] roast the potatoes
            - [ ] prep sprouts
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "within 3w window, book Christmas delivery becomes imminent" {
    # Dec 2 is exactly 3 weeks before Dec 23
    # "send Christmas cards" is also imminent (Nov 21 was 2 weeks before Dec 5)
    WHATNEXT_TODAY=2025-12-02 \
        run --separate-stderr \
            whatnext \
                example/projects/tinsel.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        example/projects/tinsel.md:
            # Project Tinsel / IMMINENT 3d
            - [ ] send Christmas cards
            # Project Tinsel / Christmas dinner / IMMINENT 3w
            - [ ] book Christmas delivery

        example/projects/tinsel.md:
            # Project Tinsel / Christmas dinner
            - [ ] prep the make-ahead gravy
            - [ ] roast the potatoes
            - [ ] prep sprouts
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "within default 2w window, send Christmas cards becomes imminent" {
    # Nov 21 is exactly 2 weeks before Dec 5
    WHATNEXT_TODAY=2025-11-21 \
        run --separate-stderr \
            whatnext \
                example/projects/tinsel.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        example/projects/tinsel.md:
            # Project Tinsel / IMMINENT 2w
            - [ ] send Christmas cards

        example/projects/tinsel.md:
            # Project Tinsel / Christmas dinner
            - [ ] book Christmas delivery
            - [ ] prep the make-ahead gravy
            - [ ] roast the potatoes
            - [ ] prep sprouts
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "on deadline day, 0d task becomes high" {
    WHATNEXT_TODAY=2025-12-25 \
        run --separate-stderr \
            whatnext \
                example/projects/tinsel.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        example/projects/tinsel.md:
            # Project Tinsel / OVERDUE 2w 6d
            - [ ] send Christmas cards
            # Project Tinsel / Christmas dinner / OVERDUE 2d
            - [ ] book Christmas delivery

        example/projects/tinsel.md:
            # Project Tinsel / Christmas dinner / HIGH
            - [ ] roast the potatoes

        example/projects/tinsel.md:
            # Project Tinsel / Christmas dinner / MEDIUM
            - [ ] prep the make-ahead gravy

        example/projects/tinsel.md:
            # Project Tinsel / Christmas dinner / IMMINENT TODAY
            - [ ] prep sprouts
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "past deadline, task becomes overdue" {
    WHATNEXT_TODAY=2025-12-06 \
        run --separate-stderr \
            whatnext \
                example/projects/tinsel.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        example/projects/tinsel.md:
            # Project Tinsel / OVERDUE 1d
            - [ ] send Christmas cards

        example/projects/tinsel.md:
            # Project Tinsel / Christmas dinner / IMMINENT 2w 3d
            - [ ] book Christmas delivery

        example/projects/tinsel.md:
            # Project Tinsel / Christmas dinner
            - [ ] prep the make-ahead gravy
            - [ ] roast the potatoes
            - [ ] prep sprouts
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "filter by overdue priority" {
    WHATNEXT_TODAY=2025-12-06 \
        run --separate-stderr \
            whatnext \
                --priority overdue \
                example/projects/tinsel.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        example/projects/tinsel.md:
            # Project Tinsel / OVERDUE 1d
            - [ ] send Christmas cards
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "filter by medium priority" {
    WHATNEXT_TODAY=2025-12-24 \
        run --separate-stderr \
            whatnext \
                --priority medium \
                example/projects/tinsel.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        example/projects/tinsel.md:
            # Project Tinsel / Christmas dinner / MEDIUM
            - [ ] prep the make-ahead gravy
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "filter by imminent priority" {
    WHATNEXT_TODAY=2025-12-06 \
        run --separate-stderr \
            whatnext \
                --priority imminent \
                example/projects/tinsel.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        example/projects/tinsel.md:
            # Project Tinsel / Christmas dinner / IMMINENT 2w 3d
            - [ ] book Christmas delivery
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "deadline date stripped from output" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                example/projects/tinsel.md

    [[ ! "$output" =~ @2025 ]]
    [ $status -eq 0 ]
}
