# Including files

The purpose of multiple task files is to encourage breaking large projects
down, and to keep otherwise unrelated work separate. But at times you want to
both have multiple task files and one unified view of the tasks. If you need
to include one task file inside another, use the `@include`

As an example, a project has a lot of small, repetative tasks to perform on
multiple targets. A directory of multiple task files, one per target, would
overwhelm the output of `whatnext`, even if a directive such as `@queue` was
used.

However, using an index task file and `@include` gives us more control:

```markdown
@queue

@include subtasks/a.md
@include subtasks/b.md
@include subtasks/c.md
@include subtasks/d.md
```

The result of this would be all of the subtasks are treated as though they
are in the index file, and that file controls the output with `@queue`
so that only the next task of `a.md` appears.
