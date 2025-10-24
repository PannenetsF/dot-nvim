```bash
apt-get install build-essential -y
GCC_MAJOR=$(gcc -dumpfullversion -dumpversion | cut -d. -f1)
apt install libgccjit-${GCC_MAJOR}-dev -y
apt install tmux wget zsh -y
apt install gnutls-bin libgnutls28-dev -y
apt install libtool libtool-bin -y
apt install pkg-config -y
apt install autoconf texinfo -y
apt install software-properties-common -y
apt-get install libcurl4-gnutls-dev -y
apt-get install gettext -y
apt-get install tmux -y

cd /usr/src
wget https://www.kernel.org/pub/software/scm/git/git-2.48.0.tar.gz
tar xzf git-2.48.0.tar.gz
cd git-2.48.0
make prefix=/usr/local/ NO_TCLTK=1 all -j64
make prefix=/usr/local/ NO_TCLTK=1 install
apt remove git -y

```


```python
import os

ALL_CMD = []


def cli_exec(cmd):
    if isinstance(cmd, list):
        # make sure the commands are exec in ONE session for variable setting
        cmd = " && ".join(cmd)
    print(f"[!!exec] {cmd}")
    # return os.system(cmd)
    ALL_CMD.append(cmd)


def host_exec(cmd):
    if isinstance(cmd, list):
        cmd = " && ".join(cmd)
    else:
        raise RuntimeError("host_exec only support list")
    print(f"[!!exec] {cmd}")
    return os.system(cmd)


class Platform:
    def __init__(self):
        self.name = self.check_platform()

    def check_platform(self):
        if os.uname().sysname == "Darwin":
            return "mac"
        # check debian/ubuntu or redhat/fedora/centos
        elif os.path.exists("/usr/bin/apt"):
            return "debian"
        elif os.path.exists("/usr/bin/yum"):
            return "redhat"
        else:
            raise RuntimeError(f"Unsupported Linux package manager for uname {os.uname()}")

    def prepare(self):
        if self.name == "mac":
            cli_exec("brew update")
        elif self.name == "debian":
            cli_exec("apt update")
        elif self.name == "redhat":
            cli_exec("yum update")
        else:
            raise RuntimeError("Unsupported Linux package manager")


class Application:
    def __init__(self, mac, linux_debian, linux_redhat, other=None):
        self.platform = Platform()
        self.mac_install = mac
        self.linux_install_debian = linux_debian
        self.linux_install_redhat = linux_redhat
        self.other_install = other

    @classmethod
    def parse(cls, mac, linux_debian, linux_redhat, other=None):
        return cls(mac, linux_debian, linux_redhat, other)

    def exec(self, platform):
        if platform == "mac" and self.mac_install is not None:
            cli_exec(self.mac_install)
        elif platform == "redhat" and self.linux_install_redhat is not None:
            cli_exec(self.linux_install_redhat)
        elif platform == "debian" and self.linux_install_debian is not None:
            cli_exec(self.linux_install_debian)
        elif self.other_install is not None:
            cli_exec(self.other_install)
        else:
            raise RuntimeError(f"Unsupported application {self.name}")


ALL_APP_CONFIGS = [
    (
        "proxy",
        None,
        None,
        None,
        [
            "export http_proxy=",
            "export https_proxy=",
        ],
    ),
    ("lua", "brew install lua", "apt install lua5.2 -yy", "yum install lua -yy"),
    ("node", "brew install node", [
        """curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash""",
        """ \. "$HOME/.nvm/nvm.sh" """,
        """nvm install 22""",
    ], "yum install node -yy"),
    (
        "nvim",
        "brew install neovim",
        None,
        None,
        [
            """curl -LO https://github.com/neovim/neovim-releases/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz""",
            """rm -rf /opt/nvim /usr/local/bin/nvim""",
            """tar -C /opt -xzf nvim-linux-x86_64.tar.gz""",
            """ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim""",
        ],
    ),
    (
        "lazygit",
        "brew install lazygit",
        None,
        None,
        [
            """LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')""",  # noqa
            '''curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"''',  # noqa
            """tar xf lazygit.tar.gz lazygit""",
            """install lazygit -D -t /usr/local/bin/""",
        ],
    ),
    ("git", "brew install git", "apt install git -yy", "yum install git -yy"),
    ("curl", "brew install curl", "apt install curl -yy", "yum install curl -yy"),
    ("wget", "brew install wget", "apt install wget -yy", "yum install wget -yy"),
    ("zsh", "brew install zsh", "apt install zsh -yy", "yum install zsh -yy"),
    ("tmux", "brew install tmux", "apt install tmux -yy", "yum install tmux -yy"),
    ("ripgrep", "brew install ripgrep", "apt install ripgrep -yy", "yum install ripgrep -yy"),
    ("fzf", "brew install fzf", "apt install fzf -yy", "yum install fzf -yy"),
    ("pynvim", None, None, None, "pip install -U pynvim"),
    ("python-lsp-server", None, None, None, "pip install -U python-lsp-server[all]"),
    ("pylsp-mypy", None, None, None, "pip install -U pylsp-mypy"),
    ("python-lsp-isort", None, None, None, "pip install -U python-lsp-isort"),
    ("python-lsp-black", None, None, None, "pip install -U python-lsp-black"),
    ("vim-language-server", None, None, None, "npm install -g vim-language-server"),
    ("im-select", ["brew tap laishulu/homebrew", "brew install macism"], ["ls"], ["ls"]),
]
ALL_APPS = {}

platform = Platform()
platform.prepare()

for app in ALL_APP_CONFIGS:
    name = app[0]
    mac_install = app[1]
    linux_install_debian = app[2]
    linux_install_redhat = app[3]
    other_install = app[4] if len(app) > 4 else None
    ALL_APPS[name] = Application.parse(mac_install, linux_install_debian, linux_install_redhat, other_install)

for app_name, app in ALL_APPS.items():
    app.exec(platform.name)

host_exec(ALL_CMD)
```
