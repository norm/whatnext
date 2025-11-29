# What next?

Document your tasks in Markdown files, using ["standard"][sn] notation:

```markdown
- [ ] open, this task is outstanding
- [/] in progress, this task is partially complete
- [X] complete, this task has been finished
- [#] cancelled, this task has been scratched
- [<] blocked, this task needs more input
```

Then install `whatnext`:

```bash
pip install whatnext
```

Now run it and it'll tell you what's next:

```bash
(computer)% whatnext
README.md:
    # What next?
    - [ ] empty, this task is outstanding
```

More detail to be found:

- [The basics of task formatting](docs/basics.md)
- [whatnext usage and arguments](docs/usage.md)
- [The `.whatnext` file](docs/dotwhatnext.md)


## The reason

I like to keep tasks in Markdown files. That way they can be interspersed
within instructions, serving as reminders, FIXMEs, and other todos.


[sn]: https://blog.github.com/2013-01-09-task-lists-in-gfm-issues-pulls-comments/
