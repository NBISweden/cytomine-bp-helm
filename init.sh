#!/bin/bash
#
# This script generates keys needed for the deployment
#

echo "Generating encryption keys"
key_file="configs/software_router/ssh_key"
if [ -f "$key_file" ]
then
    rm $key_file $key_file.pub
fi
ssh-keygen -C local -t rsa -m pem -b 2048 -f $key_file -P '' -q

echo "Generating message authentication keys"
export ADMIN_PASS=$( uuidgen )
export ADMIN_SEC=$( uuidgen )
export ADMIN_PUB=$( uuidgen )
export SUPERADMIN_SEC=$( uuidgen )
export SUPERADMIN_PUB=$( uuidgen )
export IMS_SEC=$( uuidgen )
export IMS_PUB=$( uuidgen )
export RABBITMQ_SEC=$( uuidgen )
export RABBITMQ_PUB=$( uuidgen )
export SERVER_ID=$( uuidgen )

env_vars='$ADMIN_PASS $ADMIN_SEC $ADMIN_PUB $SUPERADMIN_SEC $SUPERADMIN_PUB $IMS_SEC $IMS_PUB $RABBITMQ_SEC $RABBITMQ_PUB $SERVER_ID'

echo "Writing values.yaml file"
envsubst <values.yaml.template "$env_vars" >values.yaml
