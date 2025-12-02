from datetime import date
from textwrap import dedent

from whatnext.cli import format_tasks
from whatnext.models import MarkdownFile


class TestLimitOutput:
    obelisk = MarkdownFile(
        source="example/projects/obelisk.md",
        today=date(2025, 12, 25),
    )

    def test_limit_reduces_output(self):
        limited = format_tasks(
            [self.obelisk],
            width=40,
            include_all=False,
            limit=1,
        )
        expected = dedent("""\
            example/projects/obelisk.md:
                # Project Obelisk / OVERDUE 31y 2m
                - [<] watch archaeologists discover
                      (needs time machine)""")
        assert limited == expected

    def test_limit_spans_priority_groups(self):
        output = format_tasks(
            [self.obelisk],
            width=40,
            include_all=False,
            limit=3,
        )
        expected = dedent("""\
            example/projects/obelisk.md:
                # Project Obelisk / OVERDUE 31y 2m
                - [<] watch archaeologists discover
                      (needs time machine)

            example/projects/obelisk.md:
                # Project Obelisk / HIGH
                - [ ] bury obelisk in desert

            example/projects/obelisk.md:
                # Project Obelisk
                - [/] carve runes into obelisk""")
        assert output == expected
