#!/usr/bin/perl

use strict;
use warnings;

#### CONFIGURE HERE
my $SPRINT_BRANCH = "release-0.148-t.1";
my $TD_REMOTE = "origin";
my $WORKER_REMOTE = "fiedukow";
my $WORKER_REPO = "fiedukow/presto";
my $ALARM_COMMAND = "osascript -e 'display notification \"There was a problem with backport. Please check that.!\" with title \"Backport failed\"'";
#### END OF CONFIGURATION

# TODO LIST:
# - quite mode
# - fast local test using mvn
# - external configuration
# - better function naming and separation

sub alarm_and_die {
  my ($DIE_MSG) = @_;
  `$ALARM_COMMAND`;
  die ($DIE_MSG);
}

sub run_or_die_with_print {
  my ($COMMAND, $PRINT) = @_;
  if ($PRINT) {
    print "Running: `$COMMAND`\n";
  }
  my $RES = `$COMMAND`;
  if ($? != 0) {
    alarm_and_die("$COMMAND failed");
  }
  return $RES;
}

sub run_or_die {
  my ($COMMAND) = @_;
  run_or_die_with_print($COMMAND, 1);
}

sub build {
  my ($BRANCH_NAME) = @_;

  run_or_die("git checkout $SPRINT_BRANCH");
  run_or_die("git pull $TD_REMOTE $SPRINT_BRANCH");
  run_or_die("git checkout -b $BRANCH_NAME");
  run_or_die("git cherry-pick $ARGV[0]");
  run_or_die("git push $WORKER_REMOTE $BRANCH_NAME");

  print "Waiting 10secs for travis!\n";
  sleep 10;

  my $BUILD_ID = run_or_die("travis branches --repo $WORKER_REPO | grep $BRANCH_NAME | awk '{ printf substr(\$2,2) }'");
  my $LINK = run_or_die("travis open --print --repo $WORKER_REPO $BUILD_ID");
  print "YOU CAN OBSERVE STATUS OF THE BUILD HERE:\n";
  print $LINK;
  
  my $RESULT = "created";
  while ($RESULT eq "created" or $RESULT eq "started") {
    $RESULT = run_or_die_with_print("travis branches --repo $WORKER_REPO | grep $BRANCH_NAME | awk '{ printf \$3 }'", 0);
    print ".";
    sleep 10;
  }
  print "\n";
  
  print "JOB HAS ENDED WITH STATUS: $RESULT\n";
  return $RESULT eq "passed";
}

sub try_push {
  while (1) {
    my $BRANCH_NAME = time;
    my $SUCCESS = build($BRANCH_NAME);
    if (not $SUCCESS) {
      alarm_and_die("You have to fix something, see travis for more informations");
    }

    run_or_die("git branch -D $SPRINT_BRANCH");
    run_or_die("git checkout -b $SPRINT_BRANCH");

    print "Running: `git push $TD_REMOTE $SPRINT_BRANCH`\n";
    `git push $TD_REMOTE $SPRINT_BRANCH`;
    if ($? == 0) {
      print "MY JOB HERE IS DONE!\n";
      exit(0);
    }
    
    print "OH :-( Someone was faster than light! I'll try to do it faster this time!\n";

    run_or_die("git checkout $BRANCH_NAME");
    run_or_die("git branch -D $SPRINT_BRANCH");
    run_or_die("git checkout $TD_REMOTE/$SPRINT_BRANCH");
    run_or_die("git checkout -b $SPRINT_BRANCH");
  }
}

if (@ARGV != 1) {
  print "Usage: $0 commit/range\n";
  die("Invalid arguments");
}

try_push()

