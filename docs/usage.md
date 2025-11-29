# Usage

Without arguments, `whatnext` will show all outstanding tasks (open,
in progress, and blocked) listed in any Markdown file:

```bash
(computer)% whatnext
sample.md:
    # Sample task file
    - [ ] Do something for the sake of it
docs/basics.md:
    # Indicating the state of a task
    - [/] in progress, this task is partially complete
    - [ ] open, this task is outstanding
    - [<] blocked, this task needs more input
    # Indicating the state of a task / Multiline tasks and indentation
    - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
          eiusmod tempor incididunt ut labore et dolore magna aliqua.
    - [ ] Ut enim ad minim veniam,
```

They will be arranged:

- by file, depth-last, in alphabetical order
- grouped under the heading within the file (includes any parental
  headings)


## Matching

Any argument(s) can be used to filter the output:

-   **\[term\]** - only show tasks that contain 'term', or tasks under
    a heading that contains 'term' (matching is case-insensitive)
-   **file** - if the argument matches a directory, the tasks in that file
    will be searched
-   **directory** - if the argument matches a directory, files under
    that directory will be searched (if you have directories with short
    names like "doc", this could be ambiguous, use "./doc" to clarify)

```bash
(computer)% whatnext open
docs/basics.md:
    # Indicating the state of a task
    - [ ] open, this task is outstanding
```


## Arguments

`whatnext` takes the following optional arguments:

-   `-h` / `--help` — show a short or full usage reminder.

-   `--version` — show the version and exit.

-   `--dir` — the directory to search through for Markdown files,
    defaults to `.`.

-   `--ignore [pattern]` — ignore files matching the given
    [filename pattern][glob]; can be specified multiple times.

-   `--config` — path to the [config file](dotwhatnext.md), defaults
    to `.whatnext` or `WHATNEXT_CONFIG`.

-   `-q` / `--quiet` — suppress warnings (or `WHATNEXT_QUIET=1`).

-   `-o` / `--open` — show only open tasks.

-   `-p` / `--partial` — show only in progress tasks.

-   `-b` / `--blocked` — show only blocked tasks.

-   `-d` / `--done` — show only completed tasks.

-   `-c` / `--cancelled` — show only cancelled tasks.

-   `-s` / `--summary` — summarise the tasks found in files,
    rather than listing the tasks within:

    ```bash
    ░░░░░░░░░░░░░░                                             0/1  sample.md
    ██████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1/7  docs/basics.md
    ```

    When there are multiple files, the progress bars are sized relative to the
    task file with the most tasks.

-   `-a` / `--all` — show all tasks, not just outstanding ones:

    ```bash
    sample.md:
        # Sample task file
        - [ ] Do something for the sake of it
    docs/basics.md:
        # Indicating the state of a task
        - [/] in progress, this task is partially complete
        - [ ] open, this task is outstanding
        - [X] complete, this task has been finished
        - [#] cancelled, this task has been scratched
        - [<] blocked, this task needs more input
        # Indicating the state of a task / Multiline tasks and indentation
        - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
              eiusmod tempor incididunt ut labore et dolore magna aliqua.
        - [ ] Ut enim ad minim veniam,
    archive/done/tasks.md:
        # Some old stuff
        - [X] Do the first thing
        - [X] Do the second thing
        - [x] do the last thing all lowercase
    ```

    When combined with `--summary`:

    ```bash
    (computer)% whatnext --summary --all
    ░░░░░░░░░░░░                                        0/1  sample.md
    ████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1/7  docs/basics.md
    ██████████████████████████████████████████████████  3/3  archive/done/tasks.md
    ```


[glob]: https://docs.python.org/3/library/fnmatch.html
