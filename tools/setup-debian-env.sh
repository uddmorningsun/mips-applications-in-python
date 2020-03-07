#!/bin/bash

set -x
set -e
set -o pipefail

log_error()
{
    echo
    echo -e "\e[1;31m[$(date '+%F %T.%3N') ERROR]: $* \e[0m" >&2
}

check_uid()
{
    [[ $(id -u) -eq 0 ]] || {
        log_error "only support run as root user ..."
        return 1
    }
}

install_package()
{
    sed -i -e 's/deb.debian.org/mirrors.163.com/g' -e 's/security.debian.org/mirrors.163.com/g' /etc/apt/sources.list
    [[ "$VERSION_ID" =~ ^(9|10)$ ]] && dpkg --add-architecture mips64el
    apt-get update

    DEBIAN_FRONTEND=noninteractive apt-get install -y tig cmake-curses-gui cmake curl vim less git python3-venv rsync locales gdb python3-dbg \
    wget unzip zip bzip2 build-essential subversion python3-dev ssh eatmydata ccache apt-file tmux unar autojump bash-completion

    if [[ "$VERSION_ID" =~ ^(9|10)$ ]]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y binutils-mips64el-linux-gnuabi64 gcc-mips64el-linux-gnuabi64 gfortran-mips64el-linux-gnuabi64 \
        g++-mips64el-linux-gnuabi64 libpython3-all-dev:mips64el libc6-dev:mips64el
    fi

    apt-file update
}

setup_configuration()
{
    echo "root:rootroot" | chpasswd
    printf "en_US.UTF-8 UTF-8\n" >> /etc/locale.gen && locale-gen
    git config --global user.name "fake" && git config --global user.email "fake@foo.cn"
    cat >/root/.vimrc <<EOF
set number
set expandtab
set tabstop=4
set laststatus=2
syntax on
set background=dark
set mouse=""
set hlsearch
set shiftwidth=4
EOF
    cat >>/root/.bashrc <<'EOF'
shopt -s histappend
source /usr/share/autojump/autojump.bash
alias ls='ls --color'
export GOROOT=/opt/go
export GOPATH=/root/go
export GOPROXY=https://goproxy.cn
export PATH=/opt/go/bin:$PATH
EOF
    mkdir -p /var/run/sshd /root/.pip
    sed -i -e 's/#PermitRootLogin.*/PermitRootLogin yes/' -e 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    cat >/root/.pip/pip.conf<<EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
format = freeze
disable-pip-version-check = true
EOF

    local python_binary=$(which python3 2>/dev/null || true)
    [[ -z "$python_binary" ]] || curl -L https://bootstrap.pypa.io/get-pip.py | python3
}

setup_miniconda()
{
    wget -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-4.5.1-Linux-x86_64.sh -P /opt
    bash /opt/Miniconda3-4.5.1-Linux-x86_64.sh -p /root/conda3 -b

    for venv in 3.6 3.7; do
        /root/conda3/bin/conda create -n "py${venv/.}" -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ -y python=$venv
    done
}

cleanup()
{
    rm -rf "${TMPDIR}"
    # https://github.com/bazelbuild/bazel/blob/0.25.1/scripts/bootstrap/buildenv.sh
    trap - EXIT
}

check_uid || exit

trap "cleanup" EXIT ERR INT
TMPDIR=$(mktemp -d)

source /etc/os-release
install_package
setup_configuration
setup_miniconda

wget -c "https://mirrors.ustc.edu.cn/golang/go1.13.linux-amd64.tar.gz" -O - | tar zx -C /opt
