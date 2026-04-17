There is a difference between the _truth_ of the tasks as captured in the
files, where dependencies are declared, and the _availability_ of what can or
will be done by an individual on a team, so the person running `whatnext`
should be able to temporarily or permanently ignore a task or group of tasks
from showing up as available for them to work on.

- [X] `.whatnext.mute` merges with `.whatnext` to populate the 'mute' key in
      the config
        - contains a list, each entry being a timestamp and a match pattern
        - if the timestamp is now in the past, the entry is removed
- [X] listing tasks uses the mute list
        - anything matching a pattern is excluded from output
        - `--ignore-mute`, `--ignore-all`, `--all` bypasses this
        - show a count of muted tasks at the end
- [ ] `whatnext --mute 'period' 'pattern'` creates the entry
        - period is formatted like 1d, 2d, 1w, 1m, 2m3w
        - pattern cannot be empty
- [ ] if `whatnext [...]` produces no tasks, try again without the mute list
