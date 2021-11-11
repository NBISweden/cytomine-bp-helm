Cytomine Helm Chart
===================

These helm charts will setup a basic cytomine system on a kubernetes host.
This repository is under active development, and should not be used for
production systems in its current state.

## Current Limitations


### High priority

- There are very few security considerations in the system.
  - communication between services should be encrypted
  - sensitive data should be stored in secrets
  - usernames and passwords should be generated in a secure way

### Medium priority

- Most resources don't have proper liveness/readiness probes making it hard to
  tell when they become unhealthy.

- Postgres and MongoDB use Deployments where they should use StatefulSets.

### Low priority

- The nginx container could be replaced with ingress rules.

## Short kubernetes intro

Kuberenetes is a system to keep systems running modularly in "pods". A pod is
basically one-or-more docker containers running together. Kubernetes can do all
kinds of fancy things that are outside the scope of this readme, but here are
some basics to get you started!

There are a lot of resource types in kubernetes for managing different parts of
an infrastructure, but we're only using a few in this project:

- A
  [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
  defines how many pods of a certain type is desired, and tries to make sure
  that that number of pods is running and healthy. We run the cytomine docker
  containers as deployments.
- [Service](https://kubernetes.io/docs/concepts/services-networking/service/)s
  are are a way of defining network interfaces. We use services to map ports on
  the internal network to deployments.
- [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/)s
  are a way of passing configuration settings to other resources. We use them
  to set values and mount configuration files for containers.
- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
  is kubernetes system to handle communication between the internal kubernetes
  network and external networks. We use ingress to allow communication to the
  `nginx` pod.

You can interact with your kubernetes cluster using the
[kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool. Here are
some examples:

- `kubectl get pods`: lists all pods.
- `kubectl get svc`: lists all services. This will list which ports are open on
  all pods.
- `kubectl get ing`: lists all ingress resources. Ingress resources are external
  communication interfaces. In this particular system there's currently only one
  ingress, getting to port 80 in the `nginx` container.

To get details from running pods you can use the `kubectl logs` command.
ex.
```
kubectl logs cytomine-core-6db5645df7-pcd9z
```
(use `kubectl logs -f` to get auto-updating logs). Note that you need to use the
full pod name including the id parts to get logs.

To get the state of a pod from kuberentes standpoint, you can use `describe`.
ex. `kubectl describe deployment cytomine-core` instead. That is particularly
useful to get information on why a pod isn't starting, as you can't get logs
from pods that aren't running.

### Helm

[Helm](https://helm.sh/docs/intro/install) is a package manager for kubernetes,
which allows us to use templates which will be automatically filled with values.
This makes management much more convenient.

## Development environment

This development environment has been tested in minikube. Instructions for
installing minikube can be found in the
[official instructions](https://minikube.sigs.k8s.io/docs/start/).

Parts of the internal message authentication in cytomine requires that the web
client runs on a url that's reachable from other containers, making it difficult
to run on localhost. Because of this you will also need to follow the
instructions for using the
[ingress dns](https://minikube.sigs.k8s.io/docs/handbook/addons/ingress-dns)
add-on.

### Setting up the environment on OS X

Minikube doesn't seem to be superhappy on OS X, but with a few precautions it
works!

-  If you wish to use the `ingress-dns` addon (which is used in this project),
   you need to use the `hyperkit` driver (start minikube with:
   `minikube start --driver=hyperkit`). I tried using the docker driver but
   couldn't get it to work on my machine.

-  Connecting the cisco VPN client seems to mess with minikubes networking. I
   need to restart minikube every time I need to use the VPN.

-  Docker desktop also seems to conflict with minikube, so I can't run both
   docker and minikube at the same time (unless I use the docker driver, but
   then ingress-dns doesn't work).

### Setting up the environment on Ubuntu System

We need to add the `minikube-ip` as a DNS server

Update the file `/etc/resolvconf/resolv.conf.d/base` to have the following contents

```
search test
nameserver <minikube ip>
timeout 5
```

Ensure your Linux OS uses `systemcl`, run the following command

`sudo resolvconf -u`

To verify, run the following command to check if the `\etc\resolv.conf` is updated with the minikube ip.

### Installing helm

Helm is a package manager for kubernetes. It allows us to configure, install and
uninstall the entire system much easier than using kubernetes to deploy all the
individual parts. Instructions for installing helm can be found
[here](https://helm.sh/docs/intro/install).

### Creating the minikube cluster

Exactly what settings to use depends on what machine you are running on, but I
use this for my development:
```
minikube start --addons='ingress-dns','ingress','metrics-server' --cpus=3 --memory=8g
```

### Installing the helm charts

Once all the parts are in place, getting the system running is quite easy!

 1) Run `./init.sh` to generate the secrets and keys needed by the system.
 2) Take a look at the generated `values.yaml` file, to see if you wish to make
    any changes.
 3) Run `helm install cytomine .` to install the system with the `cytomine`
    prefix.

You can use the `kubectl get pods` command to see the kubernetes pods come
online. 
It takes 5~6 min to deploy all the pods. In case, there is a problem with the rabbitmq deployment. Increse the rabbitmq ram from 256Mi to 386Mi or 512Mi, if you can spare. If everything works, you should now be able to reach the system in your browser at `cytomine.test`.
