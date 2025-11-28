from enum import Enum
import os
import re
import textwrap


class State(Enum):
    def __new__(cls, value, markers):
        obj = object.__new__(cls)
        obj._value_ = value
        obj.markers = markers
        return obj

    INCOMPLETE = ("incomplete", [" "])
    COMPLETE = ("complete", ["X", "x"])

    @classmethod
    def all_markers(cls):
        markers = []
        for state in cls:
            markers.extend(state.markers)
        return markers

    @classmethod
    def from_marker(cls, marker):
        for state in cls:
            if marker in state.markers:
                return state
        raise ValueError(f"Unknown marker: {marker}")


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

    VALID_STATES = re.escape("".join(State.all_markers()))
    TASK_PATTERN = re.compile(rf"""
        ^
            (\s*)
            -[ ]
            \[ ([{VALID_STATES}]) \]
    """, re.VERBOSE)

    def __init__(self, path, base_dir="."):
        self.path = path
        self.base_dir = base_dir
        self.tasks = self.extract_tasks()

    def extract_tasks(self):
        tasks = []
        for heading, lines in self.sections():
            tasks.extend(self.tasks_in_section(heading, lines))
        return tasks

    def sections(self):
        heading = None
        lines = []
        results = []

        # stack stores (level, text) -- explicit level needed for
        # skipped headings (# -> ### -> ##, where position != depth)
        stack = []

        with open(self.path) as handle:
            for line in handle:
                line = line.rstrip("\n")
                if match := self.HEADING_PATTERN.match(line):
                    if lines:
                        results.append((heading, lines))
                        lines = []
                    level = len(match.group(1))
                    while stack and stack[-1][0] >= level:
                        stack.pop()
                    stack.append((level, match.group(2)))
                    heading = "# " + " / ".join(text for _, text in stack)
                else:
                    lines.append(line)

            if lines:
                results.append((heading, lines))

        return results

    def tasks_in_section(self, heading, lines):
        tasks = []
        index = -1
        while (index := index + 1) < len(lines):
            if match := self.TASK_PATTERN.match(lines[index]):
                text = lines[index].lstrip()
                indent = len(match.group(1)) + 6
                while (
                    index + 1 < len(lines)
                    and self.is_continuation(lines[index + 1], indent)
                ):
                    index += 1
                    text += "\n" + lines[index].strip()
                tasks.append(Task(heading, text, State.from_marker(match.group(2))))

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
    def complete(self):
        return [task for task in self.tasks if task.state == State.COMPLETE]

    @property
    def incomplete(self):
        return [task for task in self.tasks if task.state == State.INCOMPLETE]
