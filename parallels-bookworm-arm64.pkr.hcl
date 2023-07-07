packer {
    /*
        Note: Packer version 1.5.0 introduced support for HCL2 templates as a beta feature. As of version 1.7.0, HCL2 support is no longer in beta and is the preferred way to write Packer configuration(s).
    */
    required_version = ">= 1.8.0"
    required_plugins {
        parallels = {
            version = ">= 1.0.1"
            source  = "github.com/hashicorp/parallels"
        }
    }
}

variables {
    debug = false
}

locals {
    _boot_command     = [
        "<esc><esc><esc>e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", /* remove " --- quiet" */
        "auto=true ",
        "lowmem/low=true ",
        /* HACK: set the hostname and domain name in advance of the preseed because by the time it happens, the apropriate preseed directives are not honored */
        "hostname=vagrant ",
        "domain=local ",
        "preseed/url=http://{{.HTTPIP}}:{{.HTTPPort}}/preseed.cfg ",
        "<wait><f10>"
    ]
    _headless         = "${!var.debug}"
    _vm_name          = "bookworm-arm64-${formatdate("YYYYMMDDhhmmss", timestamp())}"
    _iso_urls         = [
        "${abspath(path.root)}/cache/debian-12.0.0-arm64-netinst.iso",
        "https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/debian-12.0.0-arm64-netinst.iso",
        "http://cdimage.debian.org/cdimage/archive/12.0.0/arm64/iso-cd/debian-12.0.0-arm64-netinst.iso",
    ]
    _preseed_file     = "${abspath(path.root)}/preseed.cfg"
    _vagrantfile      = "${abspath(path.root)}/Vagrantfile"
    _output           = "${abspath(path.root)}/dist/{{.Provider}}/{{.BuildName}}.box"
    _output_directory = "${abspath(path.root)}/dist/sandbox"
}

source "parallels-iso" "bookworm-arm64" {
    boot_command         = "${local._boot_command}"
    boot_wait            = "3s"
    cpus                 = 1
    disk_size            = 8192
    guest_os_type        = "debian"
    http_content         = {
        "/preseed.cfg" = file(local._preseed_file)
    }
    iso_checksum         = "file:https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/SHA256SUMS"
    iso_target_path      = "${abspath(path.root)}/cache/debian-12.0.0-arm64-netinst.iso"
    iso_urls             = "${local._iso_urls}"
    memory               = 1024
    output_directory     = "${local._output_directory}"
    shutdown_command     = "echo 'vagrant' | sudo -S /sbin/shutdown -hP now"
    sound                = false
    ssh_password         = "vagrant"
    ssh_port             = 22
    ssh_username         = "vagrant"
    ssh_wait_timeout     = "3600s"
    vm_name              = "${local._vm_name}"
    parallels_tools_flavor = "lin-arm"
    parallels_tools_mode = "upload"
    parallels_tools_guest_path = "/tmp/prltools.iso"
}

build {
    sources = [
        "sources.parallels-iso.bookworm-arm64"
    ]

    provisioner "shell" {
        script = "provision.sh"
        execute_command = "chmod +x '{{.Path}}'; sudo -S env {{.Vars}} '{{.Path}}'"
    }

    post-processor "vagrant" {
        compression_level              = 9
        keep_input_artifact            = false
        output                         = "${local._output}"
        vagrantfile_template           = "${local._vagrantfile}"
        vagrantfile_template_generated = true
    }
}
