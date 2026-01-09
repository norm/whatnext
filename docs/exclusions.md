# Excluding files

If you need to ignore a file (or three), but don't want to keep typing out
the `--ignore` option, there are two ways of doing this.

## Exclude a single file

To have a file declare itself not suitable for finding tasks within,
add this marker anywhere in the file:

```markdown
@notnext [explanation if necessary]
```

## Exclude multiple files

You can include a `.whatnext` file in the directory being examined for tasks:

```toml
# not considered in any summaries
ignore = [
    'README.md',
    'tasks.md',
    'docs/usage.md',
]
```

If you need to store it somewhere else, or have it be a different
filename, you can use the `--config` option, or set the location
in the environment variable `WHATNEXT_CONFIG`.
