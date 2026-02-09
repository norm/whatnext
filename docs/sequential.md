# Sequential tasks

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
