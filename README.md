# Vite+ issue 2531 dependency-resolution investigation

This repository investigates [voidzero-dev/vite-plus#2531](https://github.com/voidzero-dev/vite-plus/issues/2531) with three minimal npm projects.

## Environment

- Node.js `26.5.0`
- npm `12.0.2`
- `vite-plus@^0.2.9` (resolves to `0.2.9`)

## Results

| Project | Dependencies | Result |
| --- | --- | --- |
| `reported` | Only `vite-plus@^0.2.9` | Install succeeds |
| `conflict` | `vite-plus@^0.2.9` and `@vitest/browser-playwright@4.1.11` | Install fails with `ERESOLVE` |
| `aligned` | `vite-plus@^0.2.9` and `@vitest/browser-playwright@4.1.10` | Install succeeds |

Run each case from a clean checkout:

```sh
cd reported && npm install
cd ../conflict && npm install
cd ../aligned && npm install
```

The original steps do not reproduce the reported failure. npm does not install optional peer dependencies when only `vite-plus` is present.

The conflict occurs when `@vitest/browser-playwright@4.1.11` is also in the dependency tree. `vite-plus@0.2.9` depends on `vitest@4.1.10` and has an exact optional peer on `@vitest/browser-playwright@4.1.10`. The `4.1.11` browser provider has an exact peer on `vitest@4.1.11`, so npm cannot resolve one compatible set.

The issue's error output also reports an existing `vite-plus@0.2.8`, even though the requested range is `^0.2.9`. That output is not produced by a fresh install of the supplied dependency set.

## Fix options

- Consumers on `vite-plus@0.2.9` can pin the browser provider to `4.1.10`.
- Vite+ can publish an atomic update that moves `vitest` and all `@vitest/*` packages to `4.1.11`. The Vite+ `main` branch already contains that aligned update for the pending `0.3.0` release.
- Widening only the Vite+ optional peer range is unsafe because Vitest browser providers use exact `vitest` peer versions.
- `--force` and `--legacy-peer-deps` suppress the resolver check but do not make the two Vitest versions compatible.
