from collections import Counter

from whatnext.models import Priority, State

# done states leftmost (darker), active states rightmost (lighter)
STATE_DISPLAY_ORDER = [
    State.CANCELLED,
    State.COMPLETE,
    State.BLOCKED,
    State.IN_PROGRESS,
    State.OPEN,
]
PRIORITY_DISPLAY_ORDER = [
    Priority.OVERDUE,
    Priority.IMMINENT,
    Priority.HIGH,
    Priority.MEDIUM,
    Priority.NORMAL,
]
SHADING = ["▚", "█", "▓", "▒", "░"]


def build_visualisation_map(selected, display_order):
    selected_in_order = [s for s in display_order if s in selected]
    char_map = {}
    for i, item in enumerate(selected_in_order):
        char_map[item] = SHADING[i]
    for item in display_order:
        if item not in char_map:
            char_map[item] = SHADING[-1]
    return char_map, selected_in_order


def make_header(selected_in_order, has_remainder):
    parts = [s.abbrev for s in selected_in_order]
    if has_remainder:
        parts.append("~")
    return "/".join(parts)


def make_legend(char_map, selected_in_order, display_order, has_remainder):
    parts = [f"{char_map[s]} {s.label}" for s in selected_in_order]
    if has_remainder:
        unselected = [s.label for s in display_order if s not in selected_in_order]
        parts.append(f"{SHADING[-1]} ({'/'.join(unselected)})")
    return "  ".join(parts)


def build_bar(counts, total, width, char_map, selected_in_order, display_order):
    if total == 0:
        return ""

    remainder = [s for s in display_order if s not in selected_in_order]
    parts = []
    cumulative = 0
    bar_pos = 0
    for item in selected_in_order + remainder:
        count = counts.get(item, 0)
        cumulative += count
        end_pos = round(width * cumulative / total)
        parts.append(char_map[item] * (end_pos - bar_pos))
        bar_pos = end_pos
    return "".join(parts)


OUTSTANDING_STATES = {State.IN_PROGRESS, State.OPEN, State.BLOCKED}


def format_summary(markdown_files, width, selected_states, selected_priorities=None):
    if selected_priorities:
        display_order = PRIORITY_DISPLAY_ORDER
        selected = selected_priorities
        count_attr = "priority"
    else:
        display_order = STATE_DISPLAY_ORDER
        selected = selected_states
        count_attr = "state"

    char_map, selected_in_order = build_visualisation_map(selected, display_order)
    has_remainder = len(selected) < len(display_order)

    file_tasks = []
    for mf in markdown_files:
        if selected_priorities:
            tasks = [t for t in mf.tasks if t.state in OUTSTANDING_STATES]
        else:
            tasks = mf.tasks
        if tasks:
            file_tasks.append((mf, tasks))

    if not file_tasks:
        return ""

    widest = max(len(tasks) for _, tasks in file_tasks)
    count_width = len("/".join(str(widest) for _ in selected_in_order))
    if has_remainder:
        count_width += len(f"/{widest}")
    gap = "  "
    bar_width = max(
        10,
        width
        - count_width
        - max(len(mf.display_path) for mf, _ in file_tasks)
        - len(gap) * 3
    )

    header = make_header(selected_in_order, has_remainder)
    header = header.rjust(bar_width + len(gap) + count_width)

    lines = [header]
    for file, tasks in file_tasks:
        total = len(tasks)
        counts = Counter(getattr(task, count_attr) for task in tasks)

        file_bar_width = round(bar_width * total / widest)
        bar = build_bar(
            counts, total, file_bar_width, char_map, selected_in_order, display_order
        )

        count_parts = [str(counts.get(s, 0)) for s in selected_in_order]
        if has_remainder:
            remainder_count = sum(
                counts.get(s, 0) for s in display_order if s not in selected
            )
            count_parts.append(str(remainder_count))
        count_str = "/".join(count_parts)

        lines.append(
            f"{bar.ljust(bar_width)}{gap}"
            f"{count_str.rjust(count_width)}{gap}"
            f"{file.display_path}"
        )

    lines.append("")
    lines.append(make_legend(char_map, selected_in_order, display_order, has_remainder))

    return "\n".join(lines)
