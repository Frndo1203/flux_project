#!/usr/bin/env zsh

# Ensure you're in the Terraform directory
# If not, uncomment and modify the following line to navigate to your Terraform directory
# cd /path/to/your/terraform/directory

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed."
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed."
    exit 1
fi

# Fetch outputs from Terraform
cluster_name=$(terraform output -raw cluster_name)
cluster_endpoint=$(terraform output -raw cluster_endpoint)
region=$(terraform output -raw region)

# If 'region' output is not set, default to 'us-east-1'
if [[ -z "$region" ]]; then
    region="us-east-1"
fi

# Validate that 'cluster_name' is not empty
if [[ -z "$cluster_name" ]]; then
    echo "Error: 'cluster_name' output is empty."
    exit 1
fi

# Run the AWS EKS update-kubeconfig command
echo "Updating kubeconfig for cluster '$cluster_name' in region '$region'..."
aws eks --region "$region" update-kubeconfig --name "$cluster_name"

if [[ $? -eq 0 ]]; then
    echo "kubeconfig updated successfully."
else
    echo "Failed to update kubeconfig."
    exit 1
fi
