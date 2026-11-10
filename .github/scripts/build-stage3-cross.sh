#!/usr/bin/env bash
# Cross-build stage3 for another host with this host's stage3 (the same
# zig-src), linking that host's devkit LLVM: build-stage3.sh's stage 2,
# with stage3 in place of zig2 and the other host as the target. For a host whose
# own bootstrap fails: Arm Windows, where zig2 does not link
# (randyos-org/rstd#262). Run after build-stage3.sh, from the zig-build checkout.
# usage: build-stage3-cross.sh <target> <prefix> [zig build args]
target=${1:?usage: build-stage3-cross.sh <target> <prefix> [zig build args]}
prefix=${2:?usage: build-stage3-cross.sh <target> <prefix> [zig build args]}
shift 2
zig=$PWD/bin/stage3/bin/zig

# the target's devkit (zig-build picks it by ZIG_HOST_TARGET; nothing runs it)
( export ZIG_HOST_TARGET=$target; . ./build-devkit.sh ) || exit 1
devkit=$(export ZIG_HOST_TARGET=$target; . ./common.sh >/dev/null 2>&1; echo "${DEVKIT_WIN:-$DEVKIT}")
[ -d "$devkit" ] || { echo "no devkit at $devkit" >&2; exit 1; }
# native zig.exe cannot open msys /c/... paths (common.sh)
command -v cygpath >/dev/null 2>&1 && prefix=$(cygpath -ma "$prefix")

cd zig-src
# -Doptimize=ReleaseFast is common.sh's ZIG_BUILD_TYPE_RELWITHDEBINFO
"$zig" build \
  --prefix "$prefix" \
  -Doptimize=ReleaseFast \
  -Dtarget="$target" \
  -Dcpu="$ZIG_HOST_CPU" \
  -Duse-zig-libcxx \
  -Dno-lib \
  -Dstatic-llvm \
  --search-prefix "$devkit" \
  "$@" \
  || exit 1
echo "Cross-built stage3 for $target"
