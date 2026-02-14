bats_require_minimum_version 1.5.0

setup_file() {
    echo "- [ ] complete task" > /tmp/whatnext-test-prereq.md
}

teardown_file() {
    rm -f /tmp/whatnext-test-prereq.md
}

@test "circular dependency exits with error" {
    run --separate-stderr \
        whatnext \
            tests/deferring/circular-a.md \
            tests/deferring/circular-b.md

    expected_stderr=$(sed -e 's/^        //' <<"        EOF"
        ERROR: Circular dependency: circular-a.md -> circular-b.md -> circular-a.md
        EOF
    )
    diff -u <(echo "$expected_stderr") <(echo "$stderr")
    [ $status -eq 1 ]
}

@test "warning on nonexistent file dependency" {
    run --separate-stderr \
        whatnext \
            tests/deferring/missing-dep.md

    expected_stderr=$(sed -e 's/^        //' <<"        EOF"
        WARNING: tests/deferring/missing-dep.md: 'nonexistent.md' does not exist
        EOF
    )
    diff -u <(echo "$expected_stderr") <(echo "$stderr")
    [ $status -eq 0 ]
}

@test "all errors and warnings shown" {
    run --separate-stderr \
        whatnext \
            tests/deferring

    expected_stderr=$(sed -e 's/^        //' <<"        EOF"
        WARNING: @phase has no meaning except in a header
        WARNING: duplicate-warnings.md: 'missing-a.md' does not exist
        WARNING: duplicate-warnings.md: 'missing-b.md' does not exist
        WARNING: missing-dep.md: 'nonexistent.md' does not exist
        ERROR: Circular dependency: circular-a.md -> circular-b.md -> circular-a.md
        EOF
    )
    diff -u <(echo "$expected_stderr") <(echo "$stderr")
    [ $status -eq 1 ]
}

@test "warnings are not duplicated" {
    run --separate-stderr \
        whatnext \
            tests/deferring/duplicate-warnings.md

    expected_stderr=$(sed -e 's/^        //' <<"        EOF"
        WARNING: tests/deferring/duplicate-warnings.md: 'missing-a.md' does not exist
        WARNING: tests/deferring/duplicate-warnings.md: 'missing-b.md' does not exist
        EOF
    )
    diff -u <(echo "$expected_stderr") <(echo "$stderr")
    [ $status -eq 0 ]
}

@test "warning suppresseds" {
    run --separate-stderr \
        whatnext \
            --quiet \
            tests/deferring/missing-dep.md

    diff -u <(echo "") <(echo "$stderr")
    [ $status -eq 0 ]
}

@test "deferred tasks hidden by default" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/deferring/regular.md:
            - [ ] do the thing
        EOF
    )

    run whatnext tests/deferring/regular.md tests/deferring/deferred.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "tasks shown when file queried directly" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/deferring/bare-after.md:
            - [ ] do this last
        EOF
    )

    # nothing else is outstanding (as nothing else was loaded),
    # so the contents should be shown
    run whatnext tests/deferring/bare-after.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "after can be ignored" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/deferring/deferred.md:
            - [ ] wait for regular
        tests/deferring/regular.md:
            - [ ] do the thing
        EOF
    )

    run whatnext --ignore-after tests/deferring/regular.md tests/deferring/deferred.md
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "dependency treated as satisfied when file is deliberately ignored" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/deferring/deferred.md:
            - [ ] wait for regular
        EOF
    )

    run --separate-stderr \
        whatnext \
            --ignore regular.md \
            tests/deferring/deferred.md

    diff -u <(echo "$expected_output") <(echo "$output")
    diff -u <(echo "") <(echo "$stderr")
    [ $status -eq 0 ]
}

@test "after resolves bare filename relative to file" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/deferring/samename.md:
            - [ ] incomplete task at root
        tests/deferring/subdir/needs-sibling.md:
            - [ ] depends on sibling
        EOF
    )

    run --separate-stderr \
        whatnext \
            tests/deferring/subdir/needs-sibling.md \
            tests/deferring/subdir/samename.md \
            tests/deferring/samename.md

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "after resolves path descending into subdirectory" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/deferring/needs-subdir.md:
            - [ ] depends on subdir file
        EOF
    )

    run --separate-stderr \
        whatnext \
            tests/deferring/needs-subdir.md \
            tests/deferring/subdir/target.md

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "after resolves path ascending to parent directory" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/deferring/subdir/needs-parent.md:
            - [ ] depends on parent file
        EOF
    )

    run --separate-stderr \
        whatnext \
            tests/deferring/subdir/needs-parent.md \
            tests/deferring/root-target.md

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "after resolves absolute path" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        /tmp/whatnext-test-prereq.md:
            - [ ] complete task
        EOF
    )

    run --separate-stderr \
        whatnext \
            tests/deferring/needs-absolute.md \
            /tmp/whatnext-test-prereq.md

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "phase sections filter later phases" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/deferring/phases.md:
            # Bugs
            - [ ] fix bug
            # New feature [phase 1/3]
            - [ ] install dependencies
        EOF
    )

    run --separate-stderr \
        whatnext \
            tests/deferring/phases.md

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "phase shows next when previous complete" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/deferring/phases-partial.md:
            # Bugs
            - [ ] fix bug
            # Implementation [phase 2/3]
            - [ ] write code
        EOF
    )

    run --separate-stderr \
        whatnext \
            tests/deferring/phases-partial.md

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "all phases shown with --all" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/deferring/phases.md:
            # Bugs
            - [ ] fix bug
            # New feature [phase 1/3]
            - [ ] install dependencies
            # New feature / Implement [phase 2/3]
            - [ ] write code
            # New feature / Test [phase 3/3]
            - [ ] run tests
        EOF
    )

    run --separate-stderr \
        whatnext \
            --all \
            tests/deferring/phases.md

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "queue limits tasks within phase" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/deferring/phases-queue.md:
            # Implementation [phase 2/3]
            - [ ] first impl task
        EOF
    )

    run --separate-stderr \
        whatnext \
            tests/deferring/phases-queue.md

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "empty phase skips to next" {
    expected_output=$(sed -e 's/^        //' <<"        EOF"
        tests/deferring/phases-empty.md:
            # Implementation [phase 3/3]
            - [ ] write code
            - [ ] add tests
        EOF
    )

    run --separate-stderr \
        whatnext \
            tests/deferring/phases-empty.md

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "warning when @phase outside header" {
    expected_stderr=$(sed -e 's/^        //' <<"        EOF"
        WARNING: @phase has no meaning except in a header
        EOF
    )

    run --separate-stderr \
        whatnext \
            tests/deferring/phase-misplaced.md

    diff -u <(echo "$expected_stderr") <(echo "$stderr")
    [ $status -eq 0 ]
}
