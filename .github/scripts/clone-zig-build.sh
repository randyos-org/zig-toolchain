#!/usr/bin/env bash
# Clone zig-build (from $ZIG_BUILD_URL) at a branch, tag or commit.
# usage: clone-zig-build.sh <ref> [dir]
# Codeberg intermittently answers 5xx, so the clone is retried.
set -euo pipefail
REF=${1:?usage: clone-zig-build.sh <ref> [dir]}
DIR=${2:-zig-build}

for i in 1 2 3 4 5; do
  git clone --quiet --filter=blob:none --no-checkout "$ZIG_BUILD_URL" "$DIR" && break
  rm -rf "$DIR"
  [ "$i" = 5 ] && { echo "could not clone $ZIG_BUILD_URL" >&2; exit 1; }
  sleep $((i * 30))
done
git -C "$DIR" checkout --quiet "$REF"
# zig-build picks each host's devkit (and so its host key) from devkits.json in
# its zig-devkits submodule, which older zig-build commits lack
if git -C "$DIR" config -f .gitmodules submodule.zig-devkits.path >/dev/null; then
  git -C "$DIR" submodule update --quiet --init --filter=blob:none zig-devkits
fi
echo "zig-build at $(git -C "$DIR" rev-parse HEAD)"
