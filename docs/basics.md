# Indicating the state of a task

Tasks have states, which are indicated as such:

```markdown
- [ ] empty, this task is outstanding
- [X] crossed, this task has been completed
```

Completed tasks are not listed by `whatnext`.

Headers are used in grouping tasks. The second-level header that comes next
shows these tasks are a part of the main header. This does not indicate
a lower priority, only grouping.

## Multiline tasks and indentation

Tasks can be indented, and their text can continue across lines:

```markdown
    - [ ] Lorem ipsum dolor sit amet,
          consectetur adipisicing elit,
          sed do  eiusmod  tempor   incididunt
          ut labore et     dolore magna aliqua.
```

The output of `whatnext` will wrap text to the terminal width, and does not
consider spacing of individual words or line wrapping semantically important.

Indentation of individual tasks is ignored, but the continuation has
to be indented to match, unlike in this task which is detected as
"Ut enim ad minim veniam," only:

```markdown
    - [ ] Ut enim ad minim veniam,
         quis nostrud exercitation ullamco laboris
```
