#!/bin/bash -e

SPRINT_TO_END="$1"
IS_DRY="$2"

function execute_safe
{
  echo "Running: $@"
  if [ "$IS_DRY" == "--not-dry" ]
  then
    echo $@ | bash
    exit
  fi

  echo "Dry!"
}

function verify_travis_green
{
  TO_CHECK=$1

  echo "Checking if branch $TO_CHECK is green"
  STATUS="$(travis history -b $TO_CHECK -l1 2>/dev/null | awk '{ printf $2 }' | sed 's/://')";
  if [ "$STATUS" != "passed" ]
  then
    echo "Sprint branch $TO_CHECK is not green on Travis. Cannot close that."
    echo "Status of $TO_CHECK is: $STATUS."
    exit 1
  fi
  echo "$TO_CHECK is good to go!"
}

function checkout_and_pull
{
  BRANCH=$1

  echo "Checking out newest version of $BRANCH"
  execute_safe git checkout $BRANCH
  execute_safe git pull origin $BRANCH
}

function current_tag {
  grep "<tag>.*</tag>" pom.xml | sed "s#<tag>\(.*\)</tag>#\1#g" | xargs
}
 
function current_version {
  grep "<artifactId>presto-root</artifactId>" pom.xml -A1 | grep version | sed "s#<version>\(.*\)</version>#\1#g" | xargs
}

function commit_tag_and_push
{
  VERSION_TO_TAG=$1
  
  execute_safe git commit -a -m \"Prepare release $VERSION_TO_TAG\"
  execute_safe git tag $VERSION_TO_TAG
  execute_safe git push origin $VERSION_TO_TAG
}

function commit_next_iteration_and_push
{
  NEW_VERSION=$1

  execute_safe git commit -a -m \"Prepare next development iteration $NEW_VERSION-SNAPSHOT\" 
  execute_safe git push origin $SPRINT_TO_END
}

function change_version
{
  CH_VER="find . -name pom.xml | xargs sed -i \"\" \"s#<tag>$(current_tag)</tag>#<tag>$2</tag>#g\""
  CH_TAG="find . -name pom.xml | xargs sed -i \"\" \"s#<version>$(current_version)</version>#<version>$1</version>#g\""
  execute_safe $CH_VER
  execute_safe $CH_TAG
}

function bump_bugfix_version
{
  VERSION_TO_BUMP=$1

  python bump_bugfix_version.py $VERSION_TO_BUMP
}

if [ $# -lt 1 ]
then
  echo "Usage: $0 sprintBranchToClose [--not-dry]"
  exit 1
fi

verify_travis_green $SPRINT_TO_END
checkout_and_pull $SPRINT_TO_END

echo "Current version: $(current_version)"
VERSION=$(sed 's/-SNAPSHOT$//' <<< "$(current_version)")
echo "No snapshot version: $VERSION"

change_version $VERSION $VERSION
commit_tag_and_push $VERSION

NEW_VERSION="$(bump_bugfix_version $VERSION)"
echo "New version of $SPRINT_TO_END branch is: $NEW_VERSION-SNAPSHOT"

change_version "$NEW_VERSION-SNAPSHOT" "HEAD"
commit_next_iteration_and_push $NEW_VERSION

