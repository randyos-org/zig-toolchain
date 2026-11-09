#!/usr/bin/env bash
# zig-build's test-zig-cross.sh, run natively on a packaged Zig: it runs, finds
# its own standard library, and builds and runs a Zig and a C hello world.
# Run it on the packaged folder (package.sh), never inside zig-build's tree,
# where zig would find zig-build's lib/ instead of its own.
# usage: smoke.sh <unpacked zig folder>
set -euo pipefail
zig=$1/bin/zig
t=${RUNNER_TEMP:-/tmp}/smoke
rm -rf "$t"
mkdir -p "$t"
export ZIG_GLOBAL_CACHE_DIR=$t/global-cache ZIG_LOCAL_CACHE_DIR=$t/local-cache
set -x
"$zig" version
"$zig" env
printf 'const std = @import("std");\npub fn main() void {\n    std.debug.print("hello from zig\\n", .{});\n}\n' > "$t/hello.zig"
"$zig" build-exe "$t/hello.zig" -femit-bin="$t/hello-zig"
"$t/hello-zig" 2>&1 | grep -q "hello from zig"
printf '#include <stdio.h>\nint main(void) { puts("hello from c"); return 0; }\n' > "$t/hello.c"
"$zig" cc "$t/hello.c" -o "$t/hello-c"
"$t/hello-c" | grep -q "hello from c"
set +x
echo "smoke test passed"
