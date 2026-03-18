# mise-blade

A mise tool plugin for the Liferay Blade CLI using the vfox-style Lua hooks architecture.

This plugin mirrors Liferay's local installer behavior and installs Blade into the user's home via JPM (no system-wide install).

## Requirements

- Java (JRE/JDK) on `PATH`
- Network access to:
  - `repository-cdn.liferay.com`
  - `raw.githubusercontent.com`

## Install (local development)

```bash
mise plugin link --force blade /path/to/this/repo
mise install blade@latest
mise use blade@latest
blade version
```

## Usage

List available versions:

```bash
mise ls-remote blade
```

Install a specific version:

```bash
mise install blade@8.0.0
mise use blade@8.0.0
```

## Where Blade is installed

The Blade binary is installed by JPM into:

- Linux: `~/jpm/bin`
- macOS: `~/Library/PackageManager/bin`

The plugin adds the appropriate directory to `PATH` via `EnvKeys`.

## Development Workflow

### Setting up development environment

Install pre-commit hooks (optional but recommended):

```bash
hk install
```

### Local Testing

```bash
mise run test
```

### Linting

```bash
mise run lint
```

### Full CI suite

```bash
mise run ci
```

### Debugging

```bash
MISE_DEBUG=1 mise install blade@latest
```

## Code Quality

This repo follows the mise tool plugin template tooling:

- `stylua` for formatting
- `lua-language-server` for static checks
- `actionlint` for GitHub Actions validation
- `hk` to run the suite locally or as pre-commit hooks

Manual commands:

```bash
hk check
hk fix
```

## Files

- `metadata.lua` – Plugin metadata and configuration
- `hooks/available.lua` – Returns available versions from upstream
- `hooks/pre_install.lua` – Returns artifact URL for a given version
- `hooks/post_install.lua` – Post-installation setup
- `hooks/env_keys.lua` – Environment variables to export (PATH, etc.)
- `.github/workflows/ci.yml` – GitHub Actions CI pipeline
- `mise.toml` – Development tools and task configuration
- `mise-tasks/` – Task scripts for testing
- `types/mise-plugin.lua` – LuaCATS type definitions for IDE support
- `hk.pkl` – Linting and pre-commit hook configuration
- `stylua.toml` – Lua formatting configuration

## Publishing

1. Ensure tests pass: `mise run ci`
2. Update `metadata.lua` version
3. Commit changes
4. Tag a release: `git tag -a v1.0.0 -m "Release v1.0.0"`
5. Push tags: `git push origin --tags`
6. Create a GitHub Release (recommended)

Install from Git:

```bash
mise plugin install blade https://github.com/kheeklab/mise-liferay-blade
mise plugin install blade https://github.com/kheeklab/mise-liferay-blade@v1.0.0
```

## License

MIT
