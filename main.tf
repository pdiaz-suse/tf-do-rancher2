# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_account" "do-account" {
}

resource "digitalocean_vpc" "droplets-network" {
  name   = "${var.prefix}-droplets-vpc"
  region = var.region_server
}

resource "digitalocean_droplet" "rancherserver" {
  count    = "1"
  image    = var.image_server
  name     = "${var.prefix}-rancherserver"
  vpc_uuid = digitalocean_vpc.droplets-network.id
  region   = var.region_server
  size     = var.size
  user_data = templatefile("files/userdata_server", {
    admin_password          = var.admin_password
    cluster_name            = var.cluster_name
    cluster_rke2_name       = var.cluster_rke2_name
    docker_version_server   = var.docker_version_server
    docker_root             = var.docker_root
    rancher_version         = var.rancher_version
    rancher_registry        = var.rancher_registry
    rancher_args            = var.rancher_args
    k8s_version             = var.k8s_version
    k8s_rke2_version        = var.k8s_rke2_version
    audit_level             = var.audit_level
    kernel_nf_conntrack_max = var.kernel_nf_conntrack_max
  })
  ssh_keys = var.ssh_keys
  tags     = [join("", ["user:", replace(split("@", data.digitalocean_account.do-account.email)[0], ".", "-")])]
}

resource "digitalocean_droplet" "rancheragent-all" {
  count    = var.count_agent_all_nodes
  image    = var.image_agent
  name     = "${var.prefix}-rancheragent-all-${count.index}"
  vpc_uuid = digitalocean_vpc.droplets-network.id
  region   = var.region_agent
  size     = var.all_size
  user_data = templatefile("files/userdata_agent", {
    admin_password       = var.admin_password
    cluster_name         = var.cluster_name
    docker_version_agent = var.docker_version_agent
    docker_root          = var.docker_root
    rancher_registry     = var.rancher_registry
    rancher_version      = var.rancher_version
    server_address       = digitalocean_droplet.rancherserver[0].ipv4_address
  })
  ssh_keys = var.ssh_keys
  tags     = [join("", ["user:", replace(split("@", data.digitalocean_account.do-account.email)[0], ".", "-")])]
}

resource "digitalocean_droplet" "rancheragent-etcd" {
  count    = var.count_agent_etcd_nodes
  image    = var.image_agent
  name     = "${var.prefix}-rancheragent-etcd-${count.index}"
  vpc_uuid = digitalocean_vpc.droplets-network.id
  region   = var.region_agent
  size     = var.etcd_size
  user_data = templatefile("files/userdata_agent", {
    admin_password       = var.admin_password
    cluster_name         = var.cluster_name
    docker_version_agent = var.docker_version_agent
    docker_root          = var.docker_root
    rancher_registry     = var.rancher_registry
    rancher_version      = var.rancher_version
    server_address       = digitalocean_droplet.rancherserver[0].ipv4_address
  })
  ssh_keys = var.ssh_keys
  tags     = [join("", ["user:", replace(split("@", data.digitalocean_account.do-account.email)[0], ".", "-")])]
}

resource "digitalocean_droplet" "rancheragent-controlplane" {
  count    = var.count_agent_controlplane_nodes
  image    = var.image_agent
  name     = "${var.prefix}-rancheragent-controlplane-${count.index}"
  vpc_uuid = digitalocean_vpc.droplets-network.id
  region   = var.region_agent
  size     = var.controlplane_size
  user_data = templatefile("files/userdata_agent", {
    admin_password       = var.admin_password
    cluster_name         = var.cluster_name
    docker_version_agent = var.docker_version_agent
    docker_root          = var.docker_root
    rancher_registry     = var.rancher_registry
    rancher_version      = var.rancher_version
    server_address       = digitalocean_droplet.rancherserver[0].ipv4_address
  })
  ssh_keys = var.ssh_keys
  tags     = [join("", ["user:", replace(split("@", data.digitalocean_account.do-account.email)[0], ".", "-")])]
}

resource "digitalocean_droplet" "rancheragent-worker" {
  count    = var.count_agent_worker_nodes
  image    = var.image_agent
  name     = "${var.prefix}-rancheragent-worker-${count.index}"
  vpc_uuid = digitalocean_vpc.droplets-network.id
  region   = var.region_agent
  size     = var.worker_size
  user_data = templatefile("files/userdata_agent", {
    admin_password       = var.admin_password
    cluster_name         = var.cluster_name
    docker_version_agent = var.docker_version_agent
    docker_root          = var.docker_root
    rancher_registry     = var.rancher_registry
    rancher_version      = var.rancher_version
    server_address       = digitalocean_droplet.rancherserver[0].ipv4_address
  })
  ssh_keys = var.ssh_keys
  tags     = [join("", ["user:", replace(split("@", data.digitalocean_account.do-account.email)[0], ".", "-")])]
}

resource "digitalocean_droplet" "rancher-tools" {
  count    = var.count_tools_nodes
  image    = var.image_tools
  name     = "${var.prefix}-rancher-tools-${count.index}"
  vpc_uuid = digitalocean_vpc.droplets-network.id
  region   = var.region_agent
  size     = var.tools_size
  user_data = templatefile("files/userdata_tools", {
    docker_version_agent = var.docker_version_agent
  })
  ssh_keys = var.ssh_keys
  tags     = [join("", ["user:", replace(split("@", data.digitalocean_account.do-account.email)[0], ".", "-")])]
}

resource "digitalocean_droplet" "rancheragent-rke2-all" {
  count    = var.count_rke2_agent_all_nodes
  image    = var.image_agent
  name     = "${var.prefix}-rancheragent-rke2-all-${count.index}"
  vpc_uuid = digitalocean_vpc.droplets-network.id
  region   = var.region_agent
  size     = var.all_size
  user_data = templatefile("files/userdata_rke2_agent", {
    admin_password       = var.admin_password
    cluster_rke2_name    = var.cluster_rke2_name
    docker_version_agent = var.docker_version_agent
    docker_root          = var.docker_root
    rancher_version      = var.rancher_version
    server_address       = digitalocean_droplet.rancherserver[0].ipv4_address
  })
  ssh_keys = var.ssh_keys
  tags     = [join("", ["user:", replace(split("@", data.digitalocean_account.do-account.email)[0], ".", "-")])]
}

resource "digitalocean_droplet" "rancheragent-rke2-etcd" {
  count    = var.count_rke2_agent_etcd_nodes
  image    = var.image_agent
  name     = "${var.prefix}-rancheragent-rke2-etcd-${count.index}"
  vpc_uuid = digitalocean_vpc.droplets-network.id
  region   = var.region_agent
  size     = var.etcd_size
  user_data = templatefile("files/userdata_rke2_agent", {
    admin_password       = var.admin_password
    cluster_rke2_name    = var.cluster_rke2_name
    docker_version_agent = var.docker_version_agent
    docker_root          = var.docker_root
    rancher_version      = var.rancher_version
    server_address       = digitalocean_droplet.rancherserver[0].ipv4_address
  })
  ssh_keys = var.ssh_keys
  tags     = [join("", ["user:", replace(split("@", data.digitalocean_account.do-account.email)[0], ".", "-")])]
}

resource "digitalocean_droplet" "rancheragent-rke2-controlplane" {
  count    = var.count_rke2_agent_controlplane_nodes
  image    = var.image_agent
  name     = "${var.prefix}-rancheragent-rke2-controlplane-${count.index}"
  vpc_uuid = digitalocean_vpc.droplets-network.id
  region   = var.region_agent
  size     = var.controlplane_size
  user_data = templatefile("files/userdata_rke2_agent", {
    admin_password       = var.admin_password
    cluster_rke2_name    = var.cluster_rke2_name
    docker_version_agent = var.docker_version_agent
    docker_root          = var.docker_root
    rancher_version      = var.rancher_version
    server_address       = digitalocean_droplet.rancherserver[0].ipv4_address
  })
  ssh_keys = var.ssh_keys
  tags     = [join("", ["user:", replace(split("@", data.digitalocean_account.do-account.email)[0], ".", "-")])]
}

resource "digitalocean_droplet" "rancheragent-rke2-worker" {
  count    = var.count_rke2_agent_worker_nodes
  image    = var.image_agent
  name     = "${var.prefix}-rancheragent-rke2-worker-${count.index}"
  vpc_uuid = digitalocean_vpc.droplets-network.id
  region   = var.region_agent
  size     = var.worker_size
  user_data = templatefile("files/userdata_rke2_agent", {
    admin_password       = var.admin_password
    cluster_rke2_name    = var.cluster_rke2_name
    docker_version_agent = var.docker_version_agent
    docker_root          = var.docker_root
    rancher_version      = var.rancher_version
    server_address       = digitalocean_droplet.rancherserver[0].ipv4_address
  })
  ssh_keys = var.ssh_keys
  tags     = [join("", ["user:", replace(split("@", data.digitalocean_account.do-account.email)[0], ".", "-")])]
}

resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/files/ssh_config_template", {
    prefix                    = var.prefix
    rancherserver             = digitalocean_droplet.rancherserver[0].ipv4_address,
    rancheragent-all          = [for node in digitalocean_droplet.rancheragent-all : node.ipv4_address],
    rancheragent-etcd         = [for node in digitalocean_droplet.rancheragent-etcd : node.ipv4_address],
    rancheragent-controlplane = [for node in digitalocean_droplet.rancheragent-controlplane : node.ipv4_address],
    rancheragent-worker       = [for node in digitalocean_droplet.rancheragent-worker : node.ipv4_address],
    rancher-tools             = [for node in digitalocean_droplet.rancher-tools : node.ipv4_address],
    user-server               = var.user_server,
    user-agent                = var.user_agent,
    user-tools                = var.user_tools
  })
  filename = "${path.module}/ssh_config"
}

output "rancher-url" {
  value = ["https://${digitalocean_droplet.rancherserver[0].ipv4_address}"]
}

output "tools-private-ip" {
  value = [digitalocean_droplet.rancher-tools.*.ipv4_address_private]
}

output "tools-public-ip" {
  value = [digitalocean_droplet.rancher-tools.*.ipv4_address]
}
