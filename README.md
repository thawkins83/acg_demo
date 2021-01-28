Preparation
```shell
mkdir archives
cd lambda
zip ../archives/lambda.zip *
cd ..

```

Create stacks
```shell
aws --profile <profile_name> --region us-east-1 cloudformation deploy --stack-name ansible-lambda-bucket --template-file cloudformation/ansible_lambda_bucket.template
aws --profile <profile_name> --region us-east-1 s3 cp archives/lambda.zip s3://<lambda_bucket_name>/lambda.zip 
aws --profile <profile_name> --region us-east-1 cloudformation deploy --stack-name ansible-provisioning --template-file cloudformation/ansible_provisioning.template --capabilities CAPABILITY_NAMED_IAM --parameter-overrides BucketStackName=ansible-bucket
aws --profile <profile_name> --region us-east-1 cloudformation deploy --stack-name ec2-instances --template-file cloudformation/ec2_instances.template --capabilities CAPABILITY_NAMED_IAM

aws --profile acg_demo --region us-east-1 cloudformation deploy --stack-name ansible-lambda-bucket --template-file cloudformation/ansible_lambda_bucket.template
aws --profile acg_demo --region us-east-1 s3 cp archives/lambda.zip s3://acg-demo-lambda/lambda.zip
aws --profile acg_demo --region us-east-1 cloudformation deploy --stack-name ansible-provisioning --template-file cloudformation/ansible_provisioning.template --capabilities CAPABILITY_NAMED_IAM --parameter-overrides BucketStackName=ansible-bucket
aws --profile acg_demo --region us-east-1 cloudformation deploy --stack-name ec2-instances --template-file cloudformation/ec2_instances.template --capabilities CAPABILITY_NAMED_IAM

```

Delete stacks
```shell
aws --profile <profile_name> --region us-east-1 cloudformation delete-stack --stack-name ec2-instances
aws --profile <profile_name> --region us-east-1 cloudformation delete-stack --stack-name ansible-provisioning
aws --profile <profile_name> --region us-east-1 s3 rm s3://<lambda_bucket_name> --recursive
aws --profile <profile_name> --region us-east-1 cloudformation delete-stack --stack-name ansible-lambda-bucket

aws --profile acg_demo --region us-east-1 cloudformation delete-stack --stack-name ec2-instances
aws --profile acg_demo --region us-east-1 cloudformation delete-stack --stack-name ansible-provisioning
aws --profile acg_demo --region us-east-1 s3 rm s3://acg-demo-lambda --recursive
aws --profile acg_demo --region us-east-1 cloudformation delete-stack --stack-name ansible-lambda-bucket

```
