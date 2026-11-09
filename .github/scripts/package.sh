#!/usr/bin/env bash
# Package a stage3 build as a Zig install: <name>/bin/zig with the zig-src
# standard library at <name>/lib/zig, where zig looks for it. zig-build builds
# stage3 with -Dno-lib (its own tree links lib/ to zig-src/lib), so the library
# is copied in here. Writes dist/<archive> (.zip for a Windows target, .tar.xz
# otherwise) and dist/manifest-<target>.json, leaves the unpacked folder for the
# smoke test, and prints its path last.
# usage: package.sh <stage3 prefix> <target> <host_key> <bootstrap> <zig version>
# env: ZIG_HOST_CPU, ZIG_BUILD_COMMIT; run from the workspace, beside zig-build/
set -euo pipefail
prefix=$1 target=$2 host_key=$3 bootstrap=$4 version=$5
name="zig-$target-$ZIG_HOST_CPU-$version"
rm -rf "$name"
mkdir -p "$name/lib" dist
cp -R "$prefix/bin" "$name/bin"
cp -R zig-build/zig-src/lib "$name/lib/zig"
case "$target" in
  *-windows-*)
    archive=$name.zip
    7z a -tzip -bso0 "dist/$archive" "$name" >&2
    ;;
  *)
    archive=$name.tar.xz
    tar -cJf "dist/$archive" "$name"
    ;;
esac
jq -n --arg target "$target" --arg cpu "$ZIG_HOST_CPU" --arg version "$version" \
  --arg host_key "$host_key" --arg zig_build_commit "$ZIG_BUILD_COMMIT" \
  --arg zig_src_commit "$(git -C zig-build/zig-src rev-parse HEAD)" \
  --arg archive "$archive" --arg bootstrap "$bootstrap" \
  '{target: $target, cpu: $cpu, zig_version: $version, host_key: $host_key,
    zig_build_commit: $zig_build_commit, zig_src_commit: $zig_src_commit, archive: $archive,
    bootstrap: $bootstrap}' \
  > "dist/manifest-$target.json"
cat "dist/manifest-$target.json" >&2
ls -l dist >&2
echo "$PWD/$name"
