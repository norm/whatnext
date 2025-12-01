from enum import Enum
import os
import re
import textwrap


class Priority(Enum):
    def __new__(cls, config):
        obj = object.__new__(cls)
        obj._value_ = config["value"]
        obj.abbrev = config["abbrev"]
        obj.label = config["label"]
        return obj

    HIGH = {"value": 0, "abbrev": "H", "label": "High"}
    MEDIUM = {"value": 1, "abbrev": "M", "label": "Medium"}
    NORMAL = {"value": 2, "abbrev": "N", "label": "Normal"}


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
    def __init__(self, file, heading, text, state, priority=Priority.NORMAL):
        self.file = file
        self.heading = heading
        self.text = text
        self.state = state
        self.priority = priority

    def wrapped_task(self, width=80, indent="    "):
        text = f"- [{self.state.markers[0]}] " + " ".join(self.text.split())
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

    @staticmethod
    def detect_priority(text):
        if text.startswith("**") and text.endswith("**") and len(text) > 4:
            return Priority.HIGH
        if (
            text.startswith("_")
            and not text.startswith("__")
            and text.endswith("_")
            and not text.endswith("__")
            and len(text) > 2
        ):
            return Priority.MEDIUM
        return Priority.NORMAL

    @staticmethod
    def strip_emphasis(text):
        if text.startswith("**") and text.endswith("**") and len(text) > 4:
            return text[2:-2]
        if text.startswith("_") and text.endswith("_") and len(text) > 2:
            return text[1:-1]
        return text

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
        for heading, lines, start_line, priority in self.sections():
            tasks.extend(self.tasks_in_section(heading, lines, start_line, priority))
        return tasks

    def read_lines(self):
        if self.provided_lines is not None:
            return self.provided_lines
        with open(self.path) as handle:
            return [line.rstrip("\n") for line in handle]

    def sections(self):
        heading = None
        priority = Priority.NORMAL
        lines = []
        start_line = 1
        results = []

        # stack stores (level, text, priority) -- explicit level needed for
        # skipped headings (# -> ### -> ##, where position != depth)
        stack = []

        for line_index, line in enumerate(self.read_lines(), 1):
            if match := self.HEADING_PATTERN.match(line):
                if lines:
                    results.append((heading, lines, start_line, priority))
                    lines = []
                level = len(match.group(1))
                while stack and stack[-1][0] >= level:
                    stack.pop()
                heading_text = match.group(2)
                heading_priority = self.detect_priority(heading_text)
                stack.append((level, heading_text, heading_priority))
                heading = "# " + " / ".join(text for _, text, _ in stack)
                priority = min((p for _, _, p in stack), key=lambda p: p.value)
                start_line = line_index + 1
            else:
                lines.append(line)

        if lines:
            results.append((heading, lines, start_line, priority))

        return results

    def tasks_in_section(self, heading, lines, start_line, heading_priority):
        prefix_width = len("- [.] ")
        tasks = []
        index = -1
        while (index := index + 1) < len(lines):
            if match := self.TASK_PATTERN.match(lines[index]):
                marker = match.group(2)
                state = State.from_marker(marker)
                if state is None:
                    text = lines[index].lstrip()[prefix_width:]
                    line_index = start_line + index
                    self.warnings.append(
                        f"WARNING: ignoring invalid state '{marker}' "
                        f"in '{text}', {self.display_path} line {line_index}"
                    )
                    continue
                text = lines[index].lstrip()
                indent = len(match.group(1)) + prefix_width
                while (
                    index + 1 < len(lines)
                    and self.is_continuation(lines[index + 1], indent)
                ):
                    index += 1
                    text += "\n" + lines[index].strip()
                task_content = text[prefix_width:]
                task_priority = self.detect_priority(task_content)
                priority = min(heading_priority, task_priority, key=lambda p: p.value)
                tasks.append(
                    Task(
                        self,
                        heading,
                        self.strip_emphasis(task_content),
                        state,
                        priority,
                    )
                )

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
        outstanding_states = {
            State.IN_PROGRESS,
            State.OPEN,
            State.BLOCKED,
        }
        return self.sort_by_state(
            task for task in self.tasks if task.state in outstanding_states
        )

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

    def grouped_tasks(self, states=None, search_terms=None, priorities=None):
        tasks = self.tasks
        if states:
            tasks = [task for task in tasks if task.state in states]
        if priorities:
            tasks = [task for task in tasks if task.priority in priorities]
        if search_terms:
            filtered = []
            for task in tasks:
                heading_matches = task.heading and any(
                    term in task.heading.lower() for term in search_terms
                )
                task_matches = any(
                    term in task.text.lower() for term in search_terms
                )
                if heading_matches or task_matches:
                    filtered.append(task)
            tasks = filtered
        return (
            self.sort_by_state(t for t in tasks if t.priority == Priority.HIGH),
            self.sort_by_state(t for t in tasks if t.priority == Priority.MEDIUM),
            self.sort_by_state(t for t in tasks if t.priority == Priority.NORMAL),
        )
