from textwrap import dedent

from whatnext.models import MarkdownFile, State


class TestSortedTasks:
    def test_sort_order(self):
        md_file = MarkdownFile.from_string(dedent("""\
            # First section

            - [#] cancelled in first
            - [X] complete in first
            - [<] blocked in first
            - [ ] open in first
            - [/] in progress in first

            # Second section

            - [<] blocked in second
            - [/] in progress in second
            """))

        assert md_file.as_string() == (
            "    # First section\n"
            "    - [/] in progress in first\n"
            "    - [ ] open in first\n"
            "    - [<] blocked in first\n"
            "    # Second section\n"
            "    - [/] in progress in second\n"
            "    - [<] blocked in second"
        )

        assert md_file.as_string(include_all=True) == (
            "    # First section\n"
            "    - [/] in progress in first\n"
            "    - [ ] open in first\n"
            "    - [<] blocked in first\n"
            "    - [X] complete in first\n"
            "    - [#] cancelled in first\n"
            "    # Second section\n"
            "    - [/] in progress in second\n"
            "    - [<] blocked in second"
        )

    def test_filter_by_state(self):
        md_file = MarkdownFile.from_string(dedent("""\
            # Section

            - [#] cancelled
            - [X] complete
            - [<] blocked
            - [ ] open
            - [/] in progress
            """))

        assert md_file.as_string(states={State.OPEN}) == (
            "    # Section\n"
            "    - [ ] open"
        )

        assert md_file.as_string(states={State.IN_PROGRESS}) == (
            "    # Section\n"
            "    - [/] in progress"
        )

        assert md_file.as_string(states={State.BLOCKED}) == (
            "    # Section\n"
            "    - [<] blocked"
        )

        assert md_file.as_string(states={State.COMPLETE}) == (
            "    # Section\n"
            "    - [X] complete"
        )

        assert md_file.as_string(states={State.CANCELLED}) == (
            "    # Section\n"
            "    - [#] cancelled"
        )
