#!/usr/bin/env bash
# Build stage3 with the upstream devkit's zig directly, skipping zig-build's
# C bootstrap (zig1, zig2), for a host where zig2 does not link: Arm Windows,
# randyos-org/rstd#262 (zig.h has no zig_windows_peb there). The flags are
# build-stage3.sh's stage 2, with the devkit's zig in place of zig2.
# usage, from the zig-build checkout: bash ../.github/scripts/build-stage3-direct.sh [zig build args]
. ./common.sh
. ./env-setup.sh
. ./build-devkit.sh

fetch-upstream-tags "$ZIG_SRC" "$ZIG_UPSTREAM_URL" ||
  echo "warning: could not fetch zig tags; version string may lack the dev suffix" >&2

cd "$ZIG_SRC"
"$DEVKIT_ZIG_EXE" build \
  --prefix "$ZIG_STAGE3_PREFIX" \
  $ZIG_BUILD_TYPE_RELWITHDEBINFO \
  -Dtarget="$ZIG_HOST_TARGET" \
  -Dcpu="$ZIG_HOST_CPU" \
  -Duse-zig-libcxx \
  -Dno-lib \
  -Dstatic-llvm \
  --search-prefix "${DEVKIT_WIN:-$DEVKIT}" \
  "$@" \
  || exit 1
echo "Build stage 3 complete (devkit zig, no C bootstrap)"
