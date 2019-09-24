output "ip" {
  value = aws_instance.verdaccio_server.public_ip
}
output "domain" {
  value = aws_instance.verdaccio_server.public_dns
}
output "instance_id" {
  value = aws_instance.verdaccio_server.id
}
output "az" {
  value = aws_instance.verdaccio_server.availability_zone
}
