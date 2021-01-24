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
aws --profile acg_demo --region us-east-1 cloudformation deploy --stack-name ansible-bucket --template-file cloudformation/ansible_bucket.template
aws --profile <profile_name> --region us-east-1 cloudformation deploy --stack-name ansible-bucket --template-file cloudformation/ansible_bucket.template

aws --profile acg_demo --region us-east-1 s3 cp archives/lambda.zip s3://acg-demo-lambda/lambda.zip
aws --profile <profile_name> --region us-east-1 s3 cp archives/lambda.zip s3://<lambda_bucket_name>/lambda.zip 

aws --profile acg_demo --region us-east-1 cloudformation deploy --stack-name ansible-provisioning --template-file cloudformation/ansible_provisioning.template --capabilities CAPABILITY_NAMED_IAM --parameter-overrides BucketStackName=ansible-bucket
aws --profile <profile_name> --region us-east-1 cloudformation deploy --stack-name ansible-provisioning --template-file cloudformation/ansible_provisioning.template --capabilities CAPABILITY_NAMED_IAM --parameter-overrides BucketStackName=ansible-bucket
```

Delete stacks
```shell
cd cloudformation
aws --profile acg_demo --region us-east-1 cloudformation delete-stack --stack-name ansible-provisioning
aws --profile <profile_name> --region us-east-1 cloudformation delete-stack --stack-name ansible-provisioning

aws --profile acg_demo --region us-east-1 cloudformation delete-stack --stack-name ansible-bucket
aws --profile <profile_name> --region us-east-1 cloudformation delete-stack --stack-name ansible-bucket
```
