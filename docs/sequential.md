# Sequential tasks

For ordering tasks within a file, you can use `@queue` and `@phase`.


## One task at a time

For simpler work that is done sequentially, either because they have to be
done one-after-the-other, or because they represent larger blocks that are
not broken down into subtasks, add `@queue` to the file:

```markdown
@queue

- [ ] backup production database
- [ ] run migration to add audit columns
- [ ] backfill audit data from logs
```

When querying, [priorities](prioritisation.md) and [deadlines](deadlines.md)
will apply as usual within the file, and only the most important or
top-most task is presented. If any tasks are marked as in-progress,
they will all be shown.

```bash
(computer)% whatnext
auditing.md:
    - [ ] backup production database
```

When querying with `--all` or `--summary` arguments, all tasks are presented.


## One section at a time

For work with multiple tasks with an inherent grouping and you don't want to
break the work into multiple files, instead break the work into sections and
include `@phase` in the header:

```markdown
# Red @phase
- [ ] add/amend tests to assert desired behaviour
- [ ] prove new tests fail

# Green @phase
- [ ] update code to implement desired behaviour
- [ ] prove tests pass

# Refactor @phase
- [ ] simplify and improve new code
- [ ] prove tests still pass
```

This creates a dependency chain within the file; the first phase is
always visible, and subsequent phases will only show when all previous
phases are complete.
