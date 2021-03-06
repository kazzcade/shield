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

GitSecret=$(echo -n "value" | openssl sha1 -hmac "key" | awk '{print $2}')
GitBranch=`git branch | grep \* | cut -d ' ' -f2`
GitRepo=`git rev-parse --show-toplevel | rev | cut -d/ -f1 | rev`
GitOwner='kazzcade'
## some resource require lowercase so please no uppercase
BaseStackName=`echo "$GitRepo-$GitBranch" | tr '[:upper:]' '[:lower:]'`
PipelineStackName=$BaseStackName

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

aws cloudformation deploy \
--profile $profile \
--template-file pipeline.yml \
--capabilities CAPABILITY_NAMED_IAM \
--stack-name $PipelineStackName \
--parameter-overrides \
GitRepo=$GitRepo \
GitBranch=$GitBranch \
GitSecret=$GitSecret \
BuildStackName=$BuildStackName \
GitOwner=$GitOwner \
