#!/bin/bash

set -e

# Extract "host" argument from the input into HOST shell variable
eval "$(jq -r '@sh "MYPUB=\(.mypub)"')"

# Fetch the join command
CMD=$(echo "You can transfer your kubeconfig file with the following command: \"mkdir ~/.kube ; scp root@$MYPUB:/tmp/config.scp ~/.kube/config\"")

# Produce a JSON object containing the join command
jq -n --arg command "$CMD" '{"command":$command}'
