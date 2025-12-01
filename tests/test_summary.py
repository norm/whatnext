from whatnext.models import Priority
from whatnext.summary import (
    build_visualisation_map,
    make_header,
    make_legend,
    PRIORITY_DISPLAY_ORDER,
    SHADING,
)


class TestPriorityVisualisationMap:
    def test_single_priority_selected(self):
        char_map, selected_in_order = build_visualisation_map(
            {Priority.HIGH},
            PRIORITY_DISPLAY_ORDER,
        )
        assert selected_in_order == [Priority.HIGH]
        assert char_map[Priority.HIGH] == SHADING[0]
        assert char_map[Priority.MEDIUM] == SHADING[-1]
        assert char_map[Priority.NORMAL] == SHADING[-1]

    def test_all_priorities_selected(self):
        char_map, selected_in_order = build_visualisation_map(
            set(Priority),
            PRIORITY_DISPLAY_ORDER,
        )
        assert selected_in_order == list(PRIORITY_DISPLAY_ORDER)
        assert char_map[Priority.HIGH] == SHADING[0]
        assert char_map[Priority.MEDIUM] == SHADING[1]
        assert char_map[Priority.NORMAL] == SHADING[2]


class TestPriorityHeader:
    def test_high_priority_header(self):
        header = make_header([Priority.HIGH], has_remainder=True)
        assert header == "H/~"

    def test_medium_priority_header(self):
        header = make_header([Priority.MEDIUM], has_remainder=True)
        assert header == "M/~"

    def test_normal_priority_header(self):
        header = make_header([Priority.NORMAL], has_remainder=True)
        assert header == "N/~"


class TestPriorityLegend:
    def test_high_priority_legend(self):
        char_map = {
            Priority.HIGH: SHADING[0],
            Priority.MEDIUM: SHADING[-1],
            Priority.NORMAL: SHADING[-1],
        }
        legend = make_legend(
            char_map,
            [Priority.HIGH],
            PRIORITY_DISPLAY_ORDER,
            has_remainder=True,
        )
        assert legend == "▚ High  ░ (Medium/Normal)"

    def test_medium_priority_legend(self):
        char_map = {
            Priority.HIGH: SHADING[-1],
            Priority.MEDIUM: SHADING[0],
            Priority.NORMAL: SHADING[-1],
        }
        legend = make_legend(
            char_map,
            [Priority.MEDIUM],
            PRIORITY_DISPLAY_ORDER,
            has_remainder=True,
        )
        assert legend == "▚ Medium  ░ (High/Normal)"
