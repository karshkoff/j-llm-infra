# This repository holds Terraform configs for AWS infrastucture

## To run locally:
1. Set AWS account env vars
, [AWS credentials](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-files.html)
```
export AWS_REGION=us-east-1
export AWS_PROFILE=ak-dev
```

2. Clone repo and deploy infra
```
git clone https://github.com/karshkoff/j-llm-infra.git
cd j-lmm-infra
```
```
terraform init -backend-config=dev.s3.tfbackend
terraform apply
```

3. Destroy infra
```
terraform destroy
```

## Log in EKS
```
aws eks update-kubeconfig --name j-llm --region ${AWS_REGION} --profile ${AWS_PROFILE} --alias j-llm
kubectl config use-context j-llm
kubectl get nodes
```

