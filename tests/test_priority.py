from textwrap import dedent

from whatnext.models import MarkdownFile, Priority


class TestDetectPriority:
    def test_plain_text_is_normal_priority(self):
        assert MarkdownFile.detect_priority("Do something") == Priority.NORMAL

    def test_bold_text_is_high_priority(self):
        assert MarkdownFile.detect_priority("**Do this urgently**") == Priority.HIGH

    def test_italic_text_is_medium_priority(self):
        assert MarkdownFile.detect_priority("_Do this soon_") == Priority.MEDIUM

    def test_partial_bold_is_high_priority(self):
        assert MarkdownFile.detect_priority("Do **this** soon") == Priority.NORMAL

    def test_partial_italic_is_medium_priority(self):
        assert MarkdownFile.detect_priority("Do _this_ soon") == Priority.NORMAL

    def test_bold_takes_precedence_over_italic(self):
        text = "**urgent** and _also important_"
        assert MarkdownFile.detect_priority(text) == Priority.NORMAL

    def test_single_asterisk_is_not_bold(self):
        assert MarkdownFile.detect_priority("*not bold*") == Priority.NORMAL

    def test_double_underscore_is_not_italic(self):
        assert MarkdownFile.detect_priority("__not italic__") == Priority.NORMAL

    def test_underscore_in_function_name_is_not_italic(self):
        text = "fix entries_to_markdown"
        assert MarkdownFile.detect_priority(text) == Priority.NORMAL

    def test_asterisk_as_math_is_not_bold(self):
        text = "calculate return * investment"
        assert MarkdownFile.detect_priority(text) == Priority.NORMAL


class TestTaskPriority:
    def test_priority_normal(self):
        file = MarkdownFile.from_string(dedent("""\
            # First section

            - [ ] task under first section
        """))
        assert file.tasks[0].priority == Priority.NORMAL

    def test_priority_medium_task(self):
        file = MarkdownFile.from_string(dedent("""\
            # First section

            - [ ] _task under first section_
        """))
        assert file.tasks[0].priority == Priority.MEDIUM

    def test_priority_medium_header(self):
        file = MarkdownFile.from_string(dedent("""\
            # _First section_

            - [ ] task under first section
        """))
        assert file.tasks[0].priority == Priority.MEDIUM

    def test_priority_high_task(self):
        file = MarkdownFile.from_string(dedent("""\
            # First section

            - [ ] **task under first section**
        """))
        assert file.tasks[0].priority == Priority.HIGH

    def test_priority_high_header(self):
        file = MarkdownFile.from_string(dedent("""\
            # **First section**

            - [ ] task under first section
        """))
        assert file.tasks[0].priority == Priority.HIGH

    def test_priority_high_task_overrides(self):
        file = MarkdownFile.from_string(dedent("""\
            # _First section_

            - [ ] **task under first section**
        """))
        assert file.tasks[0].priority == Priority.HIGH

    def test_priority_high_header_overrides(self):
        file = MarkdownFile.from_string(dedent("""\
            # **First section**

            - [ ] _task under first section_
        """))
        assert file.tasks[0].priority == Priority.HIGH

    def test_new_heading_resets(self):
        file = MarkdownFile.from_string(dedent("""\
            # **First section**

            - [ ] _task under first section_

            # Second section

            - [ ] task under second section
        """))
        assert file.tasks[0].priority == Priority.HIGH
        assert file.tasks[1].priority == Priority.NORMAL

        file = MarkdownFile.from_string(dedent("""\
            # _First section_

            - [ ] _task under first section_

            # Second section

            - [ ] task under second section
        """))
        assert file.tasks[0].priority == Priority.MEDIUM
        assert file.tasks[1].priority == Priority.NORMAL


class TestPriorityPrecedence:
    def test_medium_priority_carries(self):
        file = MarkdownFile.from_string(dedent("""\
            # _First section_

            - [ ] task under first level

            ## Second subsection

            - [ ] task under second level
        """))
        assert len(file.tasks) == 2
        assert file.tasks[0].priority == Priority.MEDIUM
        assert file.tasks[1].priority == Priority.MEDIUM

    def test_high_priority_carries(self):
        file = MarkdownFile.from_string(dedent("""\
            # **First section**

            - [ ] task under first level

            ## Second subsection

            - [ ] task under second level
        """))
        assert len(file.tasks) == 2
        assert file.tasks[0].priority == Priority.HIGH
        assert file.tasks[1].priority == Priority.HIGH

    def test_high_priority_header_takes_precedence(self):
        file = MarkdownFile.from_string(dedent("""\
            # _First section_

            - [ ] task under first level

            ## **Second subsection**

            - [ ] task under second level
        """))
        assert len(file.tasks) == 2
        assert file.tasks[0].priority == Priority.MEDIUM
        assert file.tasks[1].priority == Priority.HIGH

    def test_high_priority_task_takes_precedence(self):
        file = MarkdownFile.from_string(dedent("""\
            # _First section_

            - [ ] task under first level

            ## Second subsection

            - [ ] **task under second level**
        """))
        assert len(file.tasks) == 2
        assert file.tasks[0].priority == Priority.MEDIUM
        assert file.tasks[1].priority == Priority.HIGH

    def test_medium_priority_header_inheritance(self):
        file = MarkdownFile.from_string(dedent("""\
            # **First section**

            - [ ] task under first level

            ## _Second subsection_

            - [ ] task under second level
        """))
        assert len(file.tasks) == 2
        assert file.tasks[0].priority == Priority.HIGH
        assert file.tasks[1].priority == Priority.HIGH

    def test_medium_priority_task_inheritance(self):
        file = MarkdownFile.from_string(dedent("""\
            # **First section**

            - [ ] task under first level

            ## Second subsection

            - [ ] _task under second level_
        """))
        assert len(file.tasks) == 2
        assert file.tasks[0].priority == Priority.HIGH
        assert file.tasks[1].priority == Priority.HIGH
