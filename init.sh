#!/bin/bash
#
# This script generates keys needed for the deployment
#

echo "Generating message authentication keys"
export IMS_SEC=$( uuidgen )
export IMS_PUB=$( uuidgen )
export RABBITMQ_SEC=$( uuidgen )
export RABBITMQ_PUB=$( uuidgen )

env_vars='$IMS_SEC $IMS_PUB $RABBITMQ_SEC $RABBITMQ_PUB'

echo "Writing values.yaml file"
envsubst <values.yaml.template "$env_vars" >values.yaml
