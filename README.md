# Terraform-EC2-Jenkins
Simple Terraform Script to provision AWS EC2 (with Jenkins setup) + VPC resources

....................
> Note:
  - Better to configure access throgh aws configure profile (cli/vscode extention)
  >>  Or
  - env varibles (Below steps)
   - for Linux ...
     - export AWS_ACCESS_KEY_ID="anaccesskey"
     - export AWS_SECRET_ACCESS_KEY="asecretkey"
     - export AWS_REGION="us-west-2"
   - for windows ...
     - $env:AWS_ACCESS_KEY_ID="anaccesskey"
     - $env:AWS_SECRET_ACCESS_KEY="asecretkey"
     - $env:AWS_REGION="us-west-2"

