Currently the test suite uses ./docs as input in some tests. This makes the
tests quite fragile -- we can't change the documentation without breaking the
tests.

- [X] catalogue each test in each file that relies upon input from the
      documentation directory, and add a task item in this file for it


# tests/deadline.bats

Uses `docs/deadlines.md`.

- [X] "before any deadline window, all tasks normal priority"
- [X] "within 3w window, book Christmas delivery becomes imminent"
- [X] "within default 2w window, complete and release becomes imminent"
- [X] "on deadline day, 0d task becomes high"
- [X] "past deadline, task becomes overdue"
- [X] "filter by overdue priority"
- [X] "filter by medium priority"
- [X] "filter by imminent priority"
- [X] "deadline date stripped from output"


# tests/list.bats

Uses default search (`docs/`, `archive/`, `tests/headerless.md`)
or explicit file args (`docs/basics.md`, `docs/prioritisation.md`).

- [X] "list tasks"
- [X] "default list is open, partial, blocked"
- [X] "list tasks, changes width"
- [X] "list all tasks"
- [X] "list tasks with --dir"
- [X] "warnings can be suppressed"
- [X] "filter just open tasks"
- [X] "filter just in progress tasks"
- [X] "filter just blocked tasks"
- [X] "filter just completed tasks"
- [X] "filter just cancelled tasks"
- [X] "state filters can be combined"
- [X] "state filter combines with search"
- [X] "filter by priority"
- [X] "filter multiple priorities"
- [X] "filter by priority and search"
- [X] "numeric argument limits output"
- [X] "limits combine"
- [X] "random selection"


# tests/matching.bats

Uses `docs/basics.md`, `docs/usage.md`, `example/`, `archive/`,
`tasks.md`, `.whatnext`.

- [X] "arg is task search"
- [X] "search term matches all under a heading"
- [X] "args is additive search"
- [X] "args can mix tasks and headings"
- [X] "arg matching dir restricts input"
- [X] "args match multiple dirs"
- [X] "dirs plus search"
- [X] "duplicate dirs do not duplicate output"
- [X] "multiple files"
- [X] "arg file path is respected in output"
- [X] "files plus search"
- [X] "matchers override default search space"
- [X] "no results is not an error"
- [X] "explicit file overrides ignore"


# tests/summary.bats

Uses default search (`docs/`, `archive/`, `tests/headerless.md`).

- [X] "summarise incomplete tasks"
- [X] "summarise all states"
- [X] "summarise all states, resized"
- [X] "summarise open tasks"
- [X] "summarise open tasks, relative"
- [X] "summarise partial tasks"
- [X] "summarise blocked tasks"
- [X] "summarise done tasks"
- [X] "summarise cancelled tasks"
- [X] "summarise multiple states"
- [X] "summarise high priority tasks"
- [X] "summarise medium priority tasks"
- [X] "summarise multiple priority levels"


# tests/test_file.py

`TestGroupedTasksBasics` uses `docs/basics.md`.

- [#] test_no_args_returns_all_grouped_by_priority
- [#] test_state_two_selected
- [#] test_search_terms
- [#] test_search_terms_and_state
- [#] test_search_terms_and_state_no_overlap
- [#] test_priority_high
- [#] test_priority_high_and_medium

`TestGroupedTasksPrioritisation` uses `docs/prioritisation.md`.

- [X] test_no_args_returns_all_grouped_by_priority
- [X] test_state_two_selected
- [X] test_search_terms
- [X] test_search_terms_and_state
- [X] test_search_terms_and_state_no_overlap
- [X] test_priority_high
- [X] test_priority_high_and_medium

`TestGroupedTasksDeadlines` uses `docs/deadlines.md`.

- [X] test_outside_all_windows_all_normal
- [X] test_inside_window_becomes_imminent
- [X] test_emphasis_applies_inside_window
- [X] test_high_emphasis_on_deadline_day
- [X] test_past_deadline_becomes_overdue

All three classes moved to `tests/test_grouping.py`. `TestGroupedTasksBasics`
dropped as a redundant weaker version of the prioritisation tests.
`TestGroupedTasksPrioritisation` uses `example/projects/harvest.md`.
`TestGroupedTasksDeadlines` uses `example/projects/tinsel.md`.


# wrap-up

- [ ] Fix any other failing tests
- [ ] Test deleting the docs directory, all tests should still pass.
- [ ] Any tests that use static content that mimics what is in ./example?
      Let's prefer using the example files except when stress testing things
      like the parser.
- [ ] Check coverage on grouped_tasks().
