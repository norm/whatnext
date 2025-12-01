bats_require_minimum_version 1.5.0

@test "summarise all states" {
    run --separate-stderr whatnext --summary

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                     C/D/B/P/O
        ░░░░░                                        0/0/0/0/1  sample.md
        ▚▚▚▚▚██████▓▓▓▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░       1/1/1/1/3  docs/basics.md
        ▚▚▚▚▚██████▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░  1/1/0/1/5  docs/prioritisation.md
        ░░░░░                                        0/0/0/0/1  tests/headerless.md
        ████████████████                             0/3/0/0/0  archive/done/tasks.md

        ▚ Cancelled  █ Done  ▓ Blocked  ▒ Partial  ░ Open
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise all states, narrow" {
    COLUMNS=40 run --separate-stderr whatnext --summary

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                    C/D/B/P/O
        ░           0/0/0/0/1  sample.md
        ▚██▓▒░░░░   1/1/1/1/3  docs/basics.md
        ▚█▒▒░░░░░░  1/1/0/1/5  docs/prioritisation.md
        ░           0/0/0/0/1  tests/headerless.md
        ████        0/3/0/0/0  archive/done/tasks.md

        ▚ Cancelled  █ Done  ▓ Blocked  ▒ Partial  ░ Open
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise open tasks" {
    run --separate-stderr whatnext --summary --open

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                           O/~
        ▚▚▚▚▚▚                                             1/0  sample.md
        ▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚░░░░░░░░░░░░░░░░░░░░░░░░░        3/4  docs/basics.md
        ▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚░░░░░░░░░░░░░░░░░░  5/3  docs/prioritisation.md
        ▚▚▚▚▚▚                                             1/0  tests/headerless.md
        ░░░░░░░░░░░░░░░░░░                                 0/3  archive/done/tasks.md

        ▚ Open  ░ (Cancelled/Done/Blocked/Partial)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise partial tasks" {
    run --separate-stderr whatnext --summary --partial

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                           P/~
        ░░░░░░                                             0/1  sample.md
        ▚▚▚▚▚▚░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░        1/6  docs/basics.md
        ▚▚▚▚▚▚░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1/7  docs/prioritisation.md
        ░░░░░░                                             0/1  tests/headerless.md
        ░░░░░░░░░░░░░░░░░░                                 0/3  archive/done/tasks.md

        ▚ Partial  ░ (Cancelled/Done/Blocked/Open)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise blocked tasks" {
    run --separate-stderr whatnext --summary --blocked

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                           B/~
        ░░░░░░                                             0/1  sample.md
        ▚▚▚▚▚▚░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░        1/6  docs/basics.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0/8  docs/prioritisation.md
        ░░░░░░                                             0/1  tests/headerless.md
        ░░░░░░░░░░░░░░░░░░                                 0/3  archive/done/tasks.md

        ▚ Blocked  ░ (Cancelled/Done/Partial/Open)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise done tasks" {
    run --separate-stderr whatnext --summary --done

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                           D/~
        ░░░░░░                                             0/1  sample.md
        ▚▚▚▚▚▚░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░        1/6  docs/basics.md
        ▚▚▚▚▚▚░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1/7  docs/prioritisation.md
        ░░░░░░                                             0/1  tests/headerless.md
        ▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚                                 3/0  archive/done/tasks.md

        ▚ Done  ░ (Cancelled/Blocked/Partial/Open)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise cancelled tasks" {
    run --separate-stderr whatnext --summary --cancelled

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                           C/~
        ░░░░░░                                             0/1  sample.md
        ▚▚▚▚▚▚░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░        1/6  docs/basics.md
        ▚▚▚▚▚▚░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1/7  docs/prioritisation.md
        ░░░░░░                                             0/1  tests/headerless.md
        ░░░░░░░░░░░░░░░░░░                                 0/3  archive/done/tasks.md

        ▚ Cancelled  ░ (Done/Blocked/Partial/Open)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise multiple states" {
    run --separate-stderr whatnext --summary --open --cancelled

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                         C/O/~
        ██████                                           0/1/0  sample.md
        ▚▚▚▚▚▚█████████████████░░░░░░░░░░░░░░░░░░        1/3/3  docs/basics.md
        ▚▚▚▚▚▚█████████████████████████████░░░░░░░░░░░░  1/5/2  docs/prioritisation.md
        ██████                                           0/1/0  tests/headerless.md
        ░░░░░░░░░░░░░░░░░░                               0/0/3  archive/done/tasks.md

        ▚ Cancelled  █ Open  ░ (Done/Blocked/Partial)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise high priority tasks" {
    run --separate-stderr whatnext --summary --priority high

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                           H/~
        ░░░░░░░░                                           0/1  sample.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░          0/5  docs/basics.md
        ▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚░░░░░░░░░░░░░░░░░░░░░░░░░  3/3  docs/prioritisation.md
        ░░░░░░░░                                           0/1  tests/headerless.md

        ▚ High  ░ (Medium/Normal)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise medium priority tasks" {
    run --separate-stderr whatnext --summary --priority medium

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                           M/~
        ░░░░░░░░                                           0/1  sample.md
        ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░          0/5  docs/basics.md
        ▚▚▚▚▚▚▚▚░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1/5  docs/prioritisation.md
        ░░░░░░░░                                           0/1  tests/headerless.md

        ▚ Medium  ░ (High/Normal)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "summarise multiple priority levels" {
    run --separate-stderr whatnext --summary --priority high --priority normal

    expected_output=$(sed -e 's/^        //' <<"        EOF"
                                                         H/N/~
        ████████                                         0/1/0  sample.md
        ███████████████████████████████████████          0/5/0  docs/basics.md
        ▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚███████████████░░░░░░░░  3/2/1  docs/prioritisation.md
        ████████                                         0/1/0  tests/headerless.md

        ▚ High  █ Normal  ░ (Medium)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}
