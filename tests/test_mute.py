from datetime import date
from textwrap import dedent

from whatnext.models import MarkdownFile
from whatnext.whatnext import filter_muted


def make_data(source_string):
    file = MarkdownFile(source_string=source_string, today=date(2025, 1, 1))
    return [(file, file.tasks)]


class TestFilterMuted:
    def test_empty_mute_list_returns_all_tasks(self):
        data = make_data(dedent("""\
            - [ ] first task
            - [ ] second task
        """))

        filtered, count = filter_muted(data, [])

        assert len(filtered[0][1]) == 2
        assert count == 0

    def test_pattern_matches_task_text(self):
        data = make_data(dedent("""\
            - [ ] buy apples
            - [ ] buy oranges
        """))

        filtered, count = filter_muted(data, ["apples"])

        assert len(filtered[0][1]) == 1
        assert filtered[0][1][0].text == "buy oranges"
        assert count == 1

    def test_pattern_matches_heading(self):
        data = make_data(dedent("""\
            # Shopping
            - [ ] buy apples
            # Gardening
            - [ ] plant seeds
        """))

        filtered, count = filter_muted(data, ["shopping"])

        assert len(filtered[0][1]) == 1
        assert filtered[0][1][0].text == "plant seeds"
        assert count == 1

    def test_matching_is_case_insensitive(self):
        data = make_data(dedent("""\
            - [ ] Buy APPLES
            - [ ] buy oranges
        """))

        filtered, count = filter_muted(data, ["apples"])

        assert len(filtered[0][1]) == 1
        assert filtered[0][1][0].text == "buy oranges"
        assert count == 1

    def test_multiple_patterns_any_match_excludes(self):
        data = make_data(dedent("""\
            - [ ] buy apples
            - [ ] buy oranges
            - [ ] buy bananas
        """))

        filtered, count = filter_muted(data, ["apples", "oranges"])

        assert len(filtered[0][1]) == 1
        assert filtered[0][1][0].text == "buy bananas"
        assert count == 2

    def test_no_match_includes_task(self):
        data = make_data(dedent("""\
            - [ ] buy apples
            - [ ] buy oranges
        """))

        filtered, count = filter_muted(data, ["bananas"])

        assert len(filtered[0][1]) == 2
        assert count == 0

    def test_counts_across_multiple_files(self):
        file1 = MarkdownFile(
            source_string="- [ ] buy apples\n- [ ] buy oranges\n",
            today=date(2025, 1, 1),
        )
        file2 = MarkdownFile(
            source_string="- [ ] plant apples\n- [ ] plant oranges\n",
            today=date(2025, 1, 1),
        )
        data = [(file1, file1.tasks), (file2, file2.tasks)]

        filtered, count = filter_muted(data, ["apples"])

        assert len(filtered[0][1]) == 1
        assert len(filtered[1][1]) == 1
        assert count == 2

    def test_pattern_matches_filename(self):
        file = MarkdownFile(
            source_string="- [ ] first task\n- [ ] second task\n",
            path="shopping.md",
            today=date(2025, 1, 1),
        )
        data = [(file, file.tasks)]

        filtered, count = filter_muted(data, ["shopping"])

        assert len(filtered[0][1]) == 0
        assert count == 2
