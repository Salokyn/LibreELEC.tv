# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Lukas Rusak (lrusak@libreelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="containerd"
PKG_VERSION="1.7.3"
PKG_SHA256="1fd19d2c75322bdbcb01d190a18d53940a4a79d909bd61a99f9e8e2dbc57a8fe"
PKG_LICENSE="APL"
PKG_SITE="https://containerd.io"
PKG_URL="https://github.com/containerd/containerd/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain go:host"
PKG_LONGDESC="A daemon to control runC, built for performance and density."
PKG_TOOLCHAIN="manual"

# Git commit of the matching release https://github.com/containerd/containerd/releases
PKG_GIT_COMMIT="0cae528dd6cb557f7201036e9f43420650207b58"

pre_make_target() {

  go_configure

  export CONTAINERD_VERSION="${PKG_VERSION}"
  export CONTAINERD_REVISION="${PKG_GIT_COMMIT}"
  export CONTAINERD_PKG="github.com/containerd/containerd"
  export LDFLAGS="-w -extldflags -static -X ${CONTAINERD_PKG}/version.Version=${CONTAINERD_VERSION} -X ${CONTAINERD_PKG}/version.Revision=${CONTAINERD_REVISION} -X ${CONTAINERD_PKG}/version.Package=${CONTAINERD_PKG} -extld ${CC}"
  export GO111MODULE=off

  mkdir -p ${GOPATH}
  if [ -d ${PKG_BUILD}/vendor ]; then
    mv ${PKG_BUILD}/vendor ${GOPATH}/src
  fi

  ln -fs ${PKG_BUILD} ${GOPATH}/src/github.com/containerd/containerd
}

make_target() {
  mkdir -p bin
  ${GOLANG} build -v -o bin/containerd              -a -tags "static_build no_btrfs" -ldflags "${LDFLAGS}" ./cmd/containerd
  ${GOLANG} build -v -o bin/containerd-shim         -a -tags "static_build no_btrfs" -ldflags "${LDFLAGS}" ./cmd/containerd-shim
  ${GOLANG} build -v -o bin/containerd-shim-runc-v2 -a -tags "static_build no_btrfs" -ldflags "${LDFLAGS}" ./cmd/containerd-shim-runc-v2
}
