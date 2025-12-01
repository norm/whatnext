ifndef CI
ifndef VIRTUAL_ENV
$(error Development has to happen inside venv, whatnext is also installed globally.)
endif
endif

.PHONY: test flake8 bats pytest

test: flake8 pytest bats

flake8:
	flake8 whatnext tests

bats:
	bats tests/*.bats

pytest:
	pytest tests/
