from collections import Counter

from whatnext.models import Priority, State
from whatnext.summary import (
    calculate_totals,
    make_header,
    make_legend,
    PRIORITY_DISPLAY_ORDER,
    shade_selection,
    SHADING,
)


class TestShadeSelection:
    def test_one_shade(self):
        shades = shade_selection(1)
        assert shades == [SHADING[1]]

    def test_five_shades(self):
        shades = shade_selection(5)
        assert shades == [SHADING[0], SHADING[1], SHADING[2], SHADING[3], SHADING[4]]

    def test_three_shades(self):
        shades = shade_selection(3)
        assert shades == [SHADING[0], SHADING[2], SHADING[4]]


class TestPriorityHeader:
    def test_high_priority_header(self):
        header = make_header([Priority.HIGH], has_remainder=True)
        assert header == "H ~"

    def test_medium_priority_header(self):
        header = make_header([Priority.MEDIUM], has_remainder=True)
        assert header == "M ~"

    def test_normal_priority_header(self):
        header = make_header([Priority.NORMAL], has_remainder=True)
        assert header == "N ~"


class TestPriorityLegend:
    def test_high_priority_legend(self):
        char_map = {
            Priority.OVERDUE: SHADING[-1],
            Priority.IMMINENT: SHADING[-1],
            Priority.HIGH: SHADING[1],
            Priority.MEDIUM: SHADING[-1],
            Priority.NORMAL: SHADING[-1],
        }
        legend = make_legend(
            char_map,
            [Priority.HIGH],
            PRIORITY_DISPLAY_ORDER,
            has_remainder=True,
        )
        assert legend == "█ High  ░ (Overdue/Imminent/Medium/Normal)"

    def test_medium_priority_legend(self):
        char_map = {
            Priority.OVERDUE: SHADING[-1],
            Priority.IMMINENT: SHADING[-1],
            Priority.HIGH: SHADING[-1],
            Priority.MEDIUM: SHADING[1],
            Priority.NORMAL: SHADING[-1],
        }
        legend = make_legend(
            char_map,
            [Priority.MEDIUM],
            PRIORITY_DISPLAY_ORDER,
            has_remainder=True,
        )
        assert legend == "█ Medium  ░ (Overdue/Imminent/High/Normal)"


class TestTotalsCalculation:
    def test_totals_sum_state_counts(self):
        file_counts = [
            Counter({State.OPEN: 3, State.COMPLETE: 1}),
            Counter({State.OPEN: 2, State.BLOCKED: 1}),
        ]
        total_counts = calculate_totals(file_counts)
        assert total_counts[State.OPEN] == 5
        assert total_counts[State.COMPLETE] == 1
        assert total_counts[State.BLOCKED] == 1
        assert total_counts[State.CANCELLED] == 0

    def test_totals_sum_priority_counts(self):
        file_counts = [
            Counter({Priority.HIGH: 2, Priority.NORMAL: 3}),
            Counter({Priority.HIGH: 1, Priority.MEDIUM: 2}),
        ]
        total_counts = calculate_totals(file_counts)
        assert total_counts[Priority.HIGH] == 3
        assert total_counts[Priority.NORMAL] == 3
        assert total_counts[Priority.MEDIUM] == 2
        assert total_counts[Priority.OVERDUE] == 0
