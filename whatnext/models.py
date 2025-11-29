from enum import Enum
import os
import re
import textwrap


class State(Enum):
    def __new__(cls, config):
        obj = object.__new__(cls)
        obj._value_ = config["value"]
        obj.markers = config["markers"]
        obj.sort_order = config["sort_order"]
        obj.abbrev = config["abbrev"]
        obj.label = config["label"]
        return obj

    IN_PROGRESS = {
        "value": "in_progress",
        "markers": ["/"],
        "sort_order": 0,
        "abbrev": "P",
        "label": "Partial",
    }
    OPEN = {
        "value": "open",
        "markers": [" "],
        "sort_order": 1,
        "abbrev": "O",
        "label": "Open",
    }
    BLOCKED = {
        "value": "blocked",
        "markers": ["<"],
        "sort_order": 2,
        "abbrev": "B",
        "label": "Blocked",
    }
    COMPLETE = {
        "value": "complete",
        "markers": ["X", "x"],
        "sort_order": 3,
        "abbrev": "D",
        "label": "Done",
    }
    CANCELLED = {
        "value": "cancelled",
        "markers": ["#"],
        "sort_order": 4,
        "abbrev": "C",
        "label": "Cancelled",
    }

    @classmethod
    def from_marker(cls, marker):
        for state in cls:
            if marker in state.markers:
                return state
        return None


class Task:
    def __init__(self, heading, text, state):
        self.heading = heading
        self.text = text
        self.state = state

    def wrapped_text(self, width=80, indent="    "):
        text = " ".join(self.text.split())
        if width is None or len(indent + text) <= width:
            return [indent + text]
        return textwrap.wrap(
            text,
            width=width,
            initial_indent=indent,
            subsequent_indent=indent + "      ",
        )

    def wrapped_heading(self, width=80, indent="    "):
        if not self.heading:
            return []
        if width is None or len(indent + self.heading) <= width:
            return [indent + self.heading]
        return textwrap.wrap(
            self.heading,
            width=width,
            initial_indent=indent,
            subsequent_indent=indent + "  ",
        )


class MarkdownFile:
    HEADING_PATTERN = re.compile(r"""
        ^
            (\#+) \s+ (.*)
        $
    """, re.VERBOSE)
    TASK_PATTERN = re.compile(r""" ^ (\s*) -[ ] \[ (.) \] """, re.VERBOSE)

    def __init__(self, path, base_dir=".", lines=None):
        self.path = path
        self.base_dir = base_dir
        self.provided_lines = lines
        self.warnings = []
        self.tasks = self.extract_tasks()

    @classmethod
    def from_string(cls, content, path="test.md"):
        lines = content.splitlines()
        return cls(path, ".", lines)

    def extract_tasks(self):
        tasks = []
        for heading, lines, start_line in self.sections():
            tasks.extend(self.tasks_in_section(heading, lines, start_line))
        return tasks

    def read_lines(self):
        if self.provided_lines is not None:
            return self.provided_lines
        with open(self.path) as handle:
            return [line.rstrip("\n") for line in handle]

    def sections(self):
        heading = None
        lines = []
        start_line = 1
        results = []

        # stack stores (level, text) -- explicit level needed for
        # skipped headings (# -> ### -> ##, where position != depth)
        stack = []

        for line_index, line in enumerate(self.read_lines(), 1):
            if match := self.HEADING_PATTERN.match(line):
                if lines:
                    results.append((heading, lines, start_line))
                    lines = []
                level = len(match.group(1))
                while stack and stack[-1][0] >= level:
                    stack.pop()
                stack.append((level, match.group(2)))
                heading = "# " + " / ".join(text for _, text in stack)
                start_line = line_index + 1
            else:
                lines.append(line)

        if lines:
            results.append((heading, lines, start_line))

        return results

    def tasks_in_section(self, heading, lines, start_line):
        tasks = []
        index = -1
        while (index := index + 1) < len(lines):
            if match := self.TASK_PATTERN.match(lines[index]):
                marker = match.group(2)
                state = State.from_marker(marker)
                if state is None:
                    text = lines[index].lstrip()[6:]
                    line_index = start_line + index
                    self.warnings.append(
                        f"WARNING: ignoring invalid state '{marker}' "
                        f"in '{text}', {self.display_path} line {line_index}"
                    )
                    continue
                text = lines[index].lstrip()
                indent = len(match.group(1)) + 6
                while (
                    index + 1 < len(lines)
                    and self.is_continuation(lines[index + 1], indent)
                ):
                    index += 1
                    text += "\n" + lines[index].strip()
                tasks.append(Task(heading, text, state))

        return tasks

    def is_continuation(self, line, indent):
        if not line.strip():
            return False
        leading = len(line) - len(line.lstrip())
        return leading == indent

    @property
    def display_path(self):
        return os.path.relpath(self.path, self.base_dir)

    @property
    def incomplete(self):
        outstanding_states = {State.IN_PROGRESS, State.OPEN, State.BLOCKED}
        tasks = [task for task in self.tasks if task.state in outstanding_states]
        return self.sort_by_state(tasks)

    @property
    def sorted_tasks(self):
        return self.sort_by_state(self.tasks)

    def sort_by_state(self, tasks):
        by_heading = {}
        for task in tasks:
            by_heading.setdefault(task.heading, []).append(task)
        result = []
        for heading in by_heading:
            result.extend(
                sorted(by_heading[heading], key=lambda t: t.state.sort_order)
            )
        return result

    def as_string(self, width=80, include_all=False, search_terms=None, states=None):
        if states:
            tasks = self.sort_by_state(
                [task for task in self.tasks if task.state in states]
            )
        elif include_all:
            tasks = self.sorted_tasks
        else:
            tasks = self.incomplete
        lines = []
        current_heading = None
        for task in tasks:
            if search_terms:
                heading_matches = task.heading and any(
                    term in task.heading.lower() for term in search_terms
                )
                task_matches = any(
                    term in task.text.lower() for term in search_terms
                )
                if not heading_matches and not task_matches:
                    continue
            if task.heading and task.heading != current_heading:
                lines.extend(task.wrapped_heading(width))
                current_heading = task.heading
            lines.extend(task.wrapped_text(width))
        return "\n".join(lines)
