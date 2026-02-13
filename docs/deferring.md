# Deferring tasks

Some tasks either can't or won't be considered until some other tasks
are done, so you can indicate that these tasks _should not show up_ yet:

    # Someday

    @after

    - [ ] rewrite everything in Rust

`@after` on a line by itself applies to the whole file, on a header it
applies to the section, and on a task only applies to that task.

If you need to include it without it being parsed, either surround it in
backticks (` `@after` `) or put a backslash before (`\@after`).

To ignore this when querying for tasks, use `whatnext --ignore-after`
(plus `whatnext --all` will always show all tasks regardless).


## After ... what?

Without any clarification, any deferred tasks will only appear in `whatnext`
output once every other non-deferred task is completed.

If you are trying to define project dependencies, you can indicate this
by naming the other task file(s):

    # Stage three

    @after stage_one.md stage_two.md

    - [ ] design the booster separation

Filenames are resolved relative to the file containing the `@after`
directive.

    @after ../project-b/setup.md
    @after subtask/notes.md
    @after ~/tasks/dependency.md

Circular dependencies (where A depends on B and B depends on A) will
cause an error showing the cycle. Referencing a nonexistent file will
produce a warning.

