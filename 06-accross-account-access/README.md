**Configure AWS credentials**

Before `terraform init` configure AWS credentials

`cat ~/.aws/credentials`
```
[account-a]
aws_access_key_id=<ACCOUNT-A KEY>
aws_secret_access_key=<ACCOUNT-A SECRET KEY>

[account-b]
aws_access_key_id=<ACCOUNT-B KEY>
aws_secret_access_key=<ACCOUNT-B SECRET KEY>

```

**Terraform init**

After `init` running you need to specify the ssh key to the EC2 instance.

**From the Amazon EC2 instance, configure the role with your credentials**

```
mkdir /home/ec2-user/.aws/
cat <<EOF > /home/ec2-user/.aws/config
[profile demo]
role_arn = arn:aws:iam::ACCOUNT-B-ID:role/ROLE-NAME
credential_source = Ec2InstanceMetadata
EOF
chown -R ec2-user:ec2-user /home/ec2-user/.aws/
```
**Verify the instance profile**

```
aws sts get-caller-identity --profile demo
```
```
touch file1.txt
aws s3 cp file1.txt s3://S3-BUCKET-NAME
```