output "ec2_publick_ip" {
  value       = aws_instance.minikube.public_ip
  description = "The public ip of the minikube instance"
}
