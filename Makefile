.PHONY: test flake8 bats pytest

test: flake8 bats pytest

flake8:
	flake8 whatnext tests

bats:
	bats tests/*.bats

pytest:
	pytest tests/
