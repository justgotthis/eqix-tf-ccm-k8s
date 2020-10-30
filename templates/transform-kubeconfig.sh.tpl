#!/bin/bash

echo "START KUBECONFIG REWRITE"

sed -r 's/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/"${pub_ip}"/ ~/.kube/config > /tmp/config.scp

echo "---END KUBECONFIG REWRITE---"
