import argparse
import difflib
from datetime import date
from importlib.metadata import version
import os
import sys
import textwrap

from whatnext.models import MarkdownFile
from whatnext.whatnext import load_config


def rewind_insertion_point(lines, position, min_position):
    first_non_blank = None
    while position > min_position:
        line = lines[position - 1]
        if MarkdownFile.TASK_PATTERN.match(line):
            return position, True
        if line.strip() != "":
            first_non_blank = position
        position -= 1
    if first_non_blank is not None:
        return first_non_blank, False
    return min_position, False


def update_file(file, line, content, message):
    try:
        with open(file, "r") as handle:
            old_lines = handle.readlines()
    except FileNotFoundError:
        old_lines = []
    new_lines = old_lines.copy()
    for i, content_line in enumerate(content.splitlines(True)):
        new_lines.insert(line + i, content_line)
    with open(file, "w") as handle:
        handle.writelines(new_lines)
    diff_lines = [
        diff_line
            for diff_line in difflib.unified_diff(old_lines, new_lines, n=2)
                if not diff_line.startswith(("---", "+++", "@@"))
    ]
    print(f"{message}:")
    print("".join(diff_lines), end="")


def display_path(path):
    home = os.path.realpath(os.environ["HOME"])
    real_path = os.path.realpath(path)
    if real_path.startswith(home):
        return "~" + real_path[len(home):]
    return path


def detect_task_width(lines):
    source = "".join(lines)
    md = MarkdownFile(source_string=source, today=date.today())
    return md.max_task_line_width


def get_wrap_width(lines, tasks_file, config_path):
    env_width = os.environ.get("WHATNEXT_WRAP_WIDTH")
    if env_width:
        default_width = int(env_width)
    else:
        config = load_config(config_path, os.path.dirname(tasks_file) or ".")
        default_width = config.get("wrap_width", 80)
    file_width = detect_task_width(lines)
    return max(file_width, default_width)


def wrap_task(text, width):
    task_line = f"- [ ] {text}"
    if len(task_line) <= width:
        return task_line + "\n"
    wrapped = textwrap.wrap(
        task_line,
        width=width,
        subsequent_indent="      ",
    )
    return "\n".join(wrapped) + "\n"


def add_tasks_to_file(tasks_file, tasks, max_width, section=None, append_only=False):
    shown_path = display_path(tasks_file)

    try:
        with open(tasks_file, "r") as handle:
            lines = handle.readlines()
    except FileNotFoundError:
        lines = []

    content = "".join(
        wrap_task(text, max_width)
            for text in tasks
                if text
    )

    if not content:
        return

    if not lines:
        update_file(tasks_file, 0, content, f"Created {shown_path}")
        return

    if append_only:
        position = len(lines)
        while position > 0 and lines[position - 1].strip() == "":
            position -= 1
        if position > 0 and lines[position - 1].startswith("- ["):
            update_file(tasks_file, position, content, f"Updated {shown_path}")
        else:
            update_file(tasks_file, position, f"\n{content}", f"Updated {shown_path}")
        return

    headers = [
        (index, line) for index, line
            in enumerate(lines)
                if line.startswith("#")
    ]

    if not headers:
        update_file(tasks_file, len(lines), content, f"Updated {shown_path}")
        return

    if section:
        for index, (line_num, line) in enumerate(headers):
            if line.lstrip("#").strip().lower() != section.lower():
                continue

            if index + 1 < len(headers):
                section_end = headers[index + 1][0]
            else:
                section_end = len(lines)
            section_name = line.lstrip("#").strip()
            message = f"Updated {shown_path} ({section_name})"

            position, found_task = rewind_insertion_point(
                lines,
                section_end,
                line_num + 1,
            )
            if found_task:
                update_file(tasks_file, position, content, message)
            else:
                update_file(tasks_file, position, f"\n{content}", message)
            return

    position, found_task = rewind_insertion_point(lines, headers[0][0], 0)
    if found_task:
        update_file(tasks_file, position, content, f"Updated {shown_path}")
    else:
        update_file(tasks_file, headers[0][0], f"{content}\n", f"Updated {shown_path}")


def resolve_tasks_file(args):
    project_dir = os.environ.get("WHATNEXT_PROJECT_DIR")

    if args and args[0].endswith(".md"):
        # explicit reference to file
        if os.path.isabs(args[0]):
            tasks_file = args[0]
            if os.path.isfile(tasks_file):
                return tasks_file, args[1:]
        else:
            # check relative to current dir ...
            if os.path.isfile(args[0]):
                tasks_file = os.path.abspath(args[0])
                return tasks_file, args[1:]
            # ... relative to $WHATNEXT_PROJECT_DIR ...
            if project_dir:
                tasks_file = os.path.join(project_dir, args[0])
                if os.path.isfile(tasks_file):
                    return tasks_file, args[1:]
            # ... relative to $HOME
            tasks_file = os.path.join(os.environ["HOME"], args[0])
            if os.path.isfile(tasks_file):
                return tasks_file, args[1:]

    # try shorthand references to file
    if project_dir and len(args) > 1:
        project_path = os.path.join(project_dir, args[0])
        if os.path.isdir(project_path):
            if len(args) > 2:
                subfile = os.path.join(project_path, "tasks", f"{args[1]}.md")
                if os.path.isfile(subfile):
                    return subfile, args[2:]
            tasks_file = os.path.join(project_path, "tasks.md")
            return tasks_file, args[1:]

    # prefer tasks.md in cwd, then fall back to ~/tasks.md
    cwd_tasks = os.path.join(os.getcwd(), "tasks.md")
    if os.path.isfile(cwd_tasks):
        return cwd_tasks, args

    tasks_file = os.path.join(os.environ["HOME"], "tasks.md")
    return tasks_file, args


def main():
    parser = argparse.ArgumentParser(
        prog="next",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="Add a task to a Markdown (.md file) task list.",
        epilog=textwrap.dedent("""\
            The file to add to is chosen indirectly:

            - if the first word of text is an absolute filename, use that
            - if the first word matches a file in the current directory, use that
            - if the first word matches a file in $WHATNEXT_PROJECT_DIR, use that
            - if the first word matches a file in $HOME, use that
            - if the first word matches a directory in $WHATNEXT_PROJECT_DIR:
                - if the second word matches a file
                  $WHATNEXT_PROJECT_DIR/[project]/tasks/[word].md then use that
                - otherwise, use $WHATNEXT_PROJECT_DIR/[project]/tasks.md
            - if tasks.md exists in the current directory, use that
            - otherwise, use $HOME/tasks.md

            With the remaining text:

            - if the file uses headings to section the file:
                - if the first word case-insensitively matches a heading in the
                  file, the task is added to that section
                - otherwise, the task is added above the first heading
            - otherwise, the task is added to the end of the file
            """),
    )
    parser.add_argument(
        "--version",
        action="version",
        version=f"next {version('whatnext')}",
    )
    parser.add_argument(
        "-a",
        dest="append_only",
        action="store_true",
        help="append to end of file, ignoring headings (or set WHATNEXT_APPEND_ONLY)",
    )
    parser.add_argument(
        "--config",
        default=os.environ.get("WHATNEXT_CONFIG"),
        help="path to config file (default: WHATNEXT_CONFIG, or '.whatnext')",
    )
    parser.add_argument(
        "text",
        nargs=argparse.REMAINDER,
        help="task text to add (if omitted, read from stdin)",
    )
    parsed = parser.parse_args()

    args = parsed.text
    append_only = parsed.append_only or os.environ.get("WHATNEXT_APPEND_ONLY")
    tasks_file, args = resolve_tasks_file(args)

    try:
        with open(tasks_file, "r") as handle:
            lines = handle.readlines()
    except FileNotFoundError:
        lines = []

    max_width = get_wrap_width(lines, tasks_file, parsed.config)

    section = None
    if args and not append_only:
        headers = [
            line for line in lines if line.startswith("#")
        ]
        for header in headers:
            if header.lstrip("#").strip().lower() == args[0].lower():
                section = args[0]
                args = args[1:]
                break

    if args:
        tasks = [" ".join(args)]
    else:
        tasks = [
            line.strip() for line in sys.stdin
                if line.strip()
        ]

    add_tasks_to_file(tasks_file, tasks, max_width, section, append_only)
