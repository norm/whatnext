Currently the test suite uses ./docs as input in some tests. This makes the
tests quite fragile -- we can't change the documentation without breaking the
tests.

- [X] catalogue each test in each file that relies upon input from the
      documentation directory, and add a task item in this file for it


# tests/deadline.bats

Uses `docs/deadlines.md`.

- [ ] "before any deadline window, all tasks normal priority"
- [ ] "within 3w window, book Christmas delivery becomes imminent"
- [ ] "within default 2w window, complete and release becomes imminent"
- [ ] "on deadline day, 0d task becomes high"
- [ ] "past deadline, task becomes overdue"
- [ ] "filter by overdue priority"
- [ ] "filter by medium priority"
- [ ] "filter by imminent priority"
- [ ] "deadline date stripped from output"


# tests/list.bats

Uses default search (`docs/`, `archive/`, `tests/headerless.md`)
or explicit file args (`docs/basics.md`, `docs/prioritisation.md`).

- [ ] "list tasks"
- [ ] "default list is open, partial, blocked"
- [ ] "list tasks, changes width"
- [ ] "list all tasks"
- [ ] "list tasks with --dir"
- [ ] "warnings can be suppressed"
- [ ] "filter just open tasks"
- [ ] "filter just in progress tasks"
- [ ] "filter just blocked tasks"
- [ ] "filter just completed tasks"
- [ ] "filter just cancelled tasks"
- [ ] "state filters can be combined"
- [ ] "state filter combines with search"
- [ ] "filter by priority"
- [ ] "filter multiple priorities"
- [ ] "filter by priority and search"
- [ ] "numeric argument limits output"
- [ ] "limits combine"
- [ ] "random selection"


# tests/matching.bats

Uses `docs/basics.md`, `docs/usage.md`, `example/`, `archive/`,
`tasks.md`, `.whatnext`.

- [ ] "arg is task search"
- [ ] "search term matches all under a heading"
- [ ] "args is additive search"
- [ ] "args can mix tasks and headings"
- [ ] "arg matching dir restricts input"
- [ ] "args match multiple dirs"
- [ ] "dirs plus search"
- [ ] "duplicate dirs do not duplicate output"
- [ ] "multiple files"
- [ ] "arg file path is respected in output"
- [ ] "files plus search"
- [ ] "matchers override default search space"
- [ ] "no results is not an error"
- [ ] "explicit file overrides ignore"


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

- [ ] test_no_args_returns_all_grouped_by_priority
- [ ] test_state_two_selected
- [ ] test_search_terms
- [ ] test_search_terms_and_state
- [ ] test_search_terms_and_state_no_overlap
- [ ] test_priority_high
- [ ] test_priority_high_and_medium

`TestGroupedTasksPrioritisation` uses `docs/prioritisation.md`.

- [ ] test_no_args_returns_all_grouped_by_priority
- [ ] test_state_two_selected
- [ ] test_search_terms
- [ ] test_search_terms_and_state
- [ ] test_search_terms_and_state_no_overlap
- [ ] test_priority_high
- [ ] test_priority_high_and_medium

`TestGroupedTasksDeadlines` uses `docs/deadlines.md`.

- [ ] test_outside_all_windows_all_normal
- [ ] test_inside_window_becomes_imminent
- [ ] test_emphasis_applies_inside_window
- [ ] test_high_emphasis_on_deadline_day
- [ ] test_past_deadline_becomes_overdue


# wrap-up

- [ ] Test deleting the docs directory, all tests should still pass.
- [ ] Any tests that use static content that mimics what is in ./example?
      Let's prefer using the example files except when stress testing things
      like the parser.
- [ ] Check coverage on grouped_tasks().
