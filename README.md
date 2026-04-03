# AKSAzureTerraform

This repository contains Terraform configurations for Azure Kubernetes Service (AKS) deployment.

## Overview

This Terraform code provisions:
- Azure Kubernetes Service (AKS) cluster
- Virtual Network and Subnet
- Azure Storage Account for logs

## Security

This repository includes:
- **Checkov** security scanning for Terraform
- **GitHub Actions** CI/CD pipeline
- Security checks run on every PR

## Getting Started

```bash
# Initialize Terraform
terraform init

# Validate Terraform syntax
terraform validate

# Plan changes
terraform plan
```

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/terraform.yml`) runs:
1. Terraform Validate
2. Checkov Security Scan
3. Terraform Plan (dry run)

**Note**: No Azure credentials required for validation and plan steps.