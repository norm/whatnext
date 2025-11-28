# Usage

Without arguments, `whatnext` will show all incomplete tasks listed
in any Markdown file:

```bash
(computer)% whatnext
sample.md:
    # Sample task file
    - [ ] Do something for the sake of it
docs/basics.md:
    # Indicating the state of a task
    - [ ] empty, this task is outstanding
    # Indicating the state of a task / Multiline tasks and indentation
    - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
          eiusmod tempor incididunt ut labore et dolore magna aliqua.
    - [ ] Ut enim ad minim veniam,
```

They will be arranged:

    - by file, depth-last, in alphabetical order
    - grouped under the heading within the file (includes any parental
      headings)


## Arguments

`whatnext` takes the following optional arguments:

-   `-h` / `--help` — show a short or full usage reminder.

-   `--dir` — the directory to search through for Markdown files,
    defaults to `.`.

-   `--ignore [pattern]` — ignore files matching the given
    [filename pattern][glob]; can be specified multiple times.

-   `--config` — path to the [config file](dotwhatnext.md), defaults
    to `.whatnext` or `WHATNEXT_CONFIG`.

-   `-s` / `--summary` — summarise the tasks found in files,
    rather than listing the tasks within:

    ```bash
    ░░░░░░░░░░░░░░                                             0/1  sample.md
    ██████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1/4  docs/basics.md
    ```

    When there are multiple files, the progress bars are sized relative to the
    task file with the most tasks.

-   `-a` / `--all` — show all tasks, not just incomplete ones:

    ```bash
    sample.md:
        # Sample task file
        - [ ] Do something for the sake of it
    docs/basics.md:
        # Indicating the state of a task
        - [ ] empty, this task is outstanding
        - [X] crossed, this task has been completed
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
    ████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1/4  docs/basics.md
    ██████████████████████████████████████              3/3  archive/done/tasks.md
    ```


[glob]: https://docs.python.org/3/library/fnmatch.html
