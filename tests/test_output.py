from datetime import date
from textwrap import dedent

from whatnext.cli import format_tasks
from whatnext.models import MarkdownFile, Priority, State


class TestColourOutput:
    obelisk = MarkdownFile(
        source="example/projects/obelisk.md",
        today=date(2025, 12, 25),
    )
    obelisk_early = MarkdownFile(
        source="example/projects/obelisk.md",
        today=date(1990, 1, 1),
    )
    tasks = MarkdownFile(
        source="example/tasks.md",
        today=date(2025, 12, 25),
    )

    def test_overdue_tasks_output(self):
        output = format_tasks(
            [self.obelisk],
            width=80,
            include_all=False,
            priorities={Priority.OVERDUE},
        )
        expected = dedent("""\
            example/projects/obelisk.md:
                # Project Obelisk / OVERDUE 31y 2m
                - [<] watch archaeologists discover (needs time machine)""")
        assert output == expected

    def test_overdue_tasks_output_is_bold_magenta(self):
        output = format_tasks(
            [self.obelisk],
            width=80,
            include_all=False,
            priorities={Priority.OVERDUE},
            use_colour=True,
        )
        expected = dedent("""\
            \x1b[1m\x1b[35mexample/projects/obelisk.md:
                # Project Obelisk / OVERDUE 31y 2m
                - [<] watch archaeologists discover (needs time machine)\x1b[0m""")
        assert output == expected

    def test_imminent_tasks_output(self):
        output = format_tasks(
            [self.tasks],
            width=80,
            include_all=False,
            priorities={Priority.IMMINENT},
        )
        expected = dedent("""\
            example/tasks.md:
                # Get S Done / IMMINENT 11d
                - [ ] start third project""")
        assert output == expected

    def test_imminent_tasks_output_is_green(self):
        output = format_tasks(
            [self.tasks],
            width=80,
            include_all=False,
            priorities={Priority.IMMINENT},
            use_colour=True,
        )
        expected = dedent("""\
            \x1b[32mexample/tasks.md:
                # Get S Done / IMMINENT 11d
                - [ ] start third project\x1b[0m""")
        assert output == expected

    def test_blocked_task_text_is_cyan(self):
        output = format_tasks(
            [self.obelisk_early],
            width=80,
            include_all=False,
            states={State.BLOCKED},
            use_colour=True,
        )
        cyan = "\x1b[36m"
        reset = "\x1b[0m"
        task = f"{cyan}watch archaeologists discover (needs time machine){reset}"
        expected = dedent(f"""\
            example/projects/obelisk.md:
                # Project Obelisk
                - [<] {task}""")
        assert output == expected

    def test_in_progress_task_text_is_yellow(self):
        output = format_tasks(
            [self.obelisk_early],
            width=80,
            include_all=False,
            states={State.IN_PROGRESS},
            use_colour=True,
        )
        yellow = "\x1b[33m"
        reset = "\x1b[0m"
        expected = dedent(f"""\
            example/projects/obelisk.md:
                # Project Obelisk
                - [/] {yellow}carve runes into obelisk{reset}""")
        assert output == expected
