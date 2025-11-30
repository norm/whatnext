from whatnext.models import MarkdownFile, Priority, State


def tasks(grouped_tasks):
    return tuple(
        [(t.heading, t.text, t.state, t.priority) for t in group]
        for group in grouped_tasks
    )


class TestGroupedTasksBasics:
    file = MarkdownFile("docs/basics.md")

    def test_no_args_returns_all_grouped_by_priority(self):
        assert tasks(self.file.grouped_tasks()) == (
            [],
            [],
            [
                (
                    "# Indicating the state of a task",
                    "in progress, this task is partially complete",
                    State.IN_PROGRESS,
                    Priority.NORMAL
                ),
                (
                    "# Indicating the state of a task",
                    "open, this task is outstanding",
                    State.OPEN,
                    Priority.NORMAL
                ),
                (
                    "# Indicating the state of a task",
                    "blocked, this task needs more input",
                    State.BLOCKED,
                    Priority.NORMAL
                ),
                (
                    "# Indicating the state of a task",
                    "complete, this task has been finished",
                    State.COMPLETE,
                    Priority.NORMAL
                ),
                (
                    "# Indicating the state of a task",
                    "cancelled, this task has been scratched",
                    State.CANCELLED,
                    Priority.NORMAL
                ),
                (
                    "# Indicating the state of a task / Multiline tasks and indentation",  # noqa: E501
                    "Lorem ipsum dolor sit amet,\n"
                    "consectetur adipisicing elit,\n"
                    "sed do  eiusmod  tempor   incididunt\n"
                    "ut labore et     dolore magna aliqua.",
                    State.OPEN,
                    Priority.NORMAL
                ),
                (
                    "# Indicating the state of a task / Multiline tasks and indentation",  # noqa: E501
                    "Ut enim ad minim veniam,",
                    State.OPEN,
                    Priority.NORMAL
                ),
            ],
        )

    def test_state_two_selected(self):
        assert tasks(
            self.file.grouped_tasks(states={State.IN_PROGRESS, State.BLOCKED})
        ) == (
            [],
            [],
            [
                (
                    "# Indicating the state of a task",
                    "in progress, this task is partially complete",
                    State.IN_PROGRESS,
                    Priority.NORMAL
                ),
                (
                    "# Indicating the state of a task",
                    "blocked, this task needs more input",
                    State.BLOCKED,
                    Priority.NORMAL
                ),
            ],
        )

    def test_search_terms(self):
        assert tasks(self.file.grouped_tasks(search_terms=["multiline"])) == (
            [],
            [],
            [
                (
                    "# Indicating the state of a task / Multiline tasks and indentation",  # noqa: E501
                    "Lorem ipsum dolor sit amet,\n"
                    "consectetur adipisicing elit,\n"
                    "sed do  eiusmod  tempor   incididunt\n"
                    "ut labore et     dolore magna aliqua.",
                    State.OPEN,
                    Priority.NORMAL
                ),
                (
                    "# Indicating the state of a task / Multiline tasks and indentation",  # noqa: E501
                    "Ut enim ad minim veniam,",
                    State.OPEN,
                    Priority.NORMAL
                ),
            ],
        )

    def test_search_terms_and_state(self):
        assert tasks(
            self.file.grouped_tasks(
                states={State.COMPLETE, State.CANCELLED},
                search_terms=["task"],
            )
        ) == (
            [],
            [],
            [
                (
                    "# Indicating the state of a task",
                    "complete, this task has been finished",
                    State.COMPLETE,
                    Priority.NORMAL
                ),
                (
                    "# Indicating the state of a task",
                    "cancelled, this task has been scratched",
                    State.CANCELLED,
                    Priority.NORMAL
                ),
            ],
        )

    def test_search_terms_and_state_no_overlap(self):
        assert tasks(
            self.file.grouped_tasks(
                states={State.COMPLETE},
                search_terms=["lorem"],
            )
        ) == ([], [], [])


class TestGroupedTasksPrioritisation:
    file = MarkdownFile("docs/prioritisation.md")

    def test_no_args_returns_all_grouped_by_priority(self):
        assert tasks(self.file.grouped_tasks()) == (
            [
                (
                    "# Prioritisation",
                    "super-urgent task",
                    State.OPEN,
                    Priority.HIGH
                ),
                (
                    "# **do these first**",
                    "inherently high priority task, because of the header",
                    State.OPEN,
                    Priority.HIGH
                ),
                (
                    "# **do these first**",
                    "no extra priority, still listed second",
                    State.OPEN,
                    Priority.HIGH
                ),
                (
                    "# **do these first** / grouped, but still highest priority",
                    "header priority cascades down",
                    State.COMPLETE,
                    Priority.HIGH
                ),
            ],
            [
                (
                    "# Prioritisation",
                    "semi-urgent task",
                    State.OPEN,
                    Priority.MEDIUM
                ),
            ],
            [
                (
                    "# Prioritisation",
                    "not a high priority task",
                    State.IN_PROGRESS,
                    Priority.NORMAL
                ),
                (
                    "# Prioritisation",
                    "top, but not urgent, task",
                    State.OPEN,
                    Priority.NORMAL
                ),
                (
                    "# more tasks",
                    "normal priority, new header resets that",
                    State.CANCELLED,
                    Priority.NORMAL
                ),
            ],
        )

    def test_state_two_selected(self):
        assert tasks(
            self.file.grouped_tasks(states={State.IN_PROGRESS, State.BLOCKED})
        ) == (
            [],
            [],
            [
                (
                    "# Prioritisation",
                    "not a high priority task",
                    State.IN_PROGRESS,
                    Priority.NORMAL
                ),
            ],
        )

    def test_search_terms(self):
        assert tasks(self.file.grouped_tasks(search_terms=["priority"])) == (
            [
                (
                    "# **do these first**",
                    "inherently high priority task, because of the header",
                    State.OPEN,
                    Priority.HIGH
                ),
                (
                    "# **do these first**",
                    "no extra priority, still listed second",
                    State.OPEN,
                    Priority.HIGH
                ),
                (
                    "# **do these first** / grouped, but still highest priority",
                    "header priority cascades down",
                    State.COMPLETE,
                    Priority.HIGH
                ),
            ],
            [],
            [
                (
                    "# Prioritisation",
                    "not a high priority task",
                    State.IN_PROGRESS,
                    Priority.NORMAL
                ),
                (
                    "# more tasks",
                    "normal priority, new header resets that",
                    State.CANCELLED,
                    Priority.NORMAL
                ),
            ],
        )

    def test_search_terms_and_state(self):
        assert tasks(
            self.file.grouped_tasks(
                states={State.COMPLETE},
                search_terms=["header"],
            )
        ) == (
            [
                (
                    "# **do these first** / grouped, but still highest priority",
                    "header priority cascades down",
                    State.COMPLETE,
                    Priority.HIGH
                ),
            ],
            [],
            [],
        )

    def test_search_terms_and_state_no_overlap(self):
        assert tasks(
            self.file.grouped_tasks(
                states={State.COMPLETE},
                search_terms=["urgent"],
            )
        ) == ([], [], [])
