
## Step 1. Run `bash setup-prerequisites.sh`

```bash
govind@thinkpad:~/projects/local-aws-kit$ bash setup-prerequisites.sh 
🔍 Detecting Host Operating System...
💻 System Identified: linux (amd64)
⚙️ Downloading and installing KinD binary...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    86  100    86    0     0    105      0 --:--:-- --:--:-- --:--:--   105
100 10.0M  100 10.0M    0     0  2416k      0  0:00:04  0:00:04 --:--:-- 3039k
[sudo] password for govind: 
⚙️ Downloading and installing kubectl binary...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 56.8M  100 56.8M    0     0  4104k      0  0:00:14  0:00:14 --:--:-- 4175k
🐳 Note: Ensure Docker Engine is installed and your user is part of the 'docker' group.
🚀 Validating Tool Installations...
✅ KinD Version: kind v0.33.0-alpha+0d477639ed54df go1.26.7 linux/amd64
✅ Kubectl Version:   gitVersion: v1.36.4
🎉 Prerequisites successfully configured! You can now execute ./setup.sh safely.

```

## Step 2. Switch docker context back to native linux dameon socket

Run this command to force-switch your context back to the native Linux daemon socket (if you have Docker CE installed alongside it), or restart Docker Desktop completely:

```bash
docker context use default

```

## Step 3. Run `bash steup.sh`

```bash
govind@winsoft-244:~/projects/local-aws-kit$ bash setup.sh
🚀 Commencing unified environment orchestration...
🔹 [1/4] Booting Core Platform Cloud Engine (Stack 1)...
[+] up 2/2
 ✔ Container floci-emulator        Healthy                                                                                                                               0.5s
 ✔ Container aws-local-web-console Running                                                                                                                               0.0s
🔹 [2/4] Constructing High-Fidelity KinD Cluster Matrix...
⚠️ KinD cluster 'local-eks' already exists. Skipping creation.
🔹 [3/4] Blending Virtual Kubernetes Nodes into the Host AWS Virtual Switch...
🔹 [3.5/4] Caching and Importing Ingress Images via Tar Archive...
v1.12.0: Pulling from ingress-nginx/controller
Digest: sha256:e6b8de175acda6ca913891f0f727bca4527e797d52688cbe9fec9040d6f6b6fa
Status: Image is up to date for registry.k8s.io/ingress-nginx/controller:v1.12.0
registry.k8s.io/ingress-nginx/controller:v1.12.0

What's next:
    View a summary of image vulnerabilities and recommendations → docker scout quickview registry.k8s.io/ingress-nginx/controller:v1.12.0
v1.4.4: Pulling from ingress-nginx/kube-webhook-certgen
Digest: sha256:a9f03b34a3cbfbb26d103a14046ab2c5130a80c3d69d526ff8063d2b37b9fd3f
Status: Image is up to date for registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.4
registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.4

What's next:
    View a summary of image vulnerabilities and recommendations → docker scout quickview registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.4
Importing images into local-eks-control-plane...
Successfully copied 369MB (transferred 369MB) to local-eks-control-plane:/ingress-images.tar
registry.k8s.io/ingress nginx/controller        saved
application/vnd.oci.image.manifest.v1+json sha256:e521fd5a27e3cfb8c8bdfdcee29e3aed2101af7a9cba8c9b7e8e10b06b0c80a9
Importing       elapsed: 15.5s  total:   0.0 B  (0.0 B/s)
registry.k8s.io/ingress nginx/controller        saved
registry.k8s.io/ingress nginx/kube webho        saved
application/vnd.oci.image.manifest.v1+json sha256:e521fd5a27e3cfb8c8bdfdcee29e3aed2101af7a9cba8c9b7e8e10b06b0c80a9
application/vnd.oci.image.manifest.v1+json sha256:2323e726a8e5fea30b3c24dd96578acc882c0952c7eed433888f826f8c6f9178
Importing       elapsed: 15.5s  total:   0.0 B  (0.0 B/s)
Importing images into local-eks-worker...
Successfully copied 369MB (transferred 369MB) to local-eks-worker:/ingress-images.tar
registry.k8s.io/ingress nginx/controller        saved
application/vnd.oci.image.manifest.v1+json sha256:e521fd5a27e3cfb8c8bdfdcee29e3aed2101af7a9cba8c9b7e8e10b06b0c80a9
Importing       elapsed: 6.1 s  total:   0.0 B  (0.0 B/s)
registry.k8s.io/ingress nginx/controller        saved
registry.k8s.io/ingress nginx/kube webho        saved
application/vnd.oci.image.manifest.v1+json sha256:e521fd5a27e3cfb8c8bdfdcee29e3aed2101af7a9cba8c9b7e8e10b06b0c80a9
application/vnd.oci.image.manifest.v1+json sha256:2323e726a8e5fea30b3c24dd96578acc882c0952c7eed433888f826f8c6f9178
Importing       elapsed: 6.1 s  total:   0.0 B  (0.0 B/s)
Importing images into local-eks-worker2...
Successfully copied 369MB (transferred 369MB) to local-eks-worker2:/ingress-images.tar
registry.k8s.io/ingress nginx/controller        saved
application/vnd.oci.image.manifest.v1+json sha256:e521fd5a27e3cfb8c8bdfdcee29e3aed2101af7a9cba8c9b7e8e10b06b0c80a9
Importing       elapsed: 6.8 s  total:   0.0 B  (0.0 B/s)
registry.k8s.io/ingress nginx/controller        saved
registry.k8s.io/ingress nginx/kube webho        saved
application/vnd.oci.image.manifest.v1+json sha256:e521fd5a27e3cfb8c8bdfdcee29e3aed2101af7a9cba8c9b7e8e10b06b0c80a9
application/vnd.oci.image.manifest.v1+json sha256:2323e726a8e5fea30b3c24dd96578acc882c0952c7eed433888f826f8c6f9178
Importing       elapsed: 6.9 s  total:   0.0 B  (0.0 B/s)
🔹 [4/4] Deploying NGINX Ingress Routing Platform inside KinD...
namespace/ingress-nginx created
serviceaccount/ingress-nginx created
serviceaccount/ingress-nginx-admission created
role.rbac.authorization.k8s.io/ingress-nginx created
role.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrole.rbac.authorization.k8s.io/ingress-nginx created
clusterrole.rbac.authorization.k8s.io/ingress-nginx-admission created
rolebinding.rbac.authorization.k8s.io/ingress-nginx created
rolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
configmap/ingress-nginx-controller created
service/ingress-nginx-controller created
service/ingress-nginx-controller-admission created
deployment.apps/ingress-nginx-controller created
job.batch/ingress-nginx-admission-create created
job.batch/ingress-nginx-admission-patch created
ingressclass.networking.k8s.io/nginx created
validatingwebhookconfiguration.admissionregistration.k8s.io/ingress-nginx-admission created
⏳ Waiting for Ingress controller readiness parameters...
pod/ingress-nginx-controller-7c444fc6cf-9xvng condition met
✨ Base Environment is operational! Run Stack 2 to apply your infrastructure blueprints.
```

## Step 4. **Check if the KinD cluster nodes are healthy:**

```bash
kind get clusters
docker ps --filter "name=local-eks"

```

```bash
govind@winsoft-244:~/projects/local-aws-kit$ kind get clusters
local-eks
govind@winsoft-244:~/projects/local-aws-kit$ docker ps --filter "name=local-eks"
CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS          PORTS                                                                 NAMES
ee1d787572c7   kindest/node:v1.36.1   "/usr/local/bin/entr…"   18 minutes ago   Up 18 minutes                                                                         local-eks-worker2
718e2e818270   kindest/node:v1.36.1   "/usr/local/bin/entr…"   18 minutes ago   Up 18 minutes   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 127.0.0.1:35977->6443/tcp   local-eks-control-plane
2702f16e9bed   kindest/node:v1.36.1   "/usr/local/bin/entr…"   18 minutes ago   Up 18 minutes                                                                         local-eks-worker
govind@winsoft-244:~/projects/local-aws-kit$ 
```

## Step 5. verify cluster

```bash
govind@winsoft-244:~/projects/local-aws-kit$ ./verify-cluster.sh 
🔍 Starting local environment verification diagnostics...
======================================================

🔹 [1/4] Checking Floci Emulator & Web Console...
✅ Container 'floci-emulator' is running.
✅ Floci endpoint is responding on http://localhost:4566.
✅ Container 'aws-local-web-console' is running.

🔹 [2/4] Checking KinD Kubernetes Cluster ('local-eks')...
✅ KinD cluster 'local-eks' exists.
✅ Active kubectl context is correctly set to 'kind-local-eks'.
--- Cluster Nodes Status ---
NAME                      STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION                    CONTAINER-RUNTIME
local-eks-control-plane   Ready    control-plane   30m   v1.36.1   172.24.0.3    <none>        Debian GNU/Linux 13 (trixie)   7.0.11-76070011-generic (amd64)   containerd://2.3.1
local-eks-worker          Ready    <none>          30m   v1.36.1   172.24.0.2    <none>        Debian GNU/Linux 13 (trixie)   7.0.11-76070011-generic (amd64)   containerd://2.3.1
local-eks-worker2         Ready    <none>          30m   v1.36.1   172.24.0.4    <none>        Debian GNU/Linux 13 (trixie)   7.0.11-76070011-generic (amd64)   containerd://2.3.1

🔹 [3/4] Checking Virtual Network Switch Integration ('local-aws-net')...
✅ Docker network 'local-aws-net' exists.
template parsing error: template: :1: unexpected ".2" in operand
   -> ⚠️ Node 'local-eks-control-plane' is NOT attached to 'local-aws-net'.
template parsing error: template: :1: unexpected ".2" in operand
   -> ⚠️ Node 'local-eks-worker' is NOT attached to 'local-aws-net'.
template parsing error: template: :1: unexpected ".2" in operand
   -> ⚠️ Node 'local-eks-worker2' is NOT attached to 'local-aws-net'.

🔹 [4/4] Checking NGINX Ingress Controller & System Pods...
✅ Namespace 'ingress-nginx' exists.
--- Ingress Pods Status ---
NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-7c444fc6cf-9xvng   1/1     Running   0          26m
======================================================
✨ Verification suite completed successfully!
```
