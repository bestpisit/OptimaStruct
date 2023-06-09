# OptimaStruct

OptimaStruct is a one-click Infrastructure as Code (IaC) solution, currently under development.

## Table of Contents
1. [Introduction](#introduction)
2. [Features](#features)
3. [Installation](#installation)
4. [Usage](#usage)

## Introduction

OptimaStruct makes it simple to manage and provision your cloud infrastructure resources by using a simple, declarative programming language, and to deploy and manage those resources using a few CLI commands.

## Features

- Infrastructure As Code
- Supports multiple environments, e.g., dev, test, staging, production
- Terraform with pipelines
- Infrastructure State Consistency
- Simple setup

## Installation

Before you begin, you will need to have the following installed:

- [Terraform](https://www.terraform.io/downloads.html)

To install OptimaStruct, follow these steps:

1. Clone the repository:
```bash
git clone https://github.com/bestpisit/OptimaStruct.git
cd OptimaStruct
```
2. Go to terraform folder
```bash
cd terraform
```

3. Initialize Terraform:
```bash
terraform init
```
This command is used to initialize a working directory containing Terraform configuration files.

4. Set the poject configuration

terraform/main.tf
```bash
module "configuration" {
  source = "./configuration"

  project-name = "__projectname__"
  environment = "__environment__"
  rgname = "__rgterraform__"
}
```
for example:
```bash
module "configuration" {
  source = "./configuration"

  project-name = "codingversus"
  environment = "prod"
  rgname = "rg-codingversus-prod"
}
```
## Usage

After installation, you can use OptimaStruct with the following commands:

1. Create an execution plan with Terraform:
```bash
terraform plan
```

2. Apply the changes to reach the desired state of the configuration:
```bash
terraform apply
```

## Terraform With Azure Pipelines Installation

- see the document

[OptimaStruct Documentation](https://drive.google.com/file/d/1IQYLueX60B1-sD6XRF1AQBuWepQmv8Yb/view?usp=sharing "Google's Homepage")
