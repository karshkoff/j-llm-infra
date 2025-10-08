# This repository holds Terraform configs for AWS infrastucture

## TODO:

- [] k8s
- [] GPU
- [] network
- [] monitoring

## To run locally:
1. Set AWS account env vars:

    `export AWS_PROFILE=` or set [AWS credentials](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-files.html)

    `export AWS_REGION=`

2. `cd j-lmm-infra`
3. `terraform init -backend-config=dev.s3.tfbackend`

