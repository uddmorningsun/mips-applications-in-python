#!/bin/bash

set -e
set -x
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

get_install_packages()
{
    pushd "$TMPDIR" >/dev/null
    curl -L -k -O "https://raw.githubusercontent.com/bitnami/centos-extras-base/7-r319/7/rootfs/usr/local/bin/install_packages" || {
        log_error "can not get tool from https://github.com/bitnami/centos-extras-base ..."
        return 1
    }
    chmod 755 "${TMPDIR}/install_packages" || return

    "${TMPDIR}/install_packages" epel-release
    "${TMPDIR}/install_packages" centos-release-scl
    "${TMPDIR}/install_packages" tmux vim gcc gcc-c++ make unar less which cmake wget libffi-devel openssl-devel git file python3-devel \
    bzip2 gcc-gfortran unzip yum-utils rpm-build autojump rsync openssh-server devtoolset-6 bash-completion-extras
}

setup_configuration()
{
    ssh-keygen -A
    echo "root:rootroot" | chpasswd
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
export GOROOT=/opt/go
export GOPATH=/root/go
export GOPROXY=https://goproxy.cn
export PATH=/opt/go/bin:$PATH
EOF
    git config --global user.name "fake" && git config --global user.email "fake@foo.cn"
    mkdir -p /root/.pip
    cat >/root/.pip/pip.conf<<EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
format = freeze
disable-pip-version-check = true
EOF

    local python_binary=$(which python3 2>/dev/null || true)
    [[ -z "$python_binary" ]] || curl -L https://bootstrap.pypa.io/get-pip.py | python3 -u
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

get_install_packages
setup_configuration
setup_miniconda
wget -c "https://mirrors.ustc.edu.cn/golang/go1.13.linux-amd64.tar.gz" -O - | tar zx -C /opt
