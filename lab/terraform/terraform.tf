provider "gitlab" {
    token = "${var.gitlab_token}"
}

# Configure the Sentry Provider
provider "sentry" {
    token = "${var.sentry_token}"
    base_url = "${var.sentry_base_url}"
}

# Configure the DNS Provider
provider "dns" {
  update {
    server        = "192.168.0.1"
    key_name      = "example.com."
    key_algorithm = "hmac-md5"
    key_secret    = "3VwZXJzZWNyZXQ="
  }
}

# Configure the MySQL provider
provider "mysql" {
  endpoint = "my-database.example.com:3306"
  username = "app-user"
  password = "app-password"
}

# Configure the Postgresql Provider
provider "postgresql" {
  host            = "postgres_server_ip"
  port            = 5432
  database        = "postgres"
  username        = "postgres_user"
  password        = "postgres_password"
  sslmode         = "require"
  connect_timeout = 15
}

# Configure the libvirt provider
provider "libvirt" {
    uri = "qemu:///system"
}

# Configure the Docker provider
provider "docker" {
  host = "tcp://127.0.0.1:2376/"
}

# Configure the Rancher provider
provider "rancher" {
  api_url    = "http://rancher.my-domain.com:8080"
  access_key = "${var.rancher_access_key}"
  secret_key = "${var.rancher_secret_key}"
}

provider "lxd" {
  generate_client_certificates = true
  accept_remote_certificate    = true

  lxd_remote {
    name     = "lxd-server-1"
    scheme   = "https"
    address  = "10.1.1.8"
    password = "password"
  }

  lxd_remote {
    name     = "lxd-server-2"
    scheme   = "https"
    address  = "10.1.2.8"
    password = "password"
  }
}


# Create a DNS A record set
resource "dns_a_record_set" "www" {
  # ...
}

resource "lxd_storage_pool" "pool1" {
  name = "mypool"
  driver = "dir"
  config {
    source = "/var/lib/lxd/storage-pools/mypool"
  }
}

resource "lxd_cached_image" "xenial" {
  source_remote = "ubuntu"
  source_image  = "xenial/amd64"
}

resource "lxd_network" "new_default" {
  name = "new_default"

  config {
    ipv4.address = "10.150.19.1/24"
    ipv4.nat     = "true"
    ipv6.address = "fd42:474b:622d:259d::1/64"
    ipv6.nat     = "true"
  }
}

resource "lxd_profile" "profile1" {
  name = "profile1"

  device {
    name = "eth0"
    type = "nic"

    properties {
      nictype = "bridged"
      parent  = "${lxd_network.new_default.name}"
    }
  }
}

resource "lxd_profile" "profile2" {
  name = "profile2"

  config {
    limits.cpu = 2
  }

  device {
    name = "shared"
    type = "disk"

    properties {
      source = "/tmp"
      path   = "/tmp"
    }
  }
}

resource "lxd_container" "test1" {
  name      = "test1"
  image     = "${lxd_cached_image.xenial.fingerprint}"
  ephemeral = false
  profiles  = ["${lxd_profile.profile1.name}"]

}

resource "docker_image" "ubuntu" {
  name = "ubuntu:latest"
}


# Create the private key for the registration (not the certificate)
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "libvirt_cloudinit" "commoninit" {
  name = "commoninit.iso"
  local_hostname = "node"
}

resource "libvirt_volume" "opensuse_leap" {
  name = "opensuse_leap"
  source = "http://download.opensuse.org/repositories/Cloud:/Images:/Leap_42.1/images/openSUSE-Leap-42.1-OpenStack.x86_64.qcow2"
}

# volume to attach to the "master" domain as main disk
resource "libvirt_volume" "master" {
  name           = "master.qcow2"
  base_volume_id = "${libvirt_volume.opensuse_leap.id}"
}

# volumes to attach to the "workers" domains as main disk
resource "libvirt_volume" "worker" {
  name           = "worker_${count.index}.qcow2"
  base_volume_id = "${libvirt_volume.opensuse_leap.id}"
  count          = "${var.workers_count}"
}

resource "libvirt_network" "my_network" {
  ...
  dns_forwarder {
    address = "my address"
  }
  dns_forwarder {
    address = "my address 1"
    domain = "my domain"
  }
}

resource "libvirt_domain" "domain-suse" {
  name = "suse"
  memory = "1024"
  vcpu = 1
}

resource "postgresql_database" "my_db1" {
  provider = "postgresql.pg1"
  name     = "my_db1"
}

# Create a Database
resource "mysql_database" "app" {
  name = "my_awesome_app"
}

# Set up a registration using a private key from tls_private_key
resource "acme_registration" "reg" {
  server_url      = "https://acme-staging.api.letsencrypt.org/directory"
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "nobody@example.com"
}

# Create a certificate
resource "acme_certificate" "certificate" {
  server_url                = "https://acme-staging.api.letsencrypt.org/directory"
  account_key_pem           = "${tls_private_key.private_key.private_key_pem}"
  common_name               = "www.example.com"
  subject_alternative_names = ["www2.example.com"]

  dns_challenge {
    provider = "dns"
  }

  registration_url = "${acme_registration.reg.id}"
}


# Add a project owned by the user
resource "gitlab_project" "sample_project" {
    name = "example"
}

# Add a hook to the project
resource "gitlab_project_hook" "sample_project_hook" {
    project = "${gitlab_project.sample_project.id}"
    url = "https://example.com/project_hook"
}

# Add a deploy key to the project
resource "gitlab_deploy_key" "sample_deploy_key" {
    project = "${gitlab_project.sample_project.id}"
    title = "terraform example"
    key = "ssh-rsa AAAA..."
}

# Add a group
resource "gitlab_group" "sample_group" {
    name = "example"
    path = "example"
    description = "An example group"
}

# Add a project to the group - example/example
resource "gitlab_project" "sample_group_project" {
    name = "example"
    namespace_id = "${gitlab_group.sample_group.id}"
}

data "docker_registry_image" "ubuntu" {
  name = "ubuntu:precise"
}

# Create a new docker network
resource "docker_network" "private_network" {
  name = "my_network"
}

# Creates a docker volume "shared_volume".
resource "docker_volume" "shared_volume" {
  name = "shared_volume"
}

resource "docker_image" "ubuntu" {
  name          = "${data.docker_registry_image.ubuntu.name}"
  pull_triggers = ["${data.docker_registry_image.ubuntu.sha256_digest}"]
}

resource "docker_container" "ubuntu" {
  name = "foo"
  image = "${docker_image.ubuntu.latest}"
  capabilities {
    add = ["ALL"]
    drop = ["SYS_ADMIN"]
  }
}

# Create an organization
resource "sentry_organization" "default" {
    name = "My Organization"
    slug = "my-organization"
}

# Create a team
resource "sentry_team" "default" {
    organization = "my-organization"
    name = "My Team"
    slug = "my-team"
}

# Create a project
resource "sentry_project" "default" {
    organization = "my-organization"
    team = "my-team"
    name = "Web App"
    slug = "web-app"
}

# Create a plugin
resource "sentry_plugin" "default" {
    organization = "my-organization"
    project = "web-app"
    plugin = "slack"
    config = {
      webhook = "slack://webhook"
    }
}
// Using the name parameter
data "sentry_key" "via_name" {
    organization = "${sentry_project.web_app.organization}"
    project = "${sentry_project.web_app.id}"
    name = "Default"
}

output "sentry_key_dsn_secret" {
    value = "${data.sentry_key.via_name.dsn_secret}"
}

