# Steps to install K3s on Mac

## K3s setup
Install multipass with brew:
```
brew install --cask multipass
``` 
## Spin up a new VM by specifying memory and disk space
```
multipass launch --name k3s --mem 4G --disk 40G
```

## See VM details
```
multipass info k3s
```

## We can even mount Mac directories on the VM
```
multipass mount ~/test/k8s k3s:~/k8s
```

## Install k3s by running the install script inside the VM
```
multipass shell k3s
```

## K3s provides an installation script that is a convenient way to install it as a service:
```
curl -sfL https://get.k3s.io | sh -
```
This will setup a k3s cluster on the VM. We can use kubectl and deploy applications on this cluster.

By default, k3s config file will be located at /etc/rancher/k3s/k3s.yaml

## Find out the IP of the VM & k8s token so that we can spin up a new VM and add it to this cluster
```
multipass exec k3s sudo cat /var/lib/rancher/k3s/server/node-token
multipass info k3s | grep -i ip
```

## Launch a worker node
```
multipass launch --name k3s-worker --memory 2G --disk 20G
multipass shell k3s-worker
```

## To install additional agent nodes and add them to the cluster, run the installation script with the K3S_URL and K3S_TOKEN environment variables. Here is an example showing how to join an agent:
```
curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -
```
 ## Verify if the node is added correctly from k3s VM
 Switch back to the control plane by running ```multipass shell k3s``` and run ```kubectl get nodes```

 ------------------------------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------
 ## K3s VM
- Run ```systemctl status k3s.service``` to get the k3s systemd service status.
- Notice the CGroup in the output
```
CGroup: /system.slice/k3s.service
        ├─11 "/usr/local/bin/k3s server"
        ├─1892 "containerd "
```

- Next, look at the service file. Systemd uses unit files like this. When we start our system, systemd is the first process that gets started and everything spawns from there. Here, we have a systemd k3s service (EnvironmentFile=-/etc/systemd/system/k3s.service.env) under [Service] section which then in turn is going to start the ```/usr/local/bin/k3s``` binary
```
vim /etc/systemd/system/k3s.service
```
```
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
Wants=network-online.target
After=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=notify
EnvironmentFile=-/etc/default/%N
EnvironmentFile=-/etc/sysconfig/%N
EnvironmentFile=-/etc/systemd/system/k3s.service.env
KillMode=process
Delegate=yes
User=root
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/k3s \
    server \
```
- So, if we refer back to the k3s service status output, in the cgroup section we see it has created a cgroup system slice k3s service, and from here it has spawned a few subprocesses. On executing the ```pstree``` command, we see the output:
```
ubuntu@k3s:~$ pstree
systemd─┬─ModemManager───3*[{ModemManager}]
        ├─2*[agetty]
        ├─containerd-shim─┬─coredns───8*[{coredns}]
        │                 ├─pause
        │                 └─12*[{containerd-shim}]
        ├─containerd-shim─┬─metrics-server───6*[{metrics-server}]
        │                 ├─pause
        │                 └─12*[{containerd-shim}]
        ├─containerd-shim─┬─local-path-prov───6*[{local-path-prov}]
        │                 ├─pause
        │                 └─12*[{containerd-shim}]
        ├─containerd-shim─┬─2*[entry]
        │                 ├─pause
        │                 └─13*[{containerd-shim}]
        ├─containerd-shim─┬─pause
        │                 ├─traefik───6*[{traefik}]
        │                 └─12*[{containerd-shim}]
```
We see a containerd-shim structure, we have coredns, metrics-server etc., which we know that are the name of the pods.
This shows that k3s acts as the interface to the containerd type Container Runtime Interface.

On executing ```sudo crictl ps```, we see that the actual containers are running. As we know that K8s Pods are a collection of containers. So, when we run a K8s pod on a K3s installation, it actually starts up these containers in the container runtime, in this case containerd. So, it's basically a wrapper around containerd containers.