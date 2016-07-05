speedlock.pl
============

**WARNING - THIS IS NOT WELL TESTED - USE AT YOUR OWN RISK!**

This script is ment to cover basic usecase of backporting commits to sprint branch in Teradata Presto workflow. It mostly solves problems in optimistic scenario when no human intervention is needed during backport. It may slow down the process to achieve a goal of only pushing to sprint branch things that do pass Travis test flow.

It is recommended to run this script in `screen` in order to avoid premature terminatation problems.

Usage
-----

To use the script just run one of the following commands with working directory beeing presto repository in "clean" state (no uncommited work, no rebase nor cherry-pick in progress etc.).

- `speedlock.pl [commit/range to cherry-pick]` - run in local terminal
- `screen speedlock.pl [commit/range to cherry-pick]` - run in screen

Configuration
-------------

Configuration is done directly in script by setting following variables

- `SPRINT_BRANCH` - sprint/release branch you want to commit work to
- `TD_REMOTE` - your git repository remote name pointing to http://github.com/Teradata/presto remote
- `WORKER_REMOTE` - your git repository remote name that you want to use as Travis worker (your private for of presto is a nice candidate)
- `WORKER_REPO` - github path to Travis worker
- `ALARM_COMMAND` - command that will be executed to let you know that something went wrong in the script execution

Dependencies
------------

- `perl` >= 5.18
- `ruby` (`gem`) >= 2.3.1
- `travis` client

Travis CLI installation and configuration
-----------------------------------------

- `$ gem install travis`
- `$ travis login`


