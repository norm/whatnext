# **BUGS**

This file is for bugs found.
Bugs should always be fixed before any new features.
New features go in `./tasks/[feature].md`.

- [X] usage links to example/ incorrectly
- [X] next doc nested list needs spacing out to render on github
- [X] next -a didn't add to end of file when registering these bugs
- [X] bare `@after` should wait for tasks with `@after file.md`, not just
      tasks with no `@after` at all
- [X] bug in `next`:
> (sinister ~)% next whatnext something -e something
> usage: next [-h] [--version] [-a] [text ...]
> next: error: unrecognized arguments: -e something
- [X] headers in fenceblocks are used as headers and should not be -- should whatnext ignore tasks in fenceblocks too?
- [X] `--summary --relative` with multiple states uses the same character for the second selected state and the unselected complement
