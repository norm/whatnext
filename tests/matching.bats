bats_require_minimum_version 1.5.0

function setup {
    export WHATNEXT_TODAY=2025-01-01
    cd example
}

@test "arg is task search" {
    run --separate-stderr \
        whatnext \
            runic

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/obelisk.md:
            # Project Obelisk
            Something something star gate
            - [ ] research into runic meaning
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # check it will find later parts of the name
    run --separate-stderr \
        whatnext \
            meaning
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # case insensitive
    run --separate-stderr \
        whatnext \
            RUNIC
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "search term matches all under a heading" {
    run --separate-stderr \
        whatnext \
            Spring

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/harvest.md:
            # Project Harvest / Spring planting / HIGH
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # case insensitive
    run --separate-stderr \
        whatnext \
            PLANTING
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "args is additive search" {
    run --separate-stderr \
        whatnext \
            runic \
            sprouts

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/obelisk.md:
            # Project Obelisk
            Something something star gate
            - [ ] research into runic meaning
        projects/tinsel.md:
            # Project Tinsel / Christmas dinner
            - [ ] prep sprouts
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # check it will find later parts of the name
    run --separate-stderr \
        whatnext \
            meaning \
            SPROUTS
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # case insensitive
    run --separate-stderr \
        whatnext \
            RUNIC \
            SPROUTS
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is immaterial
    run --separate-stderr \
        whatnext \
            sprouts \
            runic
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "args can mix tasks and headings" {
    run --separate-stderr \
        whatnext \
            Spring \
            sprouts

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/harvest.md:
            # Project Harvest / Spring planting / HIGH
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots

        projects/tinsel.md:
            # Project Tinsel / Christmas dinner
            - [ ] prep sprouts
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # case insensitive
    run --separate-stderr \
        whatnext \
            SPRING \
            SPROUTS
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is immaterial
    run --separate-stderr \
        whatnext \
            sprouts \
            Spring
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "arg matching dir restricts input" {
    run --separate-stderr \
        whatnext \
            projects

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

    # if you need disambiguation
    run --separate-stderr \
        whatnext \
            ./projects
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "args match multiple dirs" {
    run --separate-stderr \
        whatnext \
            --all \
            projects \
            archived

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

        projects/curtain.md:
            # Project Curtain / Final bow
            - [ ] Take a bow
            # Project Curtain / Safety
            - [ ] Lower the safety curtain
            # Project Curtain / Close the theatre
            - [ ] Escort everyone out
            - [ ] Shut up shop
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

@test "dirs plus search" {
    run --separate-stderr \
        whatnext \
            projects \
            runic

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        obelisk.md:
            # Project Obelisk
            Something something star gate
            - [ ] research into runic meaning
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # if you need disambiguation
    run --separate-stderr \
        whatnext \
            ./projects \
            runic
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is immaterial
    run --separate-stderr \
        whatnext \
            runic \
            ./projects
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "duplicate dirs do not duplicate output" {
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

    run --separate-stderr \
        whatnext \
            projects
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    run --separate-stderr \
        whatnext \
            projects \
            projects
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    run --separate-stderr \
        whatnext \
            projects \
            projects/../projects
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "arg matching file restricts input" {
    run --separate-stderr \
        whatnext \
            tasks.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tasks.md:
            # Get S Done / MEDIUM
            - [ ] question entire existence

        tasks.md:
            # Get S Done
            - [ ] come up with better projects
            - [ ] start third project
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "multiple files" {
    run --separate-stderr \
        whatnext \
            tasks.md \
            projects/harvest.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
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
        projects/harvest.md:
            # Project Harvest
            - [/] turn compost heap
            - [ ] plan raised bed layout
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    # order is irrelevant
    run --separate-stderr \
        whatnext \
            projects/harvest.md \
            tasks.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "duplicate files do not duplicate output" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tasks.md:
            # Get S Done / MEDIUM
            - [ ] question entire existence

        tasks.md:
            # Get S Done
            - [ ] come up with better projects
            - [ ] start third project
        EOF
    )

    run --separate-stderr \
        whatnext \
            tasks.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]

    run --separate-stderr \
        whatnext \
            tasks.md \
            tasks.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "arg file path is respected in output" {
    run --separate-stderr \
        whatnext \
            projects/obelisk.md

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/obelisk.md:
            # Project Obelisk / Discovery / OVERDUE 30y 2m
            Mess with Jackson
            - [<] watch archaeologists discover (needs time machine)

        projects/obelisk.md:
            # Project Obelisk
            Something something star gate
            - [/] carve runes into obelisk
            - [ ] research into runic meaning
            - [ ] bury obelisk in desert
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "files plus search" {
    run --separate-stderr \
        whatnext \
            projects/obelisk.md \
            runes

    expected_output=$(sed -e 's/^        //' <<"        EOF"
        projects/obelisk.md:
            # Project Obelisk
            Something something star gate
            - [/] carve runes into obelisk
        EOF
    )
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "matchers override default search space" {
    run --separate-stderr \
        whatnext \
            --dir . \
            archived
    [ "$output" = "" ]
    [ $status -eq 0 ]
}

@test "no results is not an error" {
    run --separate-stderr \
        whatnext \
            smurf
    diff -u <(echo "") <(echo "$output")
    [ $status -eq 0 ]

    run --separate-stderr \
        whatnext \
            projects \
            smurf
    diff -u <(echo "") <(echo "$output")
    [ $status -eq 0 ]

    run --separate-stderr \
        whatnext \
            smurf \
            projects
    diff -u <(echo "") <(echo "$output")
    [ $status -eq 0 ]
}

@test "explicit file overrides ignore" {
    echo "ignore = ['tasks.md']" > "$BATS_TEST_TMPDIR/.whatnext"

    # tasks.md is ignored
    run --separate-stderr \
        whatnext \
            --config "$BATS_TEST_TMPDIR/.whatnext" \
            --all
    [ -z "$(echo "$output" | grep tasks.md)" ]

    # but you can still query it directly
    run --separate-stderr \
        whatnext \
            --config "$BATS_TEST_TMPDIR/.whatnext" \
            --all \
            tasks.md
    [ -n "$(echo "$output" | grep tasks.md)" ]
    [ $status -eq 0 ]
}
