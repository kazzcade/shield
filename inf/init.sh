#!/bin/bash
cd `dirname $0`

for filename in ./*.yml; do
    echo Validating $filename
    errormessage=$( /sbin/modprobe -n -v hfsplus 2>&1)
    error=$(aws cloudformation validate-template --template-body file://$filename 2>&1 | grep error)
    if [[ -n $error ]]
     then
      echo $filename - $error
      exit 1
    fi
done

GitToken="b0ef08fc795203cf061d11c648142d061eea3707"
GitSecret="f5235a735d9879710276a41eeb405b6d06c365b5"
GitBranch=`git branch | grep \* | cut -d ' ' -f2`
GitRepo=`git rev-parse --show-toplevel | rev | cut -d/ -f1 | rev`
GitOwner='kazzcade'
## some resource require lowercase so please no uppercase
BaseStackName=`echo "$GitRepo-$GitBranch" | tr '[:upper:]' '[:lower:]'`
PipelineStackName=$BaseStackName-pipeline
Bucket=$BaseStackName-artifacts

## profile
read -p "AWS Profile (default): " profile
if [ -z "$profile" ]
then
   profile="default" 
fi


## parameters
echo Profile - $profile
echo Branch - $GitBranch
echo Repo - $GitRepo
echo Owner - $GitOwner
echo PipelineStackName - $PipelineStackName
echo Bucket - $Bucket

aws cloudformation deploy \
--profile $profile \
--template-file pipeline.yml \
--capabilities CAPABILITY_NAMED_IAM \
--stack-name $PipelineStackName \
--parameter-overrides \
BucketName=$Bucket \
GitRepo=$GitRepo \
GitBranch=$GitBranch \
GitSecret=$GitSecret \
GitToken=$GitToken \
BuildStackName=$BuildStackName \
GitOwner=$GitOwner \
