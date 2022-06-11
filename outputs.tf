//Output of EC2 Private IP
//Instance ID
output "Instance_ID" {
  description = "EC2 instance ID"
  value = aws_instance.my-ec2.id
}

//Output of EC2 Private IP
output "Private_IP" {
  description = "Private IP of the EC2 instance"
  value = aws_instance.my-ec2.private_ip
}

//Output of EC2 Public IP
output "Public_IP" {
  description = "Public IP of the EC2 instance"
  value = aws_instance.my-ec2.public_ip
}

