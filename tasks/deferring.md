Deferring tasks improvements.

- [X] what if an \@after file is queried solo on the command line?
- [ ] \@after with headers from the current file, not just filenames?
- [X] \@after combined with --ignore on the command line produces warnings,
      it should check we're not deliberately ignoring

Deferring to another file should be relative to the current file, but it
is not working:

```
(computer)% whatnext
WARNING: tasks/notebooks.md: 'wiki/modelling.md' does not exist
```

- [X] \@after should be relative to the file in question
- [X] \@after filenames should support `~/...` as a shortcut to `$HOME`
