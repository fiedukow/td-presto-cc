#!/bin/bash

function current_tag {
  grep "<tag>.*</tag>" pom.xml | sed "s#<tag>\(.*\)</tag>#\1#g" | xargs
}

function current_version {
  grep "<artifactId>presto-root</artifactId>" pom.xml -A1 | grep version | sed "s#<version>\(.*\)</version>#\1#g" | xargs
}

if [ $# -ne 2 ]; then
  echo "Usage: $0 [NewVersion] [NewTag]"
  exit
fi

find . -name pom.xml | xargs sed -i "" "s#<tag>`current_tag`</tag>#<tag>$2</tag>#g"
find . -name pom.xml | xargs sed -i "" "s#<version>`current_version`</version>#<version>$1</version>#g"

