from datetime import date

from whatnext.cli import collect_tasks, find_markdown_files
from whatnext.models import MarkdownFile, Priority, State


class TestLimit:
    obelisk = MarkdownFile(
        source="example/projects/obelisk.md",
        today=date(2025, 12, 25),
    )

    def test_limit_of_one(self):
        tasks = collect_tasks([self.obelisk], include_all=False, limit=1)
        assert [t.as_dict() for t in tasks] == [
            {
                "heading": "# Project Obelisk",
                "state": State.BLOCKED,
                "text": "watch archaeologists discover (needs time machine)",
                "priority": Priority.OVERDUE,
                "due": date(1994, 10, 28),
                "imminent": date(1994, 10, 14),
            },
        ]

    def test_limit_spans_priority_groups(self):
        tasks = collect_tasks([self.obelisk], include_all=False, limit=3)
        assert [t.as_dict() for t in tasks] == [
            {
                "heading": "# Project Obelisk",
                "state": State.BLOCKED,
                "text": "watch archaeologists discover (needs time machine)",
                "priority": Priority.OVERDUE,
                "due": date(1994, 10, 28),
                "imminent": date(1994, 10, 14),
            },
            {
                "heading": "# Project Obelisk",
                "state": State.OPEN,
                "text": "bury obelisk in desert",
                "priority": Priority.HIGH,
                "due": date(2026, 1, 5),
                "imminent": date(2025, 12, 22),
            },
            {
                "heading": "# Project Obelisk",
                "state": State.IN_PROGRESS,
                "text": "carve runes into obelisk",
                "priority": Priority.NORMAL,
                "due": None,
                "imminent": None,
            },
        ]


class TestRandomSelection:
    today = date(2025, 12, 25)
    example_files = find_markdown_files("example", today, include_all=True)

    def test_randomise(self):
        all_tasks = collect_tasks(
            self.example_files,
            include_all=False,
        )
        assert len(all_tasks) > 1

        first_task = all_tasks[0].text
        found_different = False

        # this should exit long before 10,000 iterations, that's just safety
        for _ in range(10000):
            randomised = collect_tasks(
                self.example_files,
                include_all=False,
                limit=1,
                randomise=True,
            )
            if randomised[0].text != first_task:
                found_different = True
                break

        assert found_different

    def test_randomise_selects_from_full_pool(self):
        all_tasks = collect_tasks(
            self.example_files,
            include_all=False,
        )
        expected = {task.text for task in all_tasks}

        # in theory this can still fail because random
        seen = set()
        for _ in range(10000):
            tasks = collect_tasks(
                self.example_files,
                include_all=False,
                limit=1,
                randomise=True,
            )
            seen.add(tasks[0].text)

        assert seen == expected
