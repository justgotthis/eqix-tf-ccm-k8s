---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: packet-cloud-controller-manager
  namespace: kube-system
  labels:
    app: packet-cloud-controller-manager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: packet-cloud-controller-manager
  template:
    metadata:
      labels:
        app: packet-cloud-controller-manager
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      dnsPolicy: Default
      hostNetwork: true
      serviceAccountName: cloud-controller-manager
      tolerations:
        # this taint is set by all kubelets running `--cloud-provider=external`
        # so we should tolerate it to schedule the packet ccm
        - key: "node.cloudprovider.kubernetes.io/uninitialized"
          value: "true"
          effect: "NoSchedule"
        - key: "CriticalAddonsOnly"
          operator: "Exists"
        # cloud controller manager should be able to run on masters
        - key: "node-role.kubernetes.io/master"
          effect: NoSchedule
      containers:
      - image: packethost/packet-ccm:${ccm_version}
        name: packet-cloud-controller-manager
        command:
          - "./packet-cloud-controller-manager"
          - "--cloud-provider=packet"
          - "--leader-elect=false"
          - "--allow-untagged-cloud=true"
          - "--authentication-skip-lookup=true"
          - "--provider-config=/etc/cloud-sa/cloud-sa.json"
        resources:
          requests:
            cpu: 100m
            memory: 50Mi
        volumeMounts:
          - name: cloud-sa-volume
            readOnly: true
            mountPath: "/etc/cloud-sa"
      volumes:
        - name: cloud-sa-volume
          secret:
            secretName: packet-cloud-config

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cloud-controller-manager
  namespace: kube-system
---
# comments about this clusterrole
# some of these are needed so that ccm can do its job
# others are needed because metallb needs some roles; if ccm
# tries to apply clusterrole or role permissions, and does not
# have those permissions itself, it will fail when it attempts to
# escalate privileges (as it should). All of those are in the lb/manifests.yaml
#
# for each one, we try to give the reasoning
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  name: system:cloud-controller-manager
rules:
- apiGroups:
  # reason: so ccm can create metallb-system namespace
  - ""
  resources:
  - namespaces
  verbs:
  - create
  - patch
  - update
  - list
  - get
- apiGroups:
  # reason: so ccm can create metallb:controller and metallb:speaker serviceaccount
  - ""
  resources:
  - serviceaccounts
  verbs:
  - create
  - patch
  - update
  - list
  - get
- apiGroups:
  # reason: so ccm can create metallb:speaker podsecuritypolicy
  - "policy"
  resources:
  - podsecuritypolicies
  verbs:
  - create
  - patch
  - update
  - list
  - get
- apiGroups:
  # reason: so ccm metallb-system:controller and metallb-system:speaker
  #   clusterroles and clusterrolebindings, and metallb-system:configwatcher
  #   role and rolebinding
  - "rbac.authorization.k8s.io"
  resources:
  - clusterroles
  - clusterrolebindings
  - roles
  - rolebindings
  verbs:
  - create
  - patch
  - update
  - list
  - get
- apiGroups:
  # reason: so metallb-system:speaker and metallb-system:controller clusterroles
  #    can work with these events
  - ""
  resources:
  - events
  verbs:
  - create
  - patch
  - update
- apiGroups:
  # reason: so ccm can read and update nodes and annotations
  # reason: so metallb-system:speaker can read and update nodes
  - ""
  resources:
  - nodes
  verbs:
  - '*'
- apiGroups:
  # reason: so ccm can update the status of nodes
  - ""
  resources:
  - nodes/status
  verbs:
  - patch
- apiGroups:
  # reason: so ccm can manage services for loadbalancer
  # reason: so metallb-system:controller can watch for services to create loadbalancers
  - ""
  resources:
  - services
  verbs:
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  # reason: so ccm can update the status of services for loadbalancer
  # reason: so metallb-system:controller can update the status of services
  - ""
  resources:
  - services/status
  verbs:
  - list
  - patch
  - update
  - watch
- apiGroups:
  # reason: so metallb-system:speaker can monitor and update endpoints
  - ""
  resources:
  - endpoints
  verbs:
  - create
  - get
  - list
  - watch
  - update
- apiGroups:
  # reason: so ccm can read and update configmap/metallb-system:config
  # reason: so metallb-system:config-watcher role can watch configmap/metallb-system:config
  - ""
  resources:
  - configmaps
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
- apiGroups:
  # reason: so ccm can deploy daemonset/metallb-system:speaker and deployment/metallb-system:controller
  - "apps"
  resources:
  - deployments
  - daemonsets
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
- apiGroups:
  # reason: so metallb-system:speaker can use the podsecuritypolicy
  - extensions
  resourceNames:
  - speaker
  resources:
  - podsecuritypolicies
  verbs:
  - use
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: system:cloud-controller-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:cloud-controller-manager
subjects:
- kind: ServiceAccount
  name: cloud-controller-manager
  namespace: kube-system
