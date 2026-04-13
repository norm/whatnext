bats_require_minimum_version 1.5.0

function setup {
    cp -r "$BATS_TEST_DIRNAME/next/." "$BATS_TEST_TMPDIR"
    export HOME="$BATS_TEST_TMPDIR"
    export WHATNEXT_PROJECT_DIR="$BATS_TEST_TMPDIR/projects"
    cd "$HOME"
}

@test "shows version" {
    run next --version

    [[ "$output" =~ ^next\ [0-9]+\. ]]
    [ $status -eq 0 ]
}

@test "shows usage" {
    expected_output=$(sed -e 's/^        //' <<-EOF
        usage: next [-h] [--version] [-a] [--config CONFIG] ...

        Add a task to a Markdown (.md file) task list.

        positional arguments:
          text             task text to add (if omitted, read from stdin)

        options:
          -h, --help       show this help message and exit
          --version        show program's version number and exit
          -a               append to end of file, ignoring headings (or set
                           WHATNEXT_APPEND_ONLY)
          --config CONFIG  path to config file (default: WHATNEXT_CONFIG, or
                           '.whatnext')

        The file to add to is chosen indirectly:

        - if the first word of text is an absolute filename, use that
        - if the first word matches a file in the current directory, use that
        - if the first word matches a file in \$WHATNEXT_PROJECT_DIR, use that
        - if the first word matches a file in \$HOME, use that
        - if the first word matches a directory in \$WHATNEXT_PROJECT_DIR:
            - if the second word matches a file
              \$WHATNEXT_PROJECT_DIR/[project]/tasks/[word].md then use that
            - otherwise, use \$WHATNEXT_PROJECT_DIR/[project]/tasks.md
        - if tasks.md exists in the current directory, use that
        - otherwise, use \$HOME/tasks.md

        With the remaining text:

        - if the file uses headings to section the file:
            - if the first word case-insensitively matches a heading in the
              file, the task is added to that section
            - otherwise, the task is added above the first heading
        - otherwise, the task is added to the end of the file
	EOF
    )

    run next --help

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "non-markdown file is treated as part of text" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] something.txt do something

        # Tasks

        - [ ] existing task
	EOF
    )

    run next something.txt do something

    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/tasks.md:
        +- [ ] something.txt do something
        +
         # Tasks
         
	EOF
    )

    diff -u "$BATS_TEST_DIRNAME/next/something.txt" "$HOME/something.txt"
    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "nonexistent file is treated as part of text" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] nonexistent.md do something

        # Tasks

        - [ ] existing task
	EOF
    )

    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/tasks.md:
        +- [ ] nonexistent.md do something
        +
         # Tasks
         
	EOF
    )

    run next nonexistent.md do something

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

function assert_task_added {
    local tasks_file="$1"
    local expected_message="$2"

    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] do something

        # Tasks

        - [ ] existing task
	EOF
    )

    expected_output=$(sed -e 's/^        //' <<-EOF
        ${expected_message}:
        +- [ ] do something
        +
         # Tasks
         
	EOF
    )

    diff -u <(echo "$expected_content") "$tasks_file"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "adds to master task list" {
    run next do something

    assert_task_added \
        "$HOME/tasks.md" \
        "Updated ~/tasks.md"
}

@test "adds to master task list wherever you are" {
    cd "$WHATNEXT_PROJECT_DIR"
    run next do something

    assert_task_added \
        "$HOME/tasks.md" \
        "Updated ~/tasks.md"
}

@test "adds to master task list from outside of homedir" {
    cd /tmp
    run next do something

    assert_task_added \
        "$HOME/tasks.md" \
        "Updated ~/tasks.md"
}

@test "prefers tasks.md in cwd over home" {
    cd "$WHATNEXT_PROJECT_DIR/alpha"
    run next do something

    assert_task_added \
        "$WHATNEXT_PROJECT_DIR/alpha/tasks.md" \
        "Updated ~/projects/alpha/tasks.md"
    diff -u "$BATS_TEST_DIRNAME/next/tasks.md" "$HOME/tasks.md"
}

@test "adds to existing project" {
    run next alpha do something

    assert_task_added \
        "$WHATNEXT_PROJECT_DIR/alpha/tasks.md" \
        "Updated ~/projects/alpha/tasks.md"
}

@test "adds to existing project from outside of homedir" {
    cd /tmp
    run next alpha do something

    assert_task_added \
        "$WHATNEXT_PROJECT_DIR/alpha/tasks.md" \
        "Updated ~/projects/alpha/tasks.md"
}

@test "adds to master task list without WHATNEXT_PROJECT_DIR" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] alpha do something

        # Tasks

        - [ ] existing task
	EOF
    )
    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/tasks.md:
        +- [ ] alpha do something
        +
         # Tasks
         
	EOF
    )
    unset WHATNEXT_PROJECT_DIR

    run next alpha do something

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "adds to project task file" {
    run next alpha things do something

    assert_task_added \
        "$WHATNEXT_PROJECT_DIR/alpha/tasks/things.md" \
        "Updated ~/projects/alpha/tasks/things.md"
}

@test "adds to project task file from outside of homedir" {
    cd /tmp
    run next alpha things do something

    assert_task_added \
        "$WHATNEXT_PROJECT_DIR/alpha/tasks/things.md" \
        "Updated ~/projects/alpha/tasks/things.md"
}

@test "creates project tasks file" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] do something
	EOF
    )
    expected_output=$(sed -e 's/^        //' <<-EOF
        Created ~/projects/beta/tasks.md:
        +- [ ] do something
	EOF
    )

    run next beta do something

    diff -u <(echo "$expected_content") "$WHATNEXT_PROJECT_DIR/beta/tasks.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "does not add to things.md as it is not tried" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] things do something
	EOF
    )

    expected_output=$(sed -e 's/^        //' <<-EOF
        Created ~/projects/beta/tasks.md:
        +- [ ] things do something
	EOF
    )

    run next beta things do something

    diff -u <(echo "$expected_content") "$WHATNEXT_PROJECT_DIR/beta/tasks.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "add to alternate file" {
    run next alternate.md do something

    assert_task_added \
        "$HOME/alternate.md" \
        "Updated ~/alternate.md"
}

@test "add with absolute filename" {
    cd /tmp
    run next "$HOME/alternate.md" do something

    assert_task_added \
        "$HOME/alternate.md" \
        "Updated ~/alternate.md"
}

@test "add with relative filename" {
    cd $HOME/projects
    run next alpha/tasks/things.md do something

    assert_task_added \
        "$HOME/projects/alpha/tasks/things.md" \
        "Updated ~/projects/alpha/tasks/things.md"
}

@test "add with homedir relative filename from outside of home" {
    # this works because any relative filename where that filename
    # doesn't exist is then tried relative to $HOME
    cd /tmp
    run next projects/alpha/tasks/things.md do something

    assert_task_added \
        "$HOME/projects/alpha/tasks/things.md" \
        "Updated ~/projects/alpha/tasks/things.md"
}

@test "add with project relative filename from outside of home" {
    # this works because any relative filename where that filename
    # doesn't exist is then tried relative to $HOME and then
    # $WHATNEXT_PROJECT_DIR
    cd /tmp
    run next alpha/tasks/things.md do something

    assert_task_added \
        "$HOME/projects/alpha/tasks/things.md" \
        "Updated ~/projects/alpha/tasks/things.md"
}

@test "adds to end of file" {
    expected_content=$(sed -e 's/^        //' <<-EOF




        - [ ] do something
	EOF
    )

    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/empty.md:
         
         
        +- [ ] do something
	EOF
    )

    run next empty.md do something

    diff -u <(echo "$expected_content") "$HOME/empty.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "test within file positioning" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        This is an explanation.

        This section currently has no tasks.

        - [ ] do something

        # First

        - [ ] first something

        # Second

        - [ ] second something

        #### Third

        This section contains notes.

        - [ ] third something

        ## Fourth

        A note.

        - [ ] A task.
        - [ ] Another task.

        Another note.

        # Second

        There is no way to add a task here.

        # Last

        - [ ] second to last task
        - [ ] last task
	EOF
    )

    run next insert.md do something
    run next insert.md first first something
    run next insert.md second second something
    run next insert.md third third something
    run next insert.md fourth Another task.
    run next insert.md last last task

    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/insert.md (Last):
         
         - [ ] second to last task
        +- [ ] last task
	EOF
    )

    diff -u <(echo "$expected_content") "$HOME/insert.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "WHATNEXT_APPEND_ONLY set" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        # Tasks

        - [ ] existing task
        - [ ] do something
	EOF
    )
    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/tasks.md:
         
         - [ ] existing task
        +- [ ] do something
	EOF
    )
    export WHATNEXT_APPEND_ONLY=1

    run next do something

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "append flag" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        # Tasks

        - [ ] existing task
        - [ ] do something
	EOF
    )

    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/tasks.md:
         
         - [ ] existing task
        +- [ ] do something
	EOF
    )

    run next -a do something

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "flag-like text is not parsed as arguments" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] something -e something

        # Tasks

        - [ ] existing task
	EOF
    )

    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/tasks.md:
        +- [ ] something -e something
        +
         # Tasks
         
	EOF
    )

    run next something -e something

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "appending spaces out tasks" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        # Tasks

        This is where things get added.

        - [ ] do something
	EOF
    )

    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/append.md:
         
         This is where things get added.
        +
        +- [ ] do something
	EOF
    )

    run next -a append.md do something

    diff -u <(echo "$expected_content") "$HOME/append.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "append adds to end of file not after last task" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        # Done

        - [X] completed task

        # Next

        - [ ] do something
	EOF
    )

    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/append-after.md:
         
         # Next
        +
        +- [ ] do something
	EOF
    )

    run next -a append-after.md do something

    diff -u <(echo "$expected_content") "$HOME/append-after.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "output shows diff on create" {
    expected_output=$(sed -e 's/^        //' <<-EOF
        Created ~/projects/beta/tasks.md:
        +- [ ] do something
	EOF
    )

    run next beta do something

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "output shows diff on update" {
    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/tasks.md:
         
         - [ ] existing task
        +- [ ] do something
	EOF
    )

    run next -a do something

    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "continuation line width is detected even when task is deferred" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] This new task is longer than eighty characters and exceeds the continuation width to prove
              where it wraps

        # Tasks @after tasks.md

        - [ ] the continuation line is deliberately longer than the first line in
              order to confirm that width detection occurs across the entire task not just the first line
	EOF
    )

    WHATNEXT_WRAP_WIDTH=20 \
        run next wrapped.md This new task is longer than eighty characters and exceeds the continuation width to prove where it wraps

    diff -u <(echo "$expected_content") "$HOME/wrapped.md"
    [ $status -eq 0 ]
}

@test "existing file with wider lines sets wrap width" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        This line of context is deliberately written to be extraordinarily long, much longer than any task line in this file, to prove the script measures task width not arbitrary line width.

        - [ ] short task
        - [ ] another short task
        - [ ] This is an existing task that is deliberately written to be wider than eighty characters on a single line
        - [ ] Adding another long task that would normally wrap at eighty but should not wrap here because existing
              tasks are wider
	EOF
    )

    run next wide.md Adding another long task that would normally wrap at eighty but should not wrap here because existing tasks are wider

    diff -u <(echo "$expected_content") "$HOME/wide.md"
    [ $status -eq 0 ]
}

@test "file width beats narrower env var" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        This line of context is deliberately written to be extraordinarily long, much longer than any task line in this file, to prove the script measures task width not arbitrary line width.

        - [ ] short task
        - [ ] another short task
        - [ ] This is an existing task that is deliberately written to be wider than eighty characters on a single line
        - [ ] This task would wrap at sixty if env var won but it does not because file width is authoritative
	EOF
    )

    WHATNEXT_WRAP_WIDTH=60 \
        run next wide.md This task would wrap at sixty if env var won but it does not because file width is authoritative

    diff -u <(echo "$expected_content") "$HOME/wide.md"
    [ $status -eq 0 ]
}

@test "env var sets width when file is narrower" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] This is a task that wraps at forty
              characters

        # Tasks

        - [ ] existing task
	EOF
    )

    WHATNEXT_WRAP_WIDTH=40 \
        run next This is a task that wraps at forty characters

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    [ $status -eq 0 ]
}

@test "config sets width when file is narrower" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] This is a task that wraps at fifty
              characters exactly

        # Tasks

        - [ ] existing task
	EOF
    )
    echo 'wrap_width = 50' > "$HOME/.whatnext"

    run next This is a task that wraps at fifty characters exactly

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    [ $status -eq 0 ]
}

@test "config file can be specified with --config" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] This is a task that wraps at fifty
              characters exactly

        # Tasks

        - [ ] existing task
	EOF
    )
    echo 'wrap_width = 50' > "$HOME/custom.toml"

    run next --config custom.toml This is a task that wraps at fifty characters exactly

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    [ $status -eq 0 ]
}

@test "long task text wraps at 80 chars by default" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] This is a very long task description that should wrap because it exceeds
              the default width of eighty characters

        # Tasks

        - [ ] existing task
	EOF
    )

    run next This is a very long task description that should wrap because it exceeds the default width of eighty characters

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    [ $status -eq 0 ]
}

@test "stdin adds multiple tasks" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] first task
        - [ ] second task
        - [ ] third task

        # Tasks

        - [ ] existing task
	EOF
    )
    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/tasks.md:
        +- [ ] first task
        +- [ ] second task
        +- [ ] third task
        +
         # Tasks
         
	EOF
    )

    run bash -c 'printf "first task\nsecond task\nthird task\n" | next'

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "stdin with file specification" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] piped task

        # Tasks

        - [ ] existing task
	EOF
    )
    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/alternate.md:
        +- [ ] piped task
        +
         # Tasks
         
	EOF
    )

    run bash -c 'echo "piped task" | next alternate.md'

    diff -u <(echo "$expected_content") "$HOME/alternate.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "stdin with section specification" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        This is an explanation.

        This section currently has no tasks.

        # First

        - [ ] piped to section

        # Second

        #### Third

        This section contains notes.

        ## Fourth

        A note.

        - [ ] A task.

        Another note.

        # Second

        There is no way to add a task here.

        # Last

        - [ ] second to last task
	EOF
    )
    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/insert.md (First):
         
         # First
        +
        +- [ ] piped to section
         
         # Second
	EOF
    )

    run bash -c 'echo "piped to section" | next insert.md first'

    diff -u <(echo "$expected_content") "$HOME/insert.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "empty stdin does nothing" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        # Tasks

        - [ ] existing task
	EOF
    )

    run bash -c 'echo -n "" | next'

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    diff -u <(echo "") <(echo "$output")
    [ $status -eq 0 ]
}

@test "stdin blank lines are ignored" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] actual task
        - [ ] another task

        # Tasks

        - [ ] existing task
	EOF
    )
    expected_output=$(sed -e 's/^        //' <<-EOF
        Updated ~/tasks.md:
        +- [ ] actual task
        +- [ ] another task
        +
         # Tasks
         
	EOF
    )

    run bash -c 'printf "\nactual task\n\n\nanother task\n\n" | next'

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    diff -u <(echo "$expected_output") <(echo "$output")
    [ $status -eq 0 ]
}

@test "stdin tasks are wrapped" {
    expected_content=$(sed -e 's/^        //' <<-EOF
        - [ ] This is a very long task that should wrap because it exceeds the default
              width of eighty characters

        # Tasks

        - [ ] existing task
	EOF
    )

    run bash -c 'echo "This is a very long task that should wrap because it exceeds the default width of eighty characters" | next'

    diff -u <(echo "$expected_content") "$HOME/tasks.md"
    [ $status -eq 0 ]
}
