#!/bin/bash

# Define log file and host file locations
LOG_FILE="terraform_apply.log"
HOST_FILE="hosts"
LOCAL_LOG_DIR="/Users/mahesh/Desktop/projects/eureka/eureka/terraform/"  # Modify this with your local directory where you want to store the logs

# Get the current timestamp
START_TIME=$(date "+%Y-%m-%d %H:%M:%S")

# Log the start time
echo "$START_TIME - Starting terraform apply" > $LOG_FILE

# Run terraform apply in the background and log output
terraform apply -auto-approve -lock=false >> $LOG_FILE 2>&1 &
TERRAFORM_PID=$!

# Wait for terraform apply to finish
wait $TERRAFORM_PID

# Capture exit status of terraform apply
if [ $? -ne 0 ]; then
  echo "Error: Terraform apply failed. Check logs for details." >> $LOG_FILE
  exit 1
fi

# Get the end timestamp
END_TIME=$(date "+%Y-%m-%d %H:%M:%S")

# Log the end time and duration (macOS-compatible duration calculation)
START_TIMESTAMP=$(date -j -f "%Y-%m-%d %H:%M:%S" "$START_TIME" "+%s")
END_TIMESTAMP=$(date -j -f "%Y-%m-%d %H:%M:%S" "$END_TIME" "+%s")
DURATION=$((END_TIMESTAMP - START_TIMESTAMP))

echo "$END_TIME - Finished terraform apply" >> $LOG_FILE
echo "$END_TIME - Duration: $DURATION seconds" >> $LOG_FILE

# Extract terraform output to generate the hosts file
terraform output instance_details | sed '/<<EOT/d;/EOT/d' > $HOST_FILE

# Extract ansible-controller IP from the hosts file
ANSIBLE_CONTROLLER_IP=$(grep -A 1 "\[ansible-controller\]" $HOST_FILE | tail -n 1)

if [ -z "$ANSIBLE_CONTROLLER_IP" ]; then
  echo "Error: Could not find ansible-controller IP in hosts file." >> $LOG_FILE
  exit 1
fi

# Copy hosts file to the ansible-controller
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $HOST_FILE ec2-user@$ANSIBLE_CONTROLLER_IP:/home/ec2-user/hosts >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy hosts file to ansible-controller." >> $LOG_FILE
  exit 1
fi

echo "$END_TIME - Hosts file successfully copied to ansible-controller ($ANSIBLE_CONTROLLER_IP)" >> $LOG_FILE

# Execute Ansible playbooks on ansible-controller
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$ANSIBLE_CONTROLLER_IP <<EOF >> $LOG_FILE 2>&1
export ANSIBLE_HOST_KEY_CHECKING=False
  cd /home/ec2-user
  ansible-playbook -i hosts /home/ec2-user/playbook-jenkins-install-master.yaml > /home/ec2-user/playbook-jenkins-install-master.log 2>&1
  ansible-playbook -i hosts /home/ec2-user/playbook-jenkins-slave.yaml > /home/ec2-user/playbook-jenkins-slave.log 2>&1
  ansible-playbook -i hosts /home/ec2-user/playbook-sonar-install.yaml > /home/ec2-user/playbook-sonar-install.log 2>&1
  ansible-playbook -i hosts /home/ec2-user/playbook-k8s.yaml > /home/ec2-user/playbook-k8s.log 2>&1
EOF
 #ansible-playbook -i hosts /home/ec2-user/playbook-docker-install.yaml > /home/ec2-user/playbook-docker-install.log 2>&1

if [ $? -ne 0 ]; then
  echo "Error: Ansible playbook execution failed on ansible-controller." >> $LOG_FILE
  exit 1
fi

echo "$END_TIME - Ansible playbooks executed successfully on ansible-controller ($ANSIBLE_CONTROLLER_IP)" >> $LOG_FILE

# Copy Jenkins logs to your local machine
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$ANSIBLE_CONTROLLER_IP:/home/ec2-user/playbook-jenkins-install-master.log $LOCAL_LOG_DIR/playbook-jenkins-install-master.log >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy Jenkins master log file to local machine." >> $LOG_FILE
  exit 1
fi

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$ANSIBLE_CONTROLLER_IP:/home/ec2-user/playbook-jenkins-slave.log $LOCAL_LOG_DIR/playbook-jenkins-slave.log >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy Jenkins slave log file to local machine." >> $LOG_FILE
  exit 1
fi

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$ANSIBLE_CONTROLLER_IP:/home/ec2-user/playbook-sonar-install.log $LOCAL_LOG_DIR/playbook-sonar-install.log >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy Sonar log file to local machine." >> $LOG_FILE
  exit 1
fi

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@$ANSIBLE_CONTROLLER_IP:/home/ec2-user/playbook-k8s.log $LOCAL_LOG_DIR/playbook-k8s.log >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy K8s log file to local machine." >> $LOG_FILE
  exit 1
fi

echo "$END_TIME - Ansible logs successfully copied to local machine" >> $LOG_FILE
