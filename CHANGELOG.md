# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.6] - unreleased

Output is now colour-coded by default, override with `--color/--no-color`
or by setting `WHATNEXT_COLOR`.


## [v0.5] - 2025-12-01

Tasks can have deadlines using the `@YYYY-MM-DD/4w` syntax. As the deadline
approaches, the task's priority automatically shifts to `imminent` (two weeks
before by default). Once past the deadline, the priority becomes `overdue`.


## [v0.4] - 2025-12-01

Individual tasks and sections of tasks can be marked with emphasis to denote
\_medium\_ priority or as \*\*high\*\* priority. They will be displayed at the
top of the output, each priority in separate blocks.


## [v0.3] — 2025-11-29

Adding more states to the roster, tasks can be marked as open (unstarted),
in progress, cancelled, blocked, and completed.

Tasks can be filtered by any of these states when showing tasks or summaries.


## [v0.2] — 2025-11-28

Filtering tasks by text/header can be helpful. And as useful as it
can be to use `--dir` to specify the base dir, sometimes you just
want to do it quicker, so you can also specify a dir or file as
an argument to restrict searching just to that.

Arguments can be mixed and matched freely. Multiple search terms
are additive not exclusive.


## [v0.1] — 2025-11-28

First version, very basic. Lists tasks found in Markdown files in a
given directory. Can produce summaries.
