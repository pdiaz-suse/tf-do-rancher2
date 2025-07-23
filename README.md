---
marp: true
theme: default
paginate: true
size: 16:9
---

# 🚀 RKE2 CIS Hardened Clusters  
### What, Why, and How We Did It

**Author:** [Your Name]  
**Date:** [Today’s Date]

---

# 🔐 Why Harden a Cluster?

- CIS = *Center for Internet Security*
- Provides a benchmark of best practices for securing Kubernetes
- Hardened clusters help:
  - Enforce least privilege
  - Meet compliance goals
  - Improve production-grade security

**🗣️ Speaker Notes:**  
> CIS hardening enables stricter rules on what runs in the cluster and how. It’s a security upgrade over the defaults — particularly valuable in production environments.

---

# 🔄 Standard vs CIS Hardened RKE2

| Feature                         | Standard RKE2 | CIS Hardened RKE2 |
|--------------------------------|---------------|-------------------|
| Pod Security Policies          | ❌ Not enforced | ✅ Enforced (restricted) |
| CIS Kernel Defaults            | ❌ No          | ✅ Yes (`protect-kernel-defaults`) |
| Admission Config File          | ❌ No          | ✅ Yes (`rancher-psact.yaml`) |
| Hardened User Data             | ❌ No          | ✅ Yes |
| Exempt System Namespaces       | ❌ No          | ✅ Yes |

**🗣️ Speaker Notes:**  
> The hardened cluster enforces pod-level policies and system configurations using Rancher’s built-in mechanisms, but only when explicitly enabled.

---

# 🔧 How We Create Clusters

### ✅ We use the **internal Rancher provisioning API**  
`/v1/provisioning.cattle.io.clusters`

---

## ⚠️ Internal API Caveats

- Not a public API
- Known as *"v2 provisioning"*
- Used internally by:
  - Rancher UI
  - Rancher Terraform Provider
  - Elemental
- Not covered by Rancher Support
- **May break between versions**

> ✅ It works now, but SUSE Rancher recommends **not depending on it long term**.

**🧭 What's coming?**  
A new public API: **RK-API**  
- More stable
- Officially supported
- Not ready until v2.13+

**🗣️ Speaker Notes:**  
> We're using this internal API with caution. The long-term goal is to migrate to RK-API, but it’s still under development.

---

# 📦 Cluster Payload Differences

### 🟥 Standard RKE2 Payload

```json
"spec": {
  "kubernetesVersion": "...",
  "rkeConfig": {
    "machineGlobalConfig": {
      "cni": "calico"
    },
    ...
  }
}



# Terraform config to launch Rancher 2

**Note: requires Terraform v0.13**

## Summary

This Terraform setup will:

- Start a droplet running `rancher/rancher` version specified in `rancher_version`
- Create an RKE1 custom cluster called `cluster_name`
- Start `count_agent_all_nodes` amount of droplets and add them to the RKE1 custom cluster with all roles
- Create an RKE2 custom cluster called `cluster_rke2_name`
- Start `count_rke2_agent_all_nodes` amount of droplets and add them to the RKE2 custom cluster with all roles
- Create an ssh_config file in the terraform module directory for connecting to the droplets

### Optional adding nodes per role
- Start `count_agent_master_nodes` amount of droplets and add them to the RKE1 custom cluster with etcd and controlplane roles
- Start `count_agent_etcd_nodes` amount of droplets and add them to the RKE1 custom cluster with etcd role
- Start `count_agent_controlplane_nodes` amount of droplets and add them to the RKE1 custom cluster with controlplane role
- Start `count_agent_worker_nodes` amount of droplets and add them to the RKE1 custom cluster with worker role
- Start `count_rke2_agent_master_nodes` amount of droplets and add them to the RKE2 custom cluster with etcd and controlplane roles
- Start `count_rke2_agent_etcd_nodes` amount of droplets and add them to the RKE2 custom cluster with etcd role
- Start `count_rke2_agent_controlplane_nodes` amount of droplets and add them to the RKE2 custom cluster with controlplane role
- Start `count_rke2_agent_worker_nodes` amount of droplets and add them to the RKE2 custom cluster with worker role

## Registry configuration

The rancher and rancher-agent images will by default be pulled from Docker Hub. You can specify an alternative registry for these two images with the `rancher_registry` option. If `rancher_registry` is specified, but the images cannot be successfully pulled from the registry, then it will fall back to Docker Hub.

## Other options

All available options/variables are described in [terraform.tfvars.example](https://github.com/superseb/tf-do-rancher2/blob/master/terraform.tfvars.example).

## Tools

You can add a tools node, which consists of some software that can be used for Rancher tooling like notifiers and logging. See below for more information on the current software included:

Note: replace PRIVATE_IP or PUBLIC_IP with tools-private-ip or tools-public-ip

| Software  | Endpoint | View command |
| ------------- | ------------- | ---------- |
| ElasticSearch | http://PRIVATE_IP:9200 | `docker logs elasticsearch` |
| Kibana  | http://PUBLIC_IP:5601  | `docker logs kibana` |
| SMTP (Mailhog) | http://PRIVATE_IP:1025 | `docker logs mailhog` |
| Echo server for HTTP requests | http://PRIVATE_IP:8080 | `docker logs echo` |
| Syslog (Syslog-NG) | http://PRIVATE_IP:514 | `docker logs syslog` |
| Fluentd | http://PRIVATE_IP:24224 | `docker logs fluentd` |

## SSH Config

**Note: set the appropriate users for the images in the terraform variables, default is `root`**

You can use the use the auto-generated ssh_config file to connect to the droplets by droplet name, e.g. `ssh <prefix>-rancheragent-all-0` or `ssh <prefix>-rancherserver` etc. To do so, you have two options:

1. Add an `Include` directive at the top of the SSH config file in your home directory (`~/.ssh/config`) to include the ssh_config file at the location you have checked out the this repository, e.g. `Include ~/git/tf-do-rancher2/ssh_config`.

2. Specify the ssh_config file when invoking `ssh` via the `-F` option, e.g. `ssh -F ~/git/tf-do-rancher2/ssh_config <host>`.

## How to use

- Clone this repository
- Move the file `terraform.tfvars.example` to `terraform.tfvars` and edit (see inline explanation)
- Run `terraform apply`
