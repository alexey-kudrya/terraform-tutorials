output "ec2_public_ip" {
  value       = aws_instance.demo_ec2.public_ip
  description = "The public ip of the demo_ec2 instance"
}
