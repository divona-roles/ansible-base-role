import abc
import os

import testinfra.utils.ansible_runner


testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


class Distribution(abc.ABC):

    @abc.abstractmethod
    def check_distribution(self):
        pass

    @abc.abstractmethod
    def check_shell_tools(self):
        pass

    @abc.abstractmethod
    def check_default_packages(self):
        pass

    @abc.abstractmethod
    def check_terminal_emulators(self):
        pass

    @abc.abstractmethod
    def check_network_tools(self):
        pass

    @abc.abstractmethod
    def check_modern_tools(self):
        pass

    def check_package_installed(self, host, packages):
        for pkg in packages:
            assert host.package(pkg).is_installed


class Archlinux(Distribution):

    def check_distribution(self, host):
        self.check_package_installed(host, ["pacman-contrib"])

    def check_shell_tools(self, host):
        self.check_package_installed(
            host, ["bash-completion", "tree", "tmux", "ncdu", "feh"]
        )

    def check_default_packages(self, host):
        self.check_package_installed(
            host, ["man-db", "dunst", "git", "gnupg", "tig", "unzip", "ccze"]
        )

    def check_terminal_emulators(self, host):
        self.check_package_installed(host, ["termite", "kitty", "terminator"])

    def check_network_tools(self, host):
        self.check_package_installed(
            host, [
                "dhclient", "openssh", "wget", "curl", "bind-tools", "mtr",
                "traceroute", "openbsd-netcat", "ipcalc", "nmap", "ngrep",
                "nethogs"])

    def check_modern_tools(self, host):
        self.check_package_installed(host, ["fzf", "ripgrep", "exa", "fd"])


class Centos(Distribution):

    def check_distribution(self, host):
        pass

    def check_shell_tools(self, host):
        self.check_package_installed(
            host, ["tree", "tmux", "ncdu"]
        )

    def check_default_packages(self, host):
        self.check_package_installed(
            host, ["ngrep", "git", "gnupg2", "tig", "unzip", "rsyslog"]
        )

    def check_terminal_emulators(self, host):
        self.check_package_installed(host, ["termite"])

    def check_network_tools(self, host):
        self.check_package_installed(
            host, [
                "openssh", "wget", "curl", "net-tools", "mtr", "traceroute",
                "nmap", "ngrep", "nethogs"])

    def check_modern_tools(self, host):
        pass


def _create_distribution(name):
    platform = None
    if name == "archlinux":
        platform = Archlinux()
    elif name == "centos":
        platform = Centos()
    return platform


def test_distribution_tools(host):
    distribution = _create_distribution(host.system_info.distribution)
    if distribution:
        distribution.check_distribution(host)


def test_shell_tools(host):
    distribution = _create_distribution(host.system_info.distribution)
    if distribution:
        distribution.check_shell_tools(host)


def test_default_packages(host):
    distribution = _create_distribution(host.system_info.distribution)
    if distribution:
        distribution.check_default_packages(host)
