# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
data "aws_ami" "image" {
  owners      = var.ami_owner   # This is the image publisher owner ID
  most_recent = var.most_recent # Get the most recent image or not
  filter {
    name   = var.iamge_filter_type  # Filter by name
    values = var.image_filter_value # Adjust the filter to match the desired AMI name pattern
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#attribute-reference
resource "aws_instance" "this" {
  ami                    = data.aws_ami.image.id # Using the latest Image ID from the data source.
  instance_type          = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids                 #Associating the security group(s) with the instance.
  subnet_id              = var.subnet_id                              # Placing the instance in the specified subnet.
  key_name               = var.use_ssh ? var.ssh_key_pair_name : null # Using the generated SSH key pair name for the instance.
  tags                   = var.default_tags

  # Configure the root block device for the instance.
  root_block_device {
    volume_type           = var.volume_type           # Type of volume (e.g., gp3)
    volume_size           = var.volume_size           # Size in GB
    delete_on_termination = var.delete_on_termination # Whether to delete the volume on instance termination
  }

}
