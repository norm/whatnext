**One at a time task visibility.**
For sequential checklists where you have tasks that can/should only be
done one at a time, but don't want to make multiple files for one task
to set up `@after` ordering.

List:
- all `[/]` in-progress tasks (there may be multiple)
- if none, the highest priority open task
- if none, the highest priority blocked task

- [X] Add `@queue` directive to files, limiting a file's output to one(ish)
