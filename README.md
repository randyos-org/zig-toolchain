# zig-toolchain

Builds of the Zig that [zig-build](https://github.com/randyos-org/zig-build) pins, for the GitHub-hosted runners, so other projects' CI can test with it without building Zig themselves.

## Using it

```yaml
- uses: randyos-org/zig-toolchain/setup@main
  with:
    version: latest   # or a version as `zig version` prints it
```

The action puts `zig` on `PATH` and gives the version as `steps.<id>.outputs.version`. It supports these runners:

| Host | Runner |
| --- | --- |
| `x86_64-linux-musl` | `ubuntu-24.04` |
| `aarch64-linux-musl` | `ubuntu-24.04-arm` |
| `x86_64-windows-gnu` | `windows-2025` |
| `aarch64-windows-gnu` | `windows-11-arm` (cross-built by the `x86_64-windows-gnu` job: `zig2` does not link there, [rstd#262](https://github.com/randyos-org/rstd/issues/262)) |
| `aarch64-macos-none` | `macos-15` |
| `x86_64-macos-none` | `macos-15-intel` (upstream publishes no devkit for it, so it bootstraps from the one [zig-devkits](https://github.com/randyos-org/zig-devkits) builds) |

## How it is built

[`build.yml`](.github/workflows/build.yml) runs zig-build's own scripts on each runner in [`targets.json`](targets.json):

1. `ci-sources.sh` fetches the pinned zig-src, and the pinned zig-devkits, whose `devkits.json` names each host's devkit.
2. `build-stage3.sh` bootstraps a release Zig from that host's devkit, upstream's mirrored by zig-devkits or zig-devkits' own build (`baseline` CPU, so it runs on any machine of the architecture).
3. `package.sh` makes a Zig install of it, `bin/` with the standard library in `lib/zig`, and a smoke test runs that package outside zig-build's tree: `zig version`, then a Zig and a C hello world. A host whose own bootstrap fails (`cross_from` in `targets.json`) is cross-built by another host's stage3 and smoke-tested on its own runner.
4. Each version's builds go into one release, `zig-<version>`, with a `manifest-<host>.json` per host listing its inputs.

A host builds only when no recent release holds its key (zig-build's `cross-manifest.sh key host`: the zig-src pin, the devkit, the host triple and CPU, and the stage scripts), so an unchanged zig-build never rebuilds. Start a run by hand from the Actions tab; `force` rebuilds every host.

## License

MIT ([`LICENSE`](LICENSE)). Zig itself is MIT licensed by its authors.
