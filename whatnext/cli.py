import argparse
import fnmatch
import importlib.metadata
import os
import shutil
import toml

from whatnext.models import MarkdownFile


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


def find_markdown_files(directory=".", ignore_patterns=None, include_all=False):
    if ignore_patterns is None:
        ignore_patterns = []
    markdown_files = []
    for root, dirs, files in os.walk(directory):
        for filename in files:
            if filename.endswith(".md"):
                filepath = os.path.join(root, filename)
                relative_path = os.path.relpath(filepath, directory)
                if is_ignored(relative_path, ignore_patterns):
                    continue
                md_file = MarkdownFile(filepath, directory)
                tasks = md_file.tasks if include_all else md_file.incomplete
                if tasks:
                    markdown_files.append(md_file)

    # files are examined depth-last as a lightweight prioritisation
    return sorted(
        markdown_files,
        key=lambda file: (
            file.display_path.count(os.sep),
            file.display_path,
        )
    )


def progress_bar(complete, total, width):
    filled = round(width * complete / total) if total else 0
    return "█" * filled + "░" * (width - filled)


def format_summary(markdown_files, width):
    widest = max(len(mf.tasks) for mf in markdown_files)
    count_width = len(f"{widest}/{widest}")
    gap = "  "
    bar_width = (
        width
        - count_width
        - max(len(mf.display_path) for mf in markdown_files)
        - len(gap) * 3
    )

    lines = []
    for md_file in markdown_files:
        total = len(md_file.tasks)
        complete = len(md_file.complete)
        bar = progress_bar(
            complete,
            total,
            round(bar_width * total / widest)
        )

        lines.append(
            f"{bar.ljust(bar_width)}{gap}"
            f"{f'{complete}/{total}'.rjust(count_width)}{gap}"
            f"{md_file.display_path}"
        )

    return "\n".join(lines)


def format_tasks(markdown_files, width, include_all):
    lines = []
    for md_file in markdown_files:
        tasks = md_file.tasks if include_all else md_file.incomplete
        lines.append(f"{md_file.display_path}:")
        current_heading = None
        for task in tasks:
            if task.heading and task.heading != current_heading:
                lines.extend(task.wrapped_heading(width))
                current_heading = task.heading
            lines.extend(task.wrapped_text(width))
    return "\n".join(lines)


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
  - [ ]     Not started (shown by default)
  - [X]     Done (hidden by default, use --all)
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
    args = parser.parse_args()

    config_path = args.config or os.environ.get("WHATNEXT_CONFIG")
    config = load_config(config_path, args.dir)
    ignore_patterns = config.get("ignore", []) + args.ignore
    markdown_files = find_markdown_files(args.dir, ignore_patterns, args.all)

    if not markdown_files:
        return

    width = get_terminal_width()

    if args.summary:
        print(format_summary(markdown_files, width))
    else:
        print(format_tasks(markdown_files, width, args.all))
