from collections import Counter

from whatnext.models import State

# states always shown in this order, left to right
STATE_ORDER = [
    State.CANCELLED,
    State.COMPLETE,
    State.BLOCKED,
    State.IN_PROGRESS,
    State.OPEN,
]
SHADING = ["▚", "█", "▓", "▒", "░"]


def build_visualisation_map(selected_states):
    selected_in_order = [s for s in STATE_ORDER if s in selected_states]
    char_map = {}
    for i, state in enumerate(selected_in_order):
        char_map[state] = SHADING[i]
    for state in STATE_ORDER:
        if state not in char_map:
            char_map[state] = SHADING[-1]
    return char_map, selected_in_order


def make_header(selected_in_order, has_remainder):
    parts = [s.abbrev for s in selected_in_order]
    if has_remainder:
        parts.append("~")
    return "/".join(parts)


def make_legend(char_map, selected_in_order, has_remainder):
    parts = [f"{char_map[s]} {s.label}" for s in selected_in_order]
    if has_remainder:
        unselected = [s.label for s in STATE_ORDER if s not in selected_in_order]
        parts.append(f"{SHADING[-1]} ({'/'.join(unselected)})")
    return "  ".join(parts)


def build_bar(counts, total, width, char_map, selected_in_order):
    if total == 0:
        return ""

    remainder_states = [s for s in STATE_ORDER if s not in selected_in_order]
    parts = []
    cumulative = 0
    bar_pos = 0
    for state in selected_in_order + remainder_states:
        count = counts.get(state, 0)
        cumulative += count
        end_pos = round(width * cumulative / total)
        parts.append(char_map[state] * (end_pos - bar_pos))
        bar_pos = end_pos
    return "".join(parts)


def format_summary(markdown_files, width, selected_states):
    char_map, selected_in_order = build_visualisation_map(selected_states)
    has_remainder = len(selected_states) < len(STATE_ORDER)

    widest = max(len(mf.tasks) for mf in markdown_files)
    count_width = len("/".join(str(widest) for _ in selected_in_order))
    if has_remainder:
        count_width += len(f"/{widest}")
    gap = "  "
    bar_width = max(
        10,
        width
        - count_width
        - max(len(mf.display_path) for mf in markdown_files)
        - len(gap) * 3
    )

    header = make_header(selected_in_order, has_remainder)
    header = header.rjust(bar_width + len(gap) + count_width)

    lines = [header]
    for md_file in markdown_files:
        total = len(md_file.tasks)
        counts = Counter(task.state for task in md_file.tasks)

        file_bar_width = round(bar_width * total / widest)
        bar = build_bar(counts, total, file_bar_width, char_map, selected_in_order)

        count_parts = [str(counts.get(s, 0)) for s in selected_in_order]
        if has_remainder:
            remainder_count = sum(
                counts.get(s, 0) for s in STATE_ORDER if s not in selected_states
            )
            count_parts.append(str(remainder_count))
        count_str = "/".join(count_parts)

        lines.append(
            f"{bar.ljust(bar_width)}{gap}"
            f"{count_str.rjust(count_width)}{gap}"
            f"{md_file.display_path}"
        )

    lines.append("")
    lines.append(make_legend(char_map, selected_in_order, has_remainder))

    return "\n".join(lines)
