from whatnext.models import Task, State


class TestTask:
    task = Task(
        "# Indicating the state of a task / Multiline tasks and indentation",

        "- [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, "
        "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",

        State.INCOMPLETE,
    )

    def test_wraps_at_40_chars(self):
        assert self.task.wrapped_text(width=40) == [
            "    - [ ] Lorem ipsum dolor sit amet,",
            "          consectetur adipisicing elit,",
            "          sed do eiusmod tempor",
            "          incididunt ut labore et dolore",
            "          magna aliqua.",
        ]
        assert self.task.wrapped_heading(width=40) == [
            "    # Indicating the state of a task /",
            "      Multiline tasks and indentation",
        ]

    def test_no_wrap_at_120_chars(self):
        assert self.task.wrapped_text(width=120) == [
            "    - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, "
            "sed do eiusmod tempor incididunt ut labore et dolore",
            "          magna aliqua.",
        ]
        assert self.task.wrapped_heading(width=120) == [
            "    # Indicating the state of a task / Multiline tasks and indentation"
        ]

    def test_default_width_80_chars(self):
        assert self.task.wrapped_text() == [
            "    - [ ] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do",  # noqa: E501
            "          eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        ]
        assert self.task.wrapped_heading() == [
            "    # Indicating the state of a task / Multiline tasks and indentation"
        ]
