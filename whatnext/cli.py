import argparse
import fnmatch
import importlib.metadata
import os
import shutil
import sys
import toml

from whatnext.models import MarkdownFile, Priority, State
from whatnext.summary import format_summary


def get_terminal_width():
    columns_env = os.environ.get("COLUMNS")
    if columns_env:
        width = int(columns_env)
    else:
        width = shutil.get_terminal_size().columns
    if width < 40:
        width = 80
    return width


def load_config(config_path=None, directory="."):
    if config_path is None:
        config_path = os.path.join(directory, ".whatnext")
    if os.path.exists(config_path):
        with open(config_path) as handle:
            return toml.load(handle)
    return {}


def is_ignored(filepath, ignore_patterns):
    for pattern in ignore_patterns:
        if fnmatch.fnmatch(filepath, pattern):
            return True
    return False


def find_markdown_files(paths, ignore_patterns=None, include_all=False):
    if ignore_patterns is None:
        ignore_patterns = []
    if isinstance(paths, str):
        paths = [paths]

    multiple = len(paths) > 1
    task_files = {}

    for path in paths:
        base_dir = "." if multiple else path

        if os.path.isfile(path):
            if path.endswith(".md"):
                abs_path = os.path.abspath(path)
                if abs_path not in task_files:
                    file = MarkdownFile(path, ".")
                    tasks = file.tasks if include_all else file.incomplete
                    if tasks:
                        task_files[abs_path] = file
            continue

        for root, dirs, files in os.walk(path):
            for filename in files:
                if filename.endswith(".md"):
                    filepath = os.path.join(root, filename)
                    abs_path = os.path.abspath(filepath)
                    if abs_path in task_files:
                        continue
                    relative_path = os.path.relpath(filepath, path)
                    if is_ignored(relative_path, ignore_patterns):
                        continue
                    file = MarkdownFile(filepath, base_dir)
                    tasks = file.tasks if include_all else file.incomplete
                    if tasks:
                        task_files[abs_path] = file

    # files are examined depth-last as a lightweight prioritisation
    return sorted(
        task_files.values(),
        key=lambda file: (
            file.display_path.count(os.sep),
            file.display_path,
        )
    )


def format_tasks(
    task_files,
    width,
    include_all,
    search_terms=None,
    states=None,
    priorities=None,
):
    if not states:
        if include_all:
            states = set(State)
        else:
            states = {State.IN_PROGRESS, State.OPEN, State.BLOCKED}

    groups = [[] for _ in Priority]
    for file in task_files:
        for priority_index, tasks in enumerate(
            file.grouped_tasks(
                states=states,
                search_terms=search_terms,
                priorities=priorities,
            )
        ):
            groups[priority_index].extend(tasks)

    output = ""
    for tasks in groups:
        if not tasks:
            continue
        current_file = None
        current_heading = None
        for task in tasks:
            if task.file != current_file:
                output += f"{task.file.display_path}:\n"
                current_file = task.file
                current_heading = None
            if task.heading and task.heading != current_heading:
                for line in task.wrapped_heading(width):
                    output += f"{line}\n"
                current_heading = task.heading
            for line in task.wrapped_task(width):
                output += f"{line}\n"
        output += "\n"

    return output


class CapitalisedHelpFormatter(argparse.RawDescriptionHelpFormatter):
    def add_usage(self, usage, actions, groups, prefix=None):
        if prefix is None:
            prefix = "Usage: "
        super().add_usage(usage, actions, groups, prefix)

    def start_section(self, heading):
        super().start_section(heading.capitalize() if heading else heading)


class ShortHelpAction(argparse.Action):
    def __init__(self, option_strings, dest, **kwargs):
        super().__init__(option_strings, dest, nargs=0, **kwargs)

    def __call__(self, parser, namespace, values, option_string=None):
        print(parser.format_usage().rstrip())
        parser.exit()


def main():
    parser = argparse.ArgumentParser(
        description="List tasks found in Markdown files",
        epilog="""\
Task States:
  - [ ]     Open (shown by default)
  - [/]     In progress (shown by default)
  - [<]     Blocked (shown by default)
  - [X]     Done (hidden by default)
  - [#]     Cancelled (hidden by default)
""",
        add_help=False,
        formatter_class=CapitalisedHelpFormatter,
    )
    parser.add_argument(
        "-h",
        action=ShortHelpAction,
        help="Show the usage reminder and exit",
    )
    parser.add_argument(
        "--help",
        action="help",
        help="Show this help message and exit",
    )
    parser.add_argument(
        "--version",
        action="version",
        version=f"whatnext version v{importlib.metadata.version('whatnext')}",
    )
    parser.add_argument(
        "--dir",
        default=".",
        help="Directory to search (default: current directory)",
    )
    parser.add_argument(
        "-s", "--summary",
        action="store_true",
        help="Show summary of task counts per file",
    )
    parser.add_argument(
        "-a", "--all",
        action="store_true",
        help="Include all tasks and files, not just incomplete",
    )
    parser.add_argument(
        "--config",
        help="Path to config file (default: .whatnext in search directory)",
    )
    parser.add_argument(
        "--ignore",
        action="append",
        default=[],
        metavar="PATTERN",
        help="Ignore files matching pattern (can be specified multiple times)",
    )
    parser.add_argument(
        "-q", "--quiet",
        action="store_true",
        help="Suppress warnings",
    )
    parser.add_argument(
        "-o", "--open",
        action="store_true",
        help="Show only open tasks",
    )
    parser.add_argument(
        "-p", "--partial",
        action="store_true",
        help="Show only in progress tasks",
    )
    parser.add_argument(
        "-b", "--blocked",
        action="store_true",
        help="Show only blocked tasks",
    )
    parser.add_argument(
        "-d", "--done",
        action="store_true",
        help="Show only completed tasks",
    )
    parser.add_argument(
        "-c", "--cancelled",
        action="store_true",
        help="Show only cancelled tasks",
    )
    parser.add_argument(
        "--priority",
        action="append",
        default=[],
        choices=[p.name.lower() for p in Priority],
        metavar="LEVEL",
        help="Show only tasks of this priority (can be specified multiple times)",
    )
    parser.add_argument(
        "match",
        nargs="*",
        help="Only include results from matching file(s), dir(s) or where "
             "\"match\" is in the task text or heading",
    )
    args = parser.parse_args()

    # build the search space
    paths = []
    search_terms = []
    for target in args.match:
        if os.path.isdir(target) or os.path.isfile(target):
            paths.append(target)
        else:
            search_terms.append(target.lower())

    if not paths:
        paths = [args.dir]

    config_path = args.config or os.environ.get("WHATNEXT_CONFIG")
    config = load_config(config_path, paths[0] if os.path.isdir(paths[0]) else ".")
    ignore_patterns = config.get("ignore", []) + args.ignore

    include_all = args.all or args.summary
    task_files = find_markdown_files(paths, ignore_patterns, include_all)

    quiet = args.quiet or os.environ.get("WHATNEXT_QUIET") == "1"
    if not quiet:
        for file in task_files:
            for warning in file.warnings:
                print(warning, file=sys.stderr)

    if not task_files:
        return

    width = get_terminal_width()

    states = set()
    if args.open:
        states.add(State.OPEN)
    if args.partial:
        states.add(State.IN_PROGRESS)
    if args.blocked:
        states.add(State.BLOCKED)
    if args.done:
        states.add(State.COMPLETE)
    if args.cancelled:
        states.add(State.CANCELLED)

    if args.priority:
        priorities = {
            Priority[p.upper()] for p in args.priority
        }
    else:
        priorities = None

    if args.summary:
        if not states:
            states = set(State)
        print(format_summary(task_files, width, states))
    else:
        print(format_tasks(
            task_files,
            width,
            args.all,
            search_terms or None,
            states or None,
            priorities,
        ))
