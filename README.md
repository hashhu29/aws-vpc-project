AWS VPC built entirely from the terminal using the AWS CLI.

Contents:

- Custom VPC (10.0.0.0/16)
- Public and private subnets in eu-west-2a
- Internet Gateway for public internet access
- NAT Gateway for private subnet outbound access
- Route tables for both subnets
- Security groups locked down by IP and SG reference
- EC2 instances in both subnets
- Bastion host pattern for private EC2 access

## Architecture

```
Users
  └── Internet Gateway
        └── Public Subnet (AZ A)
              ├── Bastion EC2
              └── NAT Gateway
                    └── Private Subnet (AZ A)
                          └── Private EC2
```

## Prerequisites

- AWS CLI installed and configured
- IAM user with AdministratorAccess
- Key pair generated

## Usage

Build the infrastructure:
```bash
./scripts/create-vpc.sh
```

Tear everything down:
```bash
./scripts/teardown.sh
```

## Security

- Public EC2 allows SSH/HTTP from specific IP only
- Private EC2 only accepts connections from the public security group
- No credentials are stored in this repository
- .pem key files are gitignoreds