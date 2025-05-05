/*output "instance_table" {
  value = format(
    "Name                 | Public IP      | Instance State | Machine Type  | AMI ID\n%s\n%s",
    "---------------------|----------------|----------------|---------------|----------------------------",
    join("\n", [
      for instance in var.instance_names :
      format(
        "%-20s | %-14s | %-14s | %-14s | %-10s ",
        instance,
        aws_instance.ec2[instance].public_ip,
        aws_instance.ec2[instance].instance_state,
        aws_instance.ec2[instance].instance_type,
        var.ami_ids.Amazon_Linux,  # Replace ami reference with the correct variable
       # aws_instance.ec2[instance].id  # Use the instance ID or another attribute
      )
    ])
  )
}

output "instance-details" {
  value = format(
  for instance in var.instance_names
    [aws_instance.ec2[instance].tags.Name]
    aws_instance.ec2[instance].public_ip
  )
}  */

/*
output "instance_details" {
  value = join("\n", [
    for instance_name, instance in aws_instance.ec2 :     #to remove EOT
    format("[%s]\n%s", instance.tags.Name, instance.public_ip)
  ])
}
*/

output "instance_details" {
  value = join("\n", [
    for instance_name, instance in aws_instance.ec2 :
    format("[%s]\n%s", instance.tags.Name, instance.public_ip)
  ])
}


