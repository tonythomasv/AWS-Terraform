# EC2 Instance in India Region

This Terraform script creates an Ubuntu 22.04 EC2 instance in the AWS Mumbai region (ap-south-1) with a desktop environment (XFCE) and Firefox browser.

## Features

- Provisions a t3.medium EC2 instance (customizable) in Mumbai region
- Installs XFCE desktop environment and Firefox browser
- Configures RDP access for remote desktop connection
- Sets up SSH access using your provided SSH key
- Creates security group allowing SSH (port 22) and RDP (port 3389) access only from your specified IP
- Uses the latest official Ubuntu 22.04 LTS AMI from Canonical

## Prerequisites

1. AWS CLI installed and configured with appropriate credentials
2. Terraform installed (version 1.0.0+)
3. SSH key pair generated for accessing the instance
4. Knowledge of your public IP address

## Security Notice

⚠️ **Important:** The script currently sets a default password (`SecurePassw0rd!`) for the Ubuntu user. You should:
- Change this password immediately after connecting to the instance
- Consider using AWS Secrets Manager or similar for better security practices
- This password is only for the RDP connection, SSH access is still secured via your SSH key

## Setup Instructions

1. **Clone this repository**:
   ```bash
   git clone https://github.com/your-username/AWS-Terraform.git
   cd AWS-Terraform/ec2-instance-india
   ```

2. **Create your configuration file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit the configuration file** with your specific values:
   ```bash
   # In terraform.tfvars
   aws_profile = "your-aws-profile"
   ssh_public_key_path = "/path/to/your/ssh/key.pub"
   admin_ip = "your-public-ip" # Find with: curl ifconfig.me
   instance_type = "t3.medium" # Change if needed
   ```

4. **Initialize Terraform**:
   ```bash
   terraform init
   ```

5. **Preview the changes**:
   ```bash
   terraform plan
   ```

6. **Apply the configuration**:
   ```bash
   terraform apply
   ```

7. **Take note of the instance's public IP** displayed in the output.

## Connecting to Your Instance

### Via SSH
```bash
ssh ubuntu@<instance-public-ip>
```

### Via RDP
1. Use your preferred RDP client (Microsoft Remote Desktop, Remmina, etc.)
2. Connect to the public IP address of the instance
3. Login with:
   - Username: `ubuntu`
   - Password: `SecurePassw0rd!` (change this immediately!)

## Clean Up

To destroy all resources created by this Terraform script:
```bash
terraform destroy
```

## Customization

You can modify `main.tf` to customize various aspects:
- Instance type (default: t3.medium)
- Region (default: ap-south-1/Mumbai)
- Security group rules
- Software installed via user_data script

## Note

This instance is tagged for "EC2 Instance in India" but can be used for any legitimate purpose requiring an India-based IP address.
