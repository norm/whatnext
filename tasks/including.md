If `tasks/list.md` contains the directive `@include tasks.md`, running
`whatnext` should behave as though the contents of `tasks.md` were inside
`list.md`.

- [X] `@include` directive pulls another file's contents in
        - the included file is read and substituted into this file at the
          directive
        - the included file is no longer considered as a source
