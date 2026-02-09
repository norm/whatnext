bats_require_minimum_version 1.5.0

function setup {
    cd example
}

@test "list tasks" {
    WHATNEXT_TODAY=2025-12-25 \
        run --separate-stderr \
            whatnext

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tasks.md:
            # Get S Done / OVERDUE 1m 3w
            - [ ] come up with better projects
        projects/obelisk.md:
            # Project Obelisk / Discovery / OVERDUE 31y 2m
            Mess with Jackson
            - [<] watch archaeologists discover (needs time machine)
        projects/tinsel.md:
            # Project Tinsel / OVERDUE 2w 6d
            - [ ] send Christmas cards
            # Project Tinsel / Christmas dinner / OVERDUE 2d
            - [ ] book Christmas delivery

        projects/harvest.md:
            # Project Harvest / HIGH
            - [ ] order squash seeds
            # Project Harvest / Spring planting / HIGH
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots
        projects/obelisk.md:
            # Project Obelisk / HIGH
            Something something star gate
            - [ ] bury obelisk in desert
        projects/tinsel.md:
            # Project Tinsel / Christmas dinner / HIGH
            - [ ] roast the potatoes

        tasks.md:
            # Get S Done / MEDIUM
            - [ ] question entire existence
        projects/harvest.md:
            # Project Harvest / MEDIUM
            - [ ] buy copper tape for slugs
        projects/tinsel.md:
            # Project Tinsel / Christmas dinner / MEDIUM
            - [ ] prep the make-ahead gravy

        tasks.md:
            # Get S Done / IMMINENT 11d
            - [ ] start third project
        projects/tinsel.md:
            # Project Tinsel / Christmas dinner / IMMINENT TODAY
            - [ ] prep sprouts

        projects/curtain.md:
            # Project Curtain / Final bow
            - [ ] Take a bow
        projects/fountain.md:
            - [ ] nigredo, the blackening or melanosis
        projects/harvest.md:
            # Project Harvest
            - [/] turn compost heap
            - [ ] plan raised bed layout
        projects/obelisk.md:
            # Project Obelisk
            Something something star gate
            - [/] carve runes into obelisk
            - [ ] research into runic meaning
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")

    # no extraneous blank lines at the end
    [ $(WHATNEXT_TODAY=2025-12-25 whatnext 2>/dev/null | wc -l) -eq 58 ]

    [ $status -eq 0 ]
}

@test "default list is open, partial, blocked" {
    diff -u <(whatnext) <(whatnext --open --partial --blocked)
}


@test "list tasks, changes width" {
    COLUMNS=40 \
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/obelisk.md:
            # Project Obelisk / Discovery /
              OVERDUE 30y 2m
            Mess with Jackson
            - [<] watch archaeologists discover
                  (needs time machine)

        projects/harvest.md:
            # Project Harvest / HIGH
            - [ ] order squash seeds
            # Project Harvest / Spring planting
              / HIGH
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots

        tasks.md:
            # Get S Done / MEDIUM
            - [ ] question entire existence
        projects/harvest.md:
            # Project Harvest / MEDIUM
            - [ ] buy copper tape for slugs

        tasks.md:
            # Get S Done
            - [ ] come up with better projects
            - [ ] start third project
        projects/curtain.md:
            # Project Curtain / Final bow
            - [ ] Take a bow
        projects/fountain.md:
            - [ ] nigredo, the blackening or
                  melanosis
        projects/harvest.md:
            # Project Harvest
            - [/] turn compost heap
            - [ ] plan raised bed layout
        projects/obelisk.md:
            # Project Obelisk
            Something something star gate
            - [/] carve runes into obelisk
            - [ ] research into runic meaning
            - [ ] bury obelisk in desert
        projects/tinsel.md:
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

@test "list all tasks" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --all

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/obelisk.md:
            # Project Obelisk / Discovery / OVERDUE 30y 2m
            Mess with Jackson
            - [<] watch archaeologists discover (needs time machine)

        projects/harvest.md:
            # Project Harvest / HIGH
            - [ ] order squash seeds
            # Project Harvest / Spring planting / HIGH
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots

        tasks.md:
            # Get S Done / MEDIUM
            - [ ] question entire existence
        projects/harvest.md:
            # Project Harvest / MEDIUM
            - [ ] buy copper tape for slugs

        tasks.md:
            # Get S Done
            - [ ] come up with better projects
            - [ ] start third project
        projects/curtain.md:
            # Project Curtain / Final bow
            - [ ] Take a bow
            # Project Curtain / Safety
            - [ ] Lower the safety curtain
            # Project Curtain / Close the theatre
            - [ ] Escort everyone out
            - [ ] Shut up shop
        projects/fountain.md:
            - [ ] nigredo, the blackening or melanosis
            - [ ] albedo, the whitening or leucosis
            - [ ] citrinitas, the yellowing or xanthosis
            - [ ] rubedo, the reddening, purpling, or iosis
        projects/harvest.md:
            # Project Harvest
            - [/] turn compost heap
            - [ ] plan raised bed layout
        projects/obelisk.md:
            # Project Obelisk
            Something something star gate
            - [/] carve runes into obelisk
            - [ ] research into runic meaning
            - [ ] bury obelisk in desert
        projects/tinsel.md:
            # Project Tinsel
            - [ ] send Christmas cards
            # Project Tinsel / Christmas dinner
            - [ ] book Christmas delivery
            - [ ] prep the make-ahead gravy
            - [ ] roast the potatoes
            - [ ] prep sprouts

        projects/harvest.md:
            # Project Harvest / Hardening off / FINISHED
            - [X] move seedlings to cold frame
            # Project Harvest / Autumn / FINISHED
            - [#] enter giant marrow contest (too late)
        projects/obelisk.md:
            # Project Obelisk / FINISHED
            Something something star gate
            - [X] secure desert burial site
        archived/projects/tangerine.md:
            # Project Tangerine / FINISHED
            - [X] acquire trebuchet plans
            - [X] source counterweight materials
            - [X] build it
            - [#] throw fruit at neighbours (they moved away)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "list tasks with --dir" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --dir projects

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        obelisk.md:
            # Project Obelisk / Discovery / OVERDUE 30y 2m
            Mess with Jackson
            - [<] watch archaeologists discover (needs time machine)

        harvest.md:
            # Project Harvest / HIGH
            - [ ] order squash seeds
            # Project Harvest / Spring planting / HIGH
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots

        harvest.md:
            # Project Harvest / MEDIUM
            - [ ] buy copper tape for slugs

        fountain.md:
            - [ ] nigredo, the blackening or melanosis
        harvest.md:
            # Project Harvest
            - [/] turn compost heap
            - [ ] plan raised bed layout
        obelisk.md:
            # Project Obelisk
            Something something star gate
            - [/] carve runes into obelisk
            - [ ] research into runic meaning
            - [ ] bury obelisk in desert
        tinsel.md:
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

@test "warnings can be suppressed" {
    run --separate-stderr \
        whatnext \
            --quiet \
            ../tests/invalid.md
    [ $status -eq 0 ]
    [ -z "$stderr" ]

    WHATNEXT_QUIET=1 \
        run --separate-stderr \
            whatnext \
                ../tests/invalid.md
    [ $status -eq 0 ]
    [ -z "$stderr" ]
}

@test "filter just open tasks" {
    run --separate-stderr \
        whatnext \
            --open \
            projects/harvest.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/harvest.md:
            # Project Harvest / HIGH
            - [ ] order squash seeds
            # Project Harvest / Spring planting / HIGH
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots

        projects/harvest.md:
            # Project Harvest / MEDIUM
            - [ ] buy copper tape for slugs

        projects/harvest.md:
            # Project Harvest
            - [ ] plan raised bed layout
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # short flag
    run --separate-stderr \
        whatnext \
            -o \
            projects/harvest.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "filter just in progress tasks" {
    run --separate-stderr \
        whatnext \
            --partial \
            projects/harvest.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/harvest.md:
            # Project Harvest
            - [/] turn compost heap
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # short flag
    run --separate-stderr \
        whatnext \
            -p \
            projects/harvest.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "filter just blocked tasks" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --blocked \
                projects/obelisk.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/obelisk.md:
            # Project Obelisk / Discovery / OVERDUE 30y 2m
            Mess with Jackson
            - [<] watch archaeologists discover (needs time machine)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # short flag
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                -b \
                projects/obelisk.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "filter just completed tasks" {
    run --separate-stderr \
        whatnext \
            --done \
            projects/harvest.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/harvest.md:
            # Project Harvest / Hardening off / FINISHED
            - [X] move seedlings to cold frame
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # short flag
    run --separate-stderr \
        whatnext \
            -d \
            projects/harvest.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "filter just cancelled tasks" {
    run --separate-stderr \
        whatnext \
            --cancelled \
            projects/harvest.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/harvest.md:
            # Project Harvest / Autumn / FINISHED
            - [#] enter giant marrow contest (too late)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # short flag
    run --separate-stderr \
        whatnext \
            -c \
            projects/harvest.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "state filters can be combined" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --blocked \
                --cancelled \
                projects/harvest.md \
                projects/obelisk.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/obelisk.md:
            # Project Obelisk / Discovery / OVERDUE 30y 2m
            Mess with Jackson
            - [<] watch archaeologists discover (needs time machine)

        projects/harvest.md:
            # Project Harvest / Autumn / FINISHED
            - [#] enter giant marrow contest (too late)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    run --separate-stderr \
        whatnext \
            --open \
            --partial \
            projects/harvest.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/harvest.md:
            # Project Harvest / HIGH
            - [ ] order squash seeds
            # Project Harvest / Spring planting / HIGH
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots

        projects/harvest.md:
            # Project Harvest / MEDIUM
            - [ ] buy copper tape for slugs

        projects/harvest.md:
            # Project Harvest
            - [/] turn compost heap
            - [ ] plan raised bed layout
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --blocked \
                --cancelled \
                --done \
                --open \
                --partial \
                projects/harvest.md \
                projects/obelisk.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/obelisk.md:
            # Project Obelisk / Discovery / OVERDUE 30y 2m
            Mess with Jackson
            - [<] watch archaeologists discover (needs time machine)

        projects/harvest.md:
            # Project Harvest / HIGH
            - [ ] order squash seeds
            # Project Harvest / Spring planting / HIGH
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots

        projects/harvest.md:
            # Project Harvest / MEDIUM
            - [ ] buy copper tape for slugs

        projects/harvest.md:
            # Project Harvest
            - [/] turn compost heap
            - [ ] plan raised bed layout
        projects/obelisk.md:
            # Project Obelisk
            Something something star gate
            - [/] carve runes into obelisk
            - [ ] research into runic meaning
            - [ ] bury obelisk in desert

        projects/harvest.md:
            # Project Harvest / Hardening off / FINISHED
            - [X] move seedlings to cold frame
            # Project Harvest / Autumn / FINISHED
            - [#] enter giant marrow contest (too late)
        projects/obelisk.md:
            # Project Obelisk / FINISHED
            Something something star gate
            - [X] secure desert burial site
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "state filter combines with search" {
    run --separate-stderr \
        whatnext \
            --open \
            squash \
            projects/harvest.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/harvest.md:
            # Project Harvest / HIGH
            - [ ] order squash seeds
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "filter by priority" {
    run --separate-stderr \
        whatnext \
            --priority high \
            projects/harvest.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/harvest.md:
            # Project Harvest / HIGH
            - [ ] order squash seeds
            # Project Harvest / Spring planting / HIGH
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "filter multiple priorities" {
    run --separate-stderr \
        whatnext \
            --priority high \
            --priority medium \
            projects/harvest.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/harvest.md:
            # Project Harvest / HIGH
            - [ ] order squash seeds
            # Project Harvest / Spring planting / HIGH
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots

        projects/harvest.md:
            # Project Harvest / MEDIUM
            - [ ] buy copper tape for slugs
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "filter by priority and search" {
    run --separate-stderr \
        whatnext \
            --priority high \
            seeds \
            projects/harvest.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/harvest.md:
            # Project Harvest / HIGH
            - [ ] order squash seeds
            # Project Harvest / Spring planting / HIGH
            - [ ] sow tomato seeds indoors
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "numeric argument limits output" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                5

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/obelisk.md:
            # Project Obelisk / Discovery / OVERDUE 30y 2m
            Mess with Jackson
            - [<] watch archaeologists discover (needs time machine)

        projects/harvest.md:
            # Project Harvest / HIGH
            - [ ] order squash seeds
            # Project Harvest / Spring planting / HIGH
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots

        tasks.md:
            # Get S Done / MEDIUM
            - [ ] question entire existence
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "limits combine" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                --blocked \
                5

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/obelisk.md:
            # Project Obelisk / Discovery / OVERDUE 30y 2m
            Mess with Jackson
            - [<] watch archaeologists discover (needs time machine)
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "random selection" {
    first_output=$(WHATNEXT_TODAY=2025-01-01 whatnext 3r)
    task_count=$(echo "$first_output" | grep -c '    - \[')
    [ "$task_count" -eq 3 ]

    # should exit long before 10,000 iterations, that's just safety
    found_different=0
    for i in $(seq 1 10000); do
        current=$(WHATNEXT_TODAY=2025-01-01 whatnext 3r)
        if [ "$current" != "$first_output" ]; then
            found_different=1
            break
        fi
    done

    [ "$found_different" -eq 1 ]
}

@test "headerless file shows annotation" {
    run --separate-stderr \
        whatnext \
            ../tests/headerless/annotation.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        ../tests/headerless/annotation.md:
            This annotation should appear even without a heading.
            - [ ] a task without heading
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "headerless file shows priority" {
    WHATNEXT_TODAY=2025-01-01 \
        run --separate-stderr \
            whatnext \
                ../tests/headerless/deadline.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        ../tests/headerless/deadline.md:
            # OVERDUE 5y
            - [ ] an overdue task without heading
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}
