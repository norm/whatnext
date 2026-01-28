from datetime import date
from textwrap import dedent

from whatnext.models import MarkdownFile, Priority, State


class TestContentFiltering:
    def filtered_content(self, source):
        file = MarkdownFile(
            source=source,
            today=date(2025, 1, 1),
        )
        return "\n".join(
            line
                for _, line in file.relevant_content()
        ) + "\n"

    def test_tasks(self):
        assert self.filtered_content("example/tasks.md") == dedent("""\
            # Get S Done
            - [ ] **come up with better projects** @2025-11-01
            - [ ] start third project @2026-01-05
            - [ ] _question entire existence_
        """)

    def test_template(self):
        assert self.filtered_content("example/template.md") == dedent("""\
            @notnext this is an example template
            # New Project Template
            - [ ] define project scope
            - [ ] identify stakeholders
            - [ ] create timeline
        """)

    def test_obelisk(self):
        assert self.filtered_content("example/projects/obelisk.md") == dedent("""\
            # Project Obelisk
            ```whatnext
            Something   something    star    gate
            ```
            - [X] **secure desert burial site**
            - [ ] research into runic meaning
            - [/] carve runes into obelisk
            - [ ] **bury obelisk in desert** @2026-01-05
            ## Discovery
            ~~~whatnext
            Mess with Jackson
            ~~~
            - [<] watch archaeologists discover (needs time machine) @1994-10-28
        """)

    def test_curtain(self):
        assert self.filtered_content("example/projects/curtain.md") == dedent("""\
            # Project Curtain
            @after
            ## Final bow @after tangerine.md
            - [ ] Take a bow
            ## Safety @after obelisk.md
            - [ ] Lower the safety curtain
            ## Close the theatre
            - [ ] Escort everyone out
            - [ ] Shut up shop
        """)

    def test_harvest(self):
        assert self.filtered_content("example/projects/harvest.md") == dedent("""\
            # Project Harvest
            - [/] turn compost heap
            - [ ] plan raised bed layout
            - [ ] _buy copper tape for slugs_
            - [ ] **order squash seeds**
            ## **Spring planting**
            - [ ] sow tomato seeds indoors
            - [ ] direct sow carrots
            ## Hardening off
            - [X] move seedlings to cold frame
            ## Autumn
            - [#] enter giant marrow contest (too late)
        """)

    def test_tinsel(self):
        assert self.filtered_content("example/projects/tinsel.md") == dedent("""\
            # Project Tinsel
            - [ ] send Christmas cards @2025-12-05
            ## Christmas dinner
            - [ ] book Christmas delivery @2025-12-23/3w
            - [ ] _prep the make-ahead gravy_ @2025-12-25/1d
            - [ ] **roast the potatoes** @2025-12-25/0d
            - [ ] prep sprouts @2025-12-25
        """)

    def test_tangerine(self):
        assert self.filtered_content(
            "example/archived/projects/tangerine.md"
        ) == dedent("""\
            # Project Tangerine
            - [X] acquire trebuchet plans
            - [X] source counterweight materials
            - [X] build it
            - [#] throw fruit at neighbours (they moved away)
        """)


class TestFileParsing:
    def test_open_task(self):
        file = MarkdownFile(
            source_string="- [ ] open, this task is outstanding",
            today=date(2025, 1, 1),
        )
        assert len(file.tasks) == 1
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.OPEN,
            "text": "open, this task is outstanding",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_in_progress_task(self):
        file = MarkdownFile(
            source_string="- [/] in progress, this task is partially complete",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.IN_PROGRESS,
            "text": "in progress, this task is partially complete",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_complete_task(self):
        file = MarkdownFile(
            source_string="- [X] complete, this task has been finished",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.COMPLETE,
            "text": "complete, this task has been finished",
            "priority": None,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_cancelled_task(self):
        file = MarkdownFile(
            source_string="- [#] cancelled, this task has been scratched",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.CANCELLED,
            "text": "cancelled, this task has been scratched",
            "priority": None,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_blocked_task(self):
        file = MarkdownFile(
            source_string="- [<] blocked, this task needs more input",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.BLOCKED,
            "text": "blocked, this task needs more input",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_multiline_task(self):
        file = MarkdownFile(
            source_string=dedent("""\
                - [ ] Lorem ipsum dolor sit amet,
                      consectetur adipisicing elit,
                      sed do  eiusmod  tempor   incididunt
                      ut labore et     dolore magna aliqua.
            """),
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.OPEN,
            "text": (
                "Lorem ipsum dolor sit amet, "
                "consectetur adipisicing elit, "
                "sed do eiusmod tempor incididunt "
                "ut labore et dolore magna aliqua."
            ),
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_multiline_task_wrong_indent(self):
        file = MarkdownFile(
            source_string=dedent("""\
                - [ ] Ut enim ad minim veniam,
                     quis nostrud exercitation ullamco laboris
            """),
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.OPEN,
            "text": "Ut enim ad minim veniam,",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_normal_priority(self):
        file = MarkdownFile(
            source_string="- [ ] top, but not urgent, task",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.OPEN,
            "text": "top, but not urgent, task",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_medium_priority(self):
        file = MarkdownFile(
            source_string="- [ ] _semi-urgent task_",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.OPEN,
            "text": "semi-urgent task",
            "priority": Priority.MEDIUM,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_high_priority(self):
        file = MarkdownFile(
            source_string="- [ ] **super-urgent task**",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.OPEN,
            "text": "super-urgent task",
            "priority": Priority.HIGH,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_priority_from_header_and_precedence(self):
        file = MarkdownFile(
            source_string=dedent("""\
                - [/] not a high priority task

                # **do these first**

                - [ ] inherently high priority task, because of the header
                - [ ] **no extra priority, still listed second**

                ## grouped, but still highest priority

                - [X] header priority cascades down

                # more tasks

                - [#] normal priority, new header resets that
            """),
            today=date(2025, 1, 1),
        )
        assert len(file.tasks) == 5
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.IN_PROGRESS,
            "text": "not a high priority task",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }
        assert file.tasks[1].as_dict() == {
            "heading": "# do these first",
            "state": State.OPEN,
            "text": "inherently high priority task, because of the header",
            "priority": Priority.HIGH,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 5,
            "deferred": None,
        }
        assert file.tasks[2].as_dict() == {
            "heading": "# do these first",
            "state": State.OPEN,
            "text": "no extra priority, still listed second",
            "priority": Priority.HIGH,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 6,
            "deferred": None,
        }
        assert file.tasks[3].as_dict() == {
            "heading": "# do these first / grouped, but still highest priority",
            "state": State.COMPLETE,
            "text": "header priority cascades down",
            "priority": None,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 10,
            "deferred": None,
        }
        assert file.tasks[4].as_dict() == {
            "heading": "# more tasks",
            "state": State.CANCELLED,
            "text": "normal priority, new header resets that",
            "priority": None,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 14,
            "deferred": None,
        }

    def test_high_task_under_medium_header(self):
        file = MarkdownFile(
            source_string=dedent("""\
                # _Medium section_

                - [ ] **high priority task**
            """),
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": "# Medium section",
            "state": State.OPEN,
            "text": "high priority task",
            "priority": Priority.HIGH,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 3,
            "deferred": None,
        }

    def test_medium_task_under_high_header(self):
        file = MarkdownFile(
            source_string=dedent("""\
                # **High section**

                - [ ] _medium priority task_
            """),
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": "# High section",
            "state": State.OPEN,
            "text": "medium priority task",
            "priority": Priority.HIGH,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 3,
            "deferred": None,
        }

    def test_medium_subsection_under_high_header(self):
        file = MarkdownFile(
            source_string=dedent("""\
                # **High section**

                ## _Medium subsection_

                - [ ] task in medium subsection
            """),
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": "# High section / Medium subsection",
            "state": State.OPEN,
            "text": "task in medium subsection",
            "priority": Priority.HIGH,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 5,
            "deferred": None,
        }

    def test_simple_deadline(self):
        file = MarkdownFile(
            source_string=dedent("""\
                # version 0.5
                - [ ] complete and release @2025-12-05
            """),
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": "# version 0.5",
            "state": State.OPEN,
            "text": "complete and release",
            "priority": Priority.NORMAL,
            "due": date(2025, 12, 5),
            "imminent": date(2025, 11, 21),
            "annotation": None,
            "line": 2,
            "deferred": None,
        }

    def test_deadline_outside_urgency_window_no_priority(self):
        file = MarkdownFile(
            source="example/projects/tinsel.md",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": "# Project Tinsel",
            "state": State.OPEN,
            "text": "send Christmas cards",
            "priority": Priority.NORMAL,
            "due": date(2025, 12, 5),
            "imminent": date(2025, 11, 21),
            "annotation": None,
            "line": 3,
            "deferred": None,
        }
        assert file.tasks[1].as_dict() == {
            "heading": "# Project Tinsel / Christmas dinner",
            "state": State.OPEN,
            "text": "book Christmas delivery",
            "priority": Priority.NORMAL,
            "due": date(2025, 12, 23),
            "imminent": date(2025, 12, 2),
            "annotation": None,
            "line": 7,
            "deferred": None,
        }
        assert file.tasks[2].as_dict() == {
            "heading": "# Project Tinsel / Christmas dinner",
            "state": State.OPEN,
            "text": "prep the make-ahead gravy",
            "priority": Priority.NORMAL,
            "due": date(2025, 12, 25),
            "imminent": date(2025, 12, 24),
            "annotation": None,
            "line": 8,
            "deferred": None,
        }
        assert file.tasks[3].as_dict() == {
            "heading": "# Project Tinsel / Christmas dinner",
            "state": State.OPEN,
            "text": "roast the potatoes",
            "priority": Priority.NORMAL,
            "due": date(2025, 12, 25),
            "imminent": date(2025, 12, 25),
            "annotation": None,
            "line": 9,
            "deferred": None,
        }
        assert file.tasks[4].as_dict() == {
            "heading": "# Project Tinsel / Christmas dinner",
            "state": State.OPEN,
            "text": "prep sprouts",
            "priority": Priority.NORMAL,
            "due": date(2025, 12, 25),
            "imminent": date(2025, 12, 11),
            "annotation": None,
            "line": 10,
            "deferred": None,
        }

    def test_deadline_inside_urgency_gains_imminent_priority(self):
        file = MarkdownFile(
            source="example/projects/tinsel.md",
            today=date(2025, 12, 15),
        )
        assert file.tasks[0].priority == Priority.OVERDUE
        assert file.tasks[1].priority == Priority.IMMINENT
        assert file.tasks[2].priority == Priority.NORMAL
        assert file.tasks[3].priority == Priority.NORMAL
        assert file.tasks[4].priority == Priority.IMMINENT

    def test_deadline_inside_urgency_regains_priority(self):
        file = MarkdownFile(
            source="example/projects/tinsel.md",
            today=date(2025, 12, 24),
        )
        assert file.tasks[0].priority == Priority.OVERDUE
        assert file.tasks[1].priority == Priority.OVERDUE
        assert file.tasks[2].priority == Priority.MEDIUM
        assert file.tasks[3].priority == Priority.NORMAL
        assert file.tasks[4].priority == Priority.IMMINENT

    def test_deadline_past_deadline_always_overdue(self):
        file = MarkdownFile(
            source="example/projects/tinsel.md",
            today=date(2025, 12, 26),
        )
        assert file.tasks[0].priority == Priority.OVERDUE
        assert file.tasks[1].priority == Priority.OVERDUE
        assert file.tasks[2].priority == Priority.OVERDUE
        assert file.tasks[3].priority == Priority.OVERDUE
        assert file.tasks[4].priority == Priority.OVERDUE

    def test_invalid_date_ignored(self):
        file = MarkdownFile(
            source_string="- [ ] task with bad date @2025-13-45",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.OPEN,
            "text": "task with bad date @2025-13-45",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_non_date_format_ignored(self):
        file = MarkdownFile(
            source_string="- [ ] task with text @december-25",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.OPEN,
            "text": "task with text @december-25",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_invalid_urgency_invalidates_deadline(self):
        file = MarkdownFile(
            source_string="- [ ] promote Random Task @2025-12-15/3m",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.OPEN,
            "text": "promote Random Task @2025-12-15/3m",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_email_not_deadline(self):
        file = MarkdownFile(
            source_string="- [ ] email user@2025-12-15.com",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].as_dict() == {
            "heading": None,
            "state": State.OPEN,
            "text": "email user@2025-12-15.com",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 1,
            "deferred": None,
        }

    def test_backticks_prevent_deadline_parsing(self):
        file = MarkdownFile(
            source_string="- [ ] document `@2025-12-15` format",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].text == "document `@2025-12-15` format"
        assert file.tasks[0].due is None

    def test_backslash_prevents_deadline_parsing(self):
        file = MarkdownFile(
            source_string=r"- [ ] document \@2025-12-15 format",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].text == r"document \@2025-12-15 format"
        assert file.tasks[0].due is None

    def test_backticks_with_urgency_not_parsed(self):
        file = MarkdownFile(
            source_string="- [ ] use `@2025-12-15/2w` syntax",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].text == "use `@2025-12-15/2w` syntax"
        assert file.tasks[0].due is None

    def test_backslash_with_urgency_not_parsed(self):
        file = MarkdownFile(
            source_string=r"- [ ] use \@2025-12-15/2w syntax",
            today=date(2025, 1, 1),
        )
        assert file.tasks[0].text == r"use \@2025-12-15/2w syntax"
        assert file.tasks[0].due is None


class TestAnnotationParsing:
    def test_annotations_associated_with_headings(self):
        file = MarkdownFile(
            source="example/projects/obelisk.md",
            today=date(2025, 1, 1),
        )
        assert len(file.tasks) == 5
        assert file.tasks[0].as_dict() == {
            "heading": "# Project Obelisk",
            "state": State.COMPLETE,
            "text": "secure desert burial site",
            "priority": None,
            "due": None,
            "imminent": None,
            "annotation": "Something something star gate",
            "line": 7,
            "deferred": None,
        }
        assert file.tasks[1].as_dict() == {
            "heading": "# Project Obelisk",
            "state": State.OPEN,
            "text": "research into runic meaning",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": "Something something star gate",
            "line": 8,
            "deferred": None,
        }
        assert file.tasks[2].as_dict() == {
            "heading": "# Project Obelisk",
            "state": State.IN_PROGRESS,
            "text": "carve runes into obelisk",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": "Something something star gate",
            "line": 9,
            "deferred": None,
        }
        assert file.tasks[3].as_dict() == {
            "heading": "# Project Obelisk",
            "state": State.OPEN,
            "text": "bury obelisk in desert",
            "priority": Priority.NORMAL,
            "due": date(2026, 1, 5),
            "imminent": date(2025, 12, 22),
            "annotation": "Something something star gate",
            "line": 10,
            "deferred": None,
        }
        assert file.tasks[4].as_dict() == {
            "heading": "# Project Obelisk / Discovery",
            "state": State.BLOCKED,
            "text": "watch archaeologists discover (needs time machine)",
            "priority": Priority.OVERDUE,
            "due": date(1994, 10, 28),
            "imminent": date(1994, 10, 14),
            "annotation": "Mess with Jackson",
            "line": 21,
            "deferred": None,
        }

    def test_other_fenced_blocks_ignored(self):
        file = MarkdownFile(
            source_string=dedent("""\
                # Only 'whatnext' blocks

                ```
                notes notes notes
                ```

                - [ ] not this one

                ##

                ```python
                print("hello")
                ```

                - [ ] not this one either
            """),
            today=date(2025, 1, 1),
        )
        assert len(file.tasks) == 2
        assert file.tasks[0].as_dict() == {
            "heading": "# Only 'whatnext' blocks",
            "state": State.OPEN,
            "text": "not this one",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 7,
            "deferred": None,
        }
        assert file.tasks[1].as_dict() == {
            "heading": "# Only 'whatnext' blocks",
            "state": State.OPEN,
            "text": "not this one either",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": None,
            "line": 15,
            "deferred": None,
        }

    def test_multiple_annotations_combine(self):
        file = MarkdownFile(
            source_string=dedent("""\
                # Shattered thoughts

                ```whatnext
                notes notes notes
                ```

                ```whatnext
                more notes
                ```

                - [ ] something about notes

                ```whatnext
                what are this?
                ```

                - [ ] are this?
            """),
            today=date(2025, 1, 1),
        )
        assert len(file.tasks) == 2
        assert file.tasks[0].as_dict() == {
            "heading": "# Shattered thoughts",
            "state": State.OPEN,
            "text": "something about notes",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": "notes notes notes more notes what are this?",
            "line": 11,
            "deferred": None,
        }
        assert file.tasks[1].as_dict() == {
            "heading": "# Shattered thoughts",
            "state": State.OPEN,
            "text": "are this?",
            "priority": Priority.NORMAL,
            "due": None,
            "imminent": None,
            "annotation": "notes notes notes more notes what are this?",
            "line": 17,
            "deferred": None,
        }


class TestNotnextParsing:
    def test_file_without_notnext(self):
        file = MarkdownFile(
            source_string="- [ ] normal task",
            today=date(2025, 1, 1),
        )
        assert file.notnext is False

    def test_file_with_notnext_at_start(self):
        file = MarkdownFile(
            source_string=dedent("""\
                @notnext

                # Example tasks

                - [ ] this file will not be included
            """),
            today=date(2025, 1, 1),
        )
        assert file.notnext is True
        assert len(file.tasks) == 1

    def test_file_with_notnext_after_content(self):
        file = MarkdownFile(
            source_string=dedent("""\
                # Example tasks

                - [ ] this file will not be included

                @notnext
            """),
            today=date(2025, 1, 1),
        )
        assert file.notnext is True

    def test_file_with_notnext_and_explanation(self):
        file = MarkdownFile(
            source_string=dedent("""\
                @notnext for many reasons

                # Example tasks

                - [ ] this file will not be included
            """),
            today=date(2025, 1, 1),
        )
        assert file.notnext is True
        assert len(file.tasks) == 1

    def test_file_with_notnext_between_sections(self):
        file = MarkdownFile(
            source_string=dedent("""\
                # Section one

                - [ ] task one

                @notnext ignores the whole file, not just after the marker

                # Section two

                - [ ] task two
            """),
            today=date(2025, 1, 1),
        )
        assert file.notnext is True
        assert len(file.tasks) == 2

    def test_notnext_must_be_on_own_line(self):
        file = MarkdownFile(
            source_string=dedent("""\
                # Tasks

                - [ ] something @notnext something else
            """),
            today=date(2025, 1, 1),
        )
        assert file.notnext is False
