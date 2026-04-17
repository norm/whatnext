import shutil

from whatnext.whatnext import load_config


class TestMuteLoading:
    def test_expired_mutes_filtered_from_config(self, tmp_path):
        shutil.copytree("tests/mute", tmp_path / "mute")
        config = load_config(directory=str(tmp_path / "mute"), extensions=["mute"])

        patterns = [entry["pattern"] for entry in config["mute"]]
        assert "future" in patterns
        assert "old" not in patterns
