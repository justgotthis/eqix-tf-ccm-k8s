apiVersion: v1
kind: Secret
metadata:
  name: packet-cloud-config
  namespace: kube-system
stringData:
  cloud-sa.json: |
    {
    "apiKey": "${auth_token}",
    "projectID": "${project_id}"
    }
