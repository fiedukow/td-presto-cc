#!/bin/bash
SSH_LOGIN="root"
HOSTS_FILE="/etc/hosts"
GENERATED_HOSTS_FILE="hosts_tmp"
INPUT_FILE_PATH=$1
SSH_PRIVATE_KEY_PATH=$2

function usage {
  echo
  echo "Usage: $0 [input_file] [ssh_private_key_path]"
  echo
  echo "Input_file in format:"
  echo "  host_name1 public_ip1 private_ip1"
  echo "  host_name2 public_ip2 private_ip2"
  echo
  echo "This script will install /etc/host with all host_name and host_name_private on all servers on list using ssh_private_key_path SSH key and $SSH_LOGIN login."
  echo
  echo "/etc/hosts backup will be stored on each machine as /etc/hosts.timestamp.old"
  echo
}

function ssh_for_each {
  while read host_name public_ip private_ip
  do
    echo "      * Executing on $host_name"
    ssh -n root@$public_ip -i $SSH_PRIVATE_KEY_PATH -o StrictHostKeyChecking=no "$@" 2>>$hostname.ssh.log
  done < "$INPUT_FILE_PATH"
}

function backup_hosts {
  BACKUP_NAME="$HOSTS_FILE.`date +"%s"`.old"
  echo "=> Backing up $HOSTS_FILE as $BACKUP_NAME"
  ssh_for_each cp $HOSTS_FILE $BACKUP_NAME
}

function create_new_hosts {
  echo "=> Generating new hosts"
  echo > $GENERATED_HOSTS_FILE
  while read host_name public_ip private_ip
  do
    if [ "x$host_name" == "x" ]
    then
      echo "      * ERROR! EMPTY LINE AT THE END OF INPUT FILE '$INPUT_FILE_PATH' IS NOT SUPPORTED"
      exit 1
    fi
 
    echo "      * Found host $host_name ($public_ip, $private_ip)"
    echo $public_ip $host_name >> $GENERATED_HOSTS_FILE
    echo $private_ip ${host_name}_prv >> $GENERATED_HOSTS_FILE
  done < "$INPUT_FILE_PATH"
}

function install_hosts {
  NEW_HOSTS_CONTENT="$(cat $GENERATED_HOSTS_FILE)"
  echo "=> Installing new /etc/hosts"
  ssh_for_each "echo \"$NEW_HOSTS_CONTENT\" >> /etc/hosts"
}

if [ $# -ne 2 ]
then
  usage
  exit 1
fi

# prepare /etc/hosts content
create_new_hosts

# login to all machines and save /etc/hosts as /etc/hosts.timestamp.old
backup_hosts

# login to all machines and add new content to /etc/hosts
install_hosts

