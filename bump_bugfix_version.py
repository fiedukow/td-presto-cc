#!/usr/local/bin/python

import sys

if len(sys.argv) < 2:
  print "Usage: " + sys.argv[0] + " currentVersion"
  sys.exit(1);

currentVersion = sys.argv[1]

splitedVersion = currentVersion.split("-t");

if splitedVersion[1] == "":
  print splitedVersion[0] + "-t.0.1"
  sys.exit(0);

splitedTDVersion = splitedVersion[1].split(".");
if len(splitedTDVersion) == 2:
  print splitedVersion[0] + "-t." + splitedTDVersion[1] + ".1"
  sys.exit(0);

print splitedVersion[0] + "-t." + splitedTDVersion[1] + "." + str(int(splitedTDVersion[2]) + 1)
