#!/bin/bash
cd `dirname $0`

GitBranch=`git branch | grep \* | cut -d ' ' -f2`
GitRepo=`git rev-parse --show-toplevel | rev | cut -d/ -f1 | rev`

Bucket=$GitRepo-$GitBranch-artifacts

make debug-build

sam local invoke -t inf/buildStatusEventHandler.sam.yml -d 5986 --debugger-path debug --debug-args "-delveAPI=2" -e samples/build.json --parameter-overrides Bucket=$Bucket
