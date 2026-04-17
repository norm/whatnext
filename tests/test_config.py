import shutil
from datetime import timedelta

import pytest

from whatnext.whatnext import load_config, parse_period, resolve_config_path


class TestParsePeriod:
    def test_days(self):
        assert parse_period("1d") == timedelta(days=1)
        assert parse_period("5d") == timedelta(days=5)

    def test_weeks(self):
        assert parse_period("1w") == timedelta(weeks=1)
        assert parse_period("2w") == timedelta(weeks=2)

    def test_months(self):
        assert parse_period("1m") == timedelta(days=30)
        assert parse_period("2m") == timedelta(days=60)

    def test_combined(self):
        assert parse_period("2m3w") == timedelta(days=60 + 21)
        assert parse_period("1m2w3d") == timedelta(days=30 + 14 + 3)

    def test_invalid_format_raises(self):
        with pytest.raises(ValueError):
            parse_period("")
        with pytest.raises(ValueError):
            parse_period("abc")
        with pytest.raises(ValueError):
            parse_period("1x")


class TestMuteLoading:
    def test_expired_mutes_filtered_from_config(self, tmp_path):
        shutil.copytree("tests/mute", tmp_path / "mute")
        config_path = resolve_config_path(None, str(tmp_path / "mute"))
        config = load_config(config_path, extensions=["mute"])

        patterns = [entry["pattern"] for entry in config["mute"]]
        assert "future" in patterns
        assert "old" not in patterns
