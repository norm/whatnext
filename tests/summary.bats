bats_require_minimum_version 1.5.0

function setup {
    cd example
}

@test "summarise incomplete tasks" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                           B P  O
        ░░░░░░░░░░░░░░░░░░░░░░░░                           0 0  3  tasks.md
        ░░░░░░░░                                           0 0  1  projects/curtain.md
        ▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0 1  5  projects/harvest.md
        ▚▚▚▚▚▚▚▚▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░                  1 1  2  projects/obelisk.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░          0 0  5  projects/tinsel.md
                                                           ──────
                                                           1 2 16  19, of 29 total

        ▚ Blocked  ▓ Partial  ░ Open
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise all states" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --all

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                            C D B P  O
        ░░░░░░░░░░░░░                       0 0 0 0  3  tasks.md
        ░░░░░░░░░░░░░░░░░                   0 0 0 0  4  projects/curtain.md
        ▚▚▚▚████▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░  1 1 0 1  5  projects/harvest.md
        ████▓▓▓▓▒▒▒▒▒░░░░░░░░               0 1 1 1  2  projects/obelisk.md
        ░░░░░░░░░░░░░░░░░░░░░               0 0 0 0  5  projects/tinsel.md
        ▚▚▚▚█████████████                   1 3 0 0  0  archived/projects/tangerine.md
                                            ──────────
                                            2 5 1 2 19  29, of 29 total

        ▚ Cancelled  █ Done  ▓ Blocked  ▒ Partial  ░ Open
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # should be functionally equivalent, with --ignore-after needed
    # because --all also ignores @after, unlike individual state flags)
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --cancelled \
                --done \
                --blocked \
                --partial \
                --open \
                --ignore-after
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # ...and order of args is irrelevant, desired ordering is applied
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --open \
                --ignore-after \
                --blocked \
                --done \
                --partial \
                --cancelled
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise all states, resized" {
    COLUMNS=40 \
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --all

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                    C D B P  O
        ░░░░        0 0 0 0  3  tasks.md
        ░░░░░       0 0 0 0  4  projects/curtain.md
        ▚█▒▒░░░░░░  1 1 0 1  5  projects/harvest.md
        █▓▒▒░░      0 1 1 1  2  projects/obelisk.md
        ░░░░░░      0 0 0 0  5  projects/tinsel.md
        ▚████       1 3 0 0  0  archived/projects/tangerine.md
                    ──────────
                    2 5 1 2 19  29, of 29 total

        ▚ Cancelled  █ Done  ▓ Blocked  ▒ Partial  ░ Open
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise open tasks" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --open

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                                O
        ████████████████████████████████                        3  tasks.md
        ███████████                                             1  projects/curtain.md
        █████████████████████████████████████████████████████   5  projects/harvest.md
        █████████████████████                                   2  projects/obelisk.md
        █████████████████████████████████████████████████████   5  projects/tinsel.md
                                                               ──
                                                               16  16, of 29 total

        █ Open
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise open tasks, relative" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --open \
                --relative

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                  O  ~
        ███████████████                           3  0  tasks.md
        █████                                     1  0  projects/curtain.md
        ████████████████████████░░░░░░░░░░░░░░░   5  3  projects/harvest.md
        ██████████░░░░░░░░░░░░░░                  2  3  projects/obelisk.md
        ████████████████████████                  5  0  projects/tinsel.md
        ░░░░░░░░░░░░░░░░░░░░                      0  4  archived/projects/tangerine.md
                                                 ─────
                                                 16 10  26, of 29 total

        █ Open  ░ (Cancelled/Done/Blocked/Partial)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise partial tasks" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --partial \
                --relative

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                  P  ~
        ░░░░░░░░░░░░░░░                           0  3  tasks.md
        ░░░░░                                     0  1  projects/curtain.md
        █████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1  7  projects/harvest.md
        █████░░░░░░░░░░░░░░░░░░░░                 1  4  projects/obelisk.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░                 0  5  projects/tinsel.md
        ░░░░░░░░░░░░░░░░░░░░                      0  4  archived/projects/tangerine.md
                                                  ────
                                                  2 24  26, of 29 total

        █ Partial  ░ (Cancelled/Done/Blocked/Open)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise blocked tasks" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --blocked \
                --relative

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                  B  ~
        ░░░░░░░░░░░░░░░                           0  3  tasks.md
        ░░░░░                                     0  1  projects/curtain.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0  8  projects/harvest.md
        █████░░░░░░░░░░░░░░░░░░░░                 1  4  projects/obelisk.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░                 0  5  projects/tinsel.md
        ░░░░░░░░░░░░░░░░░░░░                      0  4  archived/projects/tangerine.md
                                                  ────
                                                  1 25  26, of 29 total

        █ Blocked  ░ (Cancelled/Done/Partial/Open)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise done tasks" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --done \
                --relative

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                  D  ~
        ░░░░░░░░░░░░░░░                           0  3  tasks.md
        ░░░░░                                     0  1  projects/curtain.md
        █████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1  7  projects/harvest.md
        █████░░░░░░░░░░░░░░░░░░░░                 1  4  projects/obelisk.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░                 0  5  projects/tinsel.md
        ███████████████░░░░░                      3  1  archived/projects/tangerine.md
                                                  ────
                                                  5 21  26, of 29 total

        █ Done  ░ (Cancelled/Blocked/Partial/Open)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise cancelled tasks" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --cancelled \
                --relative

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                  C  ~
        ░░░░░░░░░░░░░░░                           0  3  tasks.md
        ░░░░░                                     0  1  projects/curtain.md
        █████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1  7  projects/harvest.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░                 0  5  projects/obelisk.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░                 0  5  projects/tinsel.md
        █████░░░░░░░░░░░░░░░                      1  3  archived/projects/tangerine.md
                                                  ────
                                                  2 24  26, of 29 total

        █ Cancelled  ░ (Done/Blocked/Partial/Open)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise multiple states" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --open \
                --cancelled \
                --relative

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                C  O ~
        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓                          0  3 0  tasks.md
        ▓▓▓▓▓                                   0  1 0  projects/curtain.md
        ▚▚▚▚▚▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░  1  5 2  projects/harvest.md
        ▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░                0  2 3  projects/obelisk.md
        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                0  5 0  projects/tinsel.md
        ▚▚▚▚▚░░░░░░░░░░░░░░                     1  0 3  archived/projects/tangerine.md
                                                ──────
                                                2 16 8  26, of 29 total

        ▚ Cancelled  ▓ Open  ░ (Done/Blocked/Partial)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise high priority tasks" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --priority high \
                --relative

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                  H  ~
        ░░░░░░░░░░░░░░░                           0  3  tasks.md
        ░░░░░                                     0  1  projects/curtain.md
        ███████████████░░░░░░░░░░░░░░░░░░░░░░░░░  3  5  projects/harvest.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░                 0  5  projects/obelisk.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░                 0  5  projects/tinsel.md
        ░░░░░░░░░░░░░░░░░░░░                      0  4  archived/projects/tangerine.md
                                                  ────
                                                  3 23  26, of 29 total

        █ High  ░ (Overdue/Imminent/Medium/Normal)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise medium priority tasks" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --priority medium \
                --relative

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                  M  ~
        █████░░░░░░░░░░                           1  2  tasks.md
        ░░░░░                                     0  1  projects/curtain.md
        █████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1  7  projects/harvest.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░                 0  5  projects/obelisk.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░                 0  5  projects/tinsel.md
        ░░░░░░░░░░░░░░░░░░░░                      0  4  archived/projects/tangerine.md
                                                  ────
                                                  2 24  26, of 29 total

        █ Medium  ░ (Overdue/Imminent/High/Normal)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise multiple priority levels" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --summary \
                --priority high \
                --priority normal \
                --relative

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                               H  N  ~
        ▓▓▓▓▓▓▓▓▓░░░░░                         0  2  1  tasks.md
        ▓▓▓▓▓                                  0  1  0  projects/curtain.md
        ▚▚▚▚▚▚▚▚▚▚▚▚▚▚▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░  3  2  3  projects/harvest.md
        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░                0  3  2  projects/obelisk.md
        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                0  5  0  projects/tinsel.md
        ░░░░░░░░░░░░░░░░░░                     0  0  4  archived/projects/tangerine.md
                                               ───────
                                               3 13 10  26, of 29 total

        ▚ High  ▓ Normal  ░ (Overdue/Imminent/Medium)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}
