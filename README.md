Preparation
```shell
mkdir archives
cd ansible
zip ../archives/ansible.zip *
cd ../lambda
zip ../archives/lambda.zip *

```

Create stacks
```shell
cd cloudformation
aws --profile acg_demo --region us-east-1 cloudformation deploy --stack-name ansible-bucket --template-file ansible_bucket.template
aws --profile <profile_name> --region us-east-1 cloudformation deploy --stack-name ansible-bucket --template-file ansible_bucket.template

aws --profile acg_demo --region us-east-1 cloudformation deploy --stack-name ansible-provisioning --template-file ansible_provisioning.template --capabilities CAPABILITY_NAMED_IAM --parameter-overrides BucketStackName=ansible-bucket
aws --profile <profile_name> --region us-east-1 cloudformation deploy --stack-name ansible-provisioning --template-file ansible_provisioning.template --capabilities CAPABILITY_NAMED_IAM --parameter-overrides BucketStackName=ansible-bucket
```

Delete stacks
```shell
cd cloudformation
aws --profile acg_demo --region us-east-1 cloudformation delete-stack --stack-name ansible-provisioning
aws --profile <profile_name> --region us-east-1 cloudformation delete-stack --stack-name ansible-provisioning

aws --profile acg_demo --region us-east-1 cloudformation delete-stack --stack-name ansible-bucket
aws --profile <profile_name> --region us-east-1 cloudformation delete-stack --stack-name ansible-bucket
```
