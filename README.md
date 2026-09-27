# edelweiss-conda-channel

Recipes and CI for the [`matthiasneuner/edelweiss`](https://prefix.dev/channels/edelweiss) conda channel on prefix.dev.
It holds only what conda-forge lacks for a **conda-only, free-threaded (cp314t)** EdelweissFE + Marmot environment;
everything else comes from conda-forge:

| Package | Why it is here |
|---|---|
| `vtk`, `vtk-base`, `vtk-io-ffmpeg` | conda-forge's vtk-feedstock builds no free-threaded (cp314t) Python variant. Built unchanged from the feedstock recipe (pinned commit in `build.yml`) with a derived cp314t variant (`scripts/make_cp314t_variant.py`). |
| `autodiff` 1.1.2 | conda-forge only has 0.5.13; patched with upstream autodiff#397 for Eigen 5 support. |
| `fastor`, `amgcl` | Not packaged on conda-forge. |

Platforms: linux-64, osx-arm64, osx-64, win-64.

## Use

```console
mamba create -n edelweissfe -c https://repo.prefix.dev/matthiasneuner/edelweiss -c conda-forge python-freethreading=3.14 vtk pyvista ...
```

Use flexible channel priority (the default); the solve fails under `--strict-channel-priority`.

## Build and publish

Every push builds all platforms and keeps the packages as workflow artifacts.
Publishing is manual: run the `build` workflow with `upload` ticked (needs the `PREFIX_API_KEY` repository secret).

Retire a package here once conda-forge ships it (e.g. a cp314t vtk, autodiff with Eigen 5 support).
