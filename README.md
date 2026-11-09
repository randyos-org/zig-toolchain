# zig-toolchain

Builds of the Zig that [zig-build](https://github.com/randyos-org/zig-build) (a mirror of its source on [Codeberg](https://codeberg.org/emanspeaks/zig-build)) pins, for the GitHub-hosted runners, so other projects' CI can test with it without building Zig themselves.

## Using it

```yaml
- uses: randyos-org/zig-toolchain/setup@main
  with:
    version: latest   # or a version as `zig version` prints it
```

The action puts `zig` on `PATH` and gives the version as `steps.<id>.outputs.version`. It supports these runners (not Intel macOS: upstream publishes no `x86_64-macos` devkit to bootstrap from, so that host would need zig-build's cross pipeline):

| Host | Runner |
| --- | --- |
| `x86_64-linux-musl` | `ubuntu-24.04` |
| `aarch64-linux-musl` | `ubuntu-24.04-arm` |
| `x86_64-windows-gnu` | `windows-2025` |
| `aarch64-windows-gnu` | `windows-11-arm` (not built yet: `zig2` does not link there, see `targets.json`) |
| `aarch64-macos-none` | `macos-15` |

## How it is built

[`build.yml`](.github/workflows/build.yml) runs zig-build's own scripts on each runner in [`targets.json`](targets.json):

1. `ci-sources.sh` fetches the pinned zig-src.
2. `build-stage3.sh` bootstraps a release Zig from the upstream devkit for that host (`baseline` CPU, so it runs on any machine of the architecture).
3. A smoke test runs `zig version`, then builds and runs a Zig and a C hello world.
4. Each version's builds go into one release, `zig-<version>`, with a `manifest-<host>.json` per host listing its inputs.

A host builds only when no recent release holds its key (zig-build's `cross-manifest.sh key host`: the zig-src pin, the devkit, the host triple and CPU, and the stage scripts), so an unchanged zig-build never rebuilds. Start a run by hand from the Actions tab; `force` rebuilds every host.

## License

MIT ([`LICENSE`](LICENSE)). Zig itself is MIT licensed by its authors.
