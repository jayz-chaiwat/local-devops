# Local DevOps


### Requirements

- [terraform](https://terraform.io) v0.12+
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) `kubectl` command
- [helm](https://helm.sh/docs/intro/install/) `helm` command
- RKE terraform provider version 1.0.1 installed locally - full install instructions [below](#installing-terraform-provider-rke)

#### Installing terraform-provider-virtual-box

##### MacOS

Download [the v1.0.1 release archive for MacOS](https://github.com/terra-farm/terraform-provider-virtualbox/releases/download/v0.1.1/terraform-provider-virtualbox_darwin_amd64),
change name and move the binary to
`~/.terraform.d/plugins/darwin_amd64/terraform-provider-virtualbox_v0.1.1`.

If curl and unzip are installed, you can use the following script:
```sh
curl -LO https://github.com/terra-farm/terraform-provider-virtualbox/releases/download/v0.1.1/terraform-provider-virtualbox_darwin_amd64 && \
chmod +x ./terraform-provider-virtualbox_darwin_amd64 && \
mkdir -p ~/.terraform.d/plugins/darwin_amd64/ && \
mv ./terraform-provider-virtualbox_darwin_amd64 ~/.terraform.d/plugins/darwin_amd64/terraform-provider-virtualbox_v0.1.1
```

##### Windows

###### 64-bit

Download [the v1.0.1 release archive for Windows (64-bit)](https://github.com/terra-farm/terraform-provider-virtualbox/releases/download/v0.1.1/terraform-provider-virtualbox_windows_amd64.exe),
change name and move the binary to
`%APPDATA%\terraform.d\plugins\windows_amd64\terraform-provider-virtualbox_v0.1.1.exe`.

You can use the following PowerShell script to perform the same steps (tested with PS version 5.1):
```
New-Item -Path $Env:APPDATA\terraform.d\plugins\windows_amd64 -ItemType Directory -Force
Invoke-WebRequest -Uri https://github.com/terra-farm/terraform-provider-virtualbox/releases/download/v0.1.1/terraform-provider-virtualbox_windows_amd64.exe -OutFile terraform-provider-virtualbox_windows_amd64.exe -UseBasicParsing
Expand-Archive terraform-provider-rke_1.0.1_windows_amd64.zip
Move-Item -Path terraform-provider-virtualbox_windows_amd64.exe -Destination $Env:APPDATA\terraform.d\plugins\windows_amd64\terraform-provider-virtualbox_v0.1.1.exe
```

#### Installing terraform-provider-rke

##### MacOS

Download [the v1.0.1 release archive for MacOS](https://github.com/rancher/terraform-provider-rke/releases/download/v1.0.1/terraform-provider-rke_1.0.1_darwin_amd64.zip),
extract the archive, and move the binary to
`~/.terraform.d/plugins/darwin_amd64/terraform-provider-rke_v1.0.1`.

If curl and unzip are installed, you can use the following script:
```sh
curl -LO https://github.com/rancher/terraform-provider-rke/releases/download/v1.0.1/terraform-provider-rke_1.0.1_darwin_amd64.zip && \
unzip terraform-provider-rke_1.0.1_darwin_amd64.zip && \
chmod +x ./terraform-provider-rke_v1.0.1 && \
mkdir -p ~/.terraform.d/plugins/darwin_amd64/ && \
mv ./terraform-provider-rke_v1.0.1 ~/.terraform.d/plugins/darwin_amd64/terraform-provider-rke_v1.0.1
rm -rf ./terraform-provider-rke_*
```

##### Windows

###### 64-bit

Download [the v1.0.1 release archive for Windows (64-bit)](https://github.com/rancher/terraform-provider-rke/releases/download/v1.0.1/terraform-provider-rke_1.0.1_windows_amd64.zip),
extract the archive, and move the executable to
`%APPDATA%\terraform.d\plugins\windows_amd64\terraform-provider-rke_v1.0.1.exe`.

You can use the following PowerShell script to perform the same steps (tested with PS version 5.1):
```
New-Item -Path $Env:APPDATA\terraform.d\plugins\windows_amd64 -ItemType Directory -Force
Invoke-WebRequest -Uri https://github.com/rancher/terraform-provider-rke/releases/download/v1.0.1/terraform-provider-rke_1.0.1_windows_amd64.zip -OutFile terraform-provider-rke_1.0.1_windows_amd64.zip -UseBasicParsing
Expand-Archive terraform-provider-rke_1.0.1_windows_amd64.zip
Move-Item -Path terraform-provider-rke_1.0.1_windows_amd64\terraform-provider-rke_v1.0.1.exe -Destination $Env:APPDATA\terraform.d\plugins\windows_amd64\terraform-provider-rke_v1.0.1.exe
Remove-Item -Path terraform-provider-rke_1.0.1_windows_amd64* -Recurse
```

###### 32-bit

Download [the v1.0.1 release archive for Windows (32-bit)](https://github.com/rancher/terraform-provider-rke/releases/download/v1.0.1/terraform-provider-rke_1.0.1_windows_386.zip),
extract the archive, and move the executable to
`%APPDATA%\terraform.d\plugins\windows_386\terraform-provider-rke_v1.0.1.exe`.

You can use the following PowerShell script to perform the same steps (tested with PS version 5.1):
```
Invoke-WebRequest -Uri https://github.com/rancher/terraform-provider-rke/releases/download/v1.0.1/terraform-provider-rke_1.0.1_windows_386.zip -OutFile terraform-provider-rke_1.0.1_windows_386.zip -UseBasicParsing
New-Item -Path $Env:APPDATA\terraform.d\plugins\windows_386 -ItemType Directory -Force
Expand-Archive terraform-provider-rke_1.0.1_windows_386.zip
Move-Item -Path terraform-provider-rke_1.0.1_windows_386\terraform-provider-rke_v1.0.1.exe -Destination $Env:APPDATA\terraform.d\plugins\windows_386\terraform-provider-rke_v1.0.1.exe
Remove-Item -Path terraform-provider-rke_1.0.1_windows_386* -Recurse
```

## How to run

Initial terraform download library

``` shell
cd tf
terraform init
```

Terraform validate and build

``` shell
terraform validate
terraform plan
```

Terraform apply (Run)

``` shell
terraform apply
```

## Setting Metrics Server for docker-desktop

``` shell
kubectl edit deployment/kubernetes-dashboard-metrics-server -n kubernetes-dashboard
```
Add two arguments and save
``` yaml
- command:
    - ...
    - --kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP
    - --kubelet-insecure-tls=true
```

## Access Kubernetes Dashboard

Now, create a proxy server that will allow you to navigate to the dashboard 
from the browser on your local machine. This will continue running until you stop the process by pressing `CTRL + C`.

```shell
$ kubectl proxy
```

You should be able to access the Kubernetes dashboard [here](http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:https/proxy/).

```plaintext
http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:https/proxy/
```

## Authenticate the dashboard

To use the Kubernetes dashboard, you need to provide an authorization token. 
Authenticating using `kubeconfig` is **not** an option. You can read more about
it in the [Kubernetes documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/#accessing-the-dashboard-ui).

Generate the token in another terminal (do not close the `kubectl proxy` process).

```shell
$ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}')

Name:         service-controller-token-46qlm
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: service-controller
              kubernetes.io/service-account.uid: dd1948f3-6234-11ea-bb3f-0a063115cf22

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6I...
```

Select "Token" on the Dashboard UI then copy and paste the entire token you 
receive into the 
[dashboard authentication screen](http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/) 
to sign in. You are now signed in to the dashboard for your Kubernetes cluster.

