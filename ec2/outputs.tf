output "address" {
  value = "${aws_instance.web.public_dns}"
}

output "image_id" {
  value = "${data.aws_ami.ubuntu_latest.id}"
}

output "image_name" {
  value = "${data.aws_ami.ubuntu_latest.name}"
}
