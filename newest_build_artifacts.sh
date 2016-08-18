#!/bin/bash

TD_BUCKET_URI=s3://teradata-presto/travis_build_artifacts/Teradata/presto
BRANCH=$1
ARTIFACT_PREFIX=$2
OUTPUT_NAME=$3

pip install awscli > /dev/null

last_build=`aws s3 ls $TD_BUCKET_URI/$BRANCH/ --no-sign-request | sort -r -k1 -n | head -n1 | awk '{printf $2}' | awk '{print substr($0, 1, length($0)-1)}'`
artifact_name=`aws s3 ls $TD_BUCKET_URI/$BRANCH/$last_build/ --no-sign-request | grep $ARTIFACT_PREFIX | awk '{printf $4}'`
aws s3 cp $TD_BUCKET_URI/$BRANCH/$last_build/$artifact_name $OUTPUT_NAME --no-sign-request
echo $artifact_name

