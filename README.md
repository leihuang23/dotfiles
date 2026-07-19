# dotfiles

My personal Mac setup, managed with [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).
One repo, one command, and a fresh Mac ends up configured the same way every time.

This repo was originally forked/adapted from [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles). The original walkthrough is at https://youtu.be/5N-okeDdIuI. Thanks to Kun for sharing it.

## What you get

Running the switch builds:

- System settings (dark mode, key repeat, dock, Finder, trackpad)
- Homebrew apps (casks and CLI tools)
  - CLI tools: `herdr`, `kimi-code`
  - Casks: `wezterm`, `claude-code`, `cc-switch`
- Nix user packages (`ripgrep`, `fd`, `fzf`, `jq`, `lazygit`, `neovim`, `hack` nerd font)
- Shell (`zsh`, aliases, [starship](https://starship.rs) prompt)
- Editor (Neovim config with the rose-pine moon theme)
- Terminal (WezTerm config with the rose-pine moon theme)
- Agent configs (Claude, Codex, opencode, and Kimi Code)
  - Claude Code provider/API config is managed by [CC Switch](https://github.com/farion1231/cc-switch), not home-manager.
  - Claude, Codex, and opencode share one `AGENTS.md`.
  - Kimi Code config is managed under `home/.kimi-code/`.

## Prerequisites

- Apple Silicon Mac, by default (`aarch64-darwin`).
- Intel Mac: change one line in `configuration.nix`:
  ```nix
  nixpkgs.hostPlatform = "x86_64-darwin";
  ```

## Fresh-machine setup

On a brand new Mac, from a bare clone of this repo:

```sh
git clone git@github.com:leihuang23/dotfiles.git
cd dotfiles
```

Before you run it: review "Make it yours" below.
Change the host label or CPU architecture if needed, and read the Homebrew cleanup warning.
`bootstrap.sh` applies the config to your machine, so run this first:

```sh
./bootstrap.sh
```

`bootstrap.sh` does four things, in order:

1. Installs Determinate Nix, if it isn't already installed.
2. Symlinks this repo to `~/.dotfiles`.
   This has to happen before the first build, because `home.nix` points at config files through `~/.dotfiles`.
3. Checks the `user` configured in `flake.nix` against your actual macOS username, and offers to fix it for you if they differ.
4. Runs the first `darwin-rebuild switch`.
   It fetches the `darwin-rebuild` tool from the nix-darwin 26.05 release branch, then applies this repo's locked flake config.

After that, `darwin-rebuild` exists and you're on the normal workflow below.

### Validate without applying

Once Nix is installed (`bootstrap.sh` step 1 handles that), you can check that the config builds without touching your system:

```sh
nix flake check --no-build
nix build .#darwinConfigurations.macbook-pro.system --dry-run
```

If you renamed the host label, substitute your label for `macbook-pro` in these commands.

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

That's it. No separate build-and-copy step.

## Make it yours

This repo is currently configured for:

- **Username:** `leihuang`
- **Host label:** `macbook-pro`
- **Architecture:** `aarch64-darwin` (Apple Silicon)
- **Git identity:** set declaratively in `home.nix` as `leihuang` / `leihuang@example.com`

If you clone this for a different machine, review and update these before you run `bootstrap.sh`:

- **Username:** run `./bootstrap.sh` (it detects your macOS username and offers to set it) OR change the single `user = "leihuang"` line in `flake.nix`.
  Everything else (`configuration.nix`, `home.nix`, home directory paths) is threaded from that one variable.
- **Host label** `"macbook-pro"`, in three places: `flake.nix` (the `darwinConfigurations."macbook-pro"` name), `rebuild.sh` (the `#macbook-pro` at the end of the flake reference), and `bootstrap.sh`'s first-switch command (also `#macbook-pro`).
  All three have to match.
- **CPU architecture**, `hostPlatform` in `configuration.nix` (see Prerequisites above).

**Homebrew cleanup warning:** `configuration.nix` sets `homebrew.onActivation.cleanup = "zap"`.
That means every time you switch, Homebrew removes any package or cask on your machine that isn't listed in the `brews` and `casks` arrays in `configuration.nix`.
If you already have Homebrew stuff installed that isn't in that list, the first switch will uninstall it.
Read through `brews` and `casks` before you run `bootstrap.sh` or `rebuild.sh` for the first time, and add anything you want to keep.

`nix-homebrew.autoMigrate = true` is enabled, so an existing `/opt/homebrew` installation will be migrated into nix-homebrew management rather than wiped.

**Heads-up:**

- `home/AGENTS.md` is inherited from the original repo and is installed for Claude, Codex, and opencode.
  If you clone this repo, you'd silently inherit those agent instructions — edit or delete `home/AGENTS.md` if you don't want that.
- The `cc` and `co` shell aliases in `home.nix` are high-agency shortcuts: `claude --dangerously-skip-permissions` and `codex --full-auto`.
  They're convenient, but know what they do before you use them.

## Claude Code + CC Switch

[CC Switch](https://github.com/farion1231/cc-switch) is the single source of truth for Claude Code (and Codex / Gemini / etc.) **provider** config: API keys, base URLs, and model defaults.

### Ownership split

| Path | Owner | Notes |
|------|--------|--------|
| `~/.cc-switch/` | CC Switch | SQLite DB, device settings, skills SSOT, backups |
| `~/.claude/settings.json` | CC Switch | Written on provider switch. **Not** managed by home-manager. |
| `~/.claude/CLAUDE.md` | home-manager | Symlink to shared `home/AGENTS.md` |
| `home/.claude/settings.example.json` | git (template only) | Seed / reference. No live keys. |

Do **not** re-add `home.file.".claude/settings.json"` in `home.nix`. A managed symlink either blocks CC Switch writes or dirties git on every provider switch.

Do **not** export `ANTHROPIC_AUTH_TOKEN` / `ANTHROPIC_BASE_URL` in shell config. Shell env wins over `settings.json` and pins every switch to one provider. Keep raw keys like `DEEPSEEK_API_KEY` in `~/.zshrc.secrets` only for non-Claude tools; put Claude credentials inside each CC Switch provider profile.

### First-time / recovery

1. Install via this repo (`cc-switch` is in the Homebrew casks list) and open **CC Switch**.
2. On first launch, import the live Claude config as a provider, or add presets (DeepSeek, OpenRouter, Official, …).
3. Put shared non-provider fields (hooks, statusLine, plugins) in **Edit Provider → Shared Config** so they survive switches.
4. Skills: prefer storage at `~/.agents/skills` (this machine already symlinks `~/.claude/skills` there). Set that in CC Switch Skills settings if it is still on the built-in `~/.cc-switch/skills` path.
5. Optional seed without secrets: copy `home/.claude/settings.example.json` → `~/.claude/settings.json`, then import it in CC Switch and fill the key.

### DeepSeek example

A typical DeepSeek provider `env` block (key only in CC Switch / live file, never in git):

```json
{
  "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
  "ANTHROPIC_AUTH_TOKEN": "<your-deepseek-api-key>",
  "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
  "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro[1m]",
  "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash[1m]",
  "CLAUDE_CODE_EFFORT_LEVEL": "max",
  "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
}
```

Inside Claude Code, switch models with `/model opus`, `/model sonnet`, or `/model haiku`. Switch **providers** from the CC Switch tray or main UI (Claude Code hot-reloads provider data).

## Repo tour

- `flake.nix` - the entry point.
  Wires up nixpkgs, nix-darwin, home-manager, and nix-homebrew, and declares the `macbook-pro` machine.
- `configuration.nix` - system-level config: macOS defaults, Homebrew.
- `home.nix` - user-level config: shell, packages, prompt, git identity, and the symlinks described below.
- `rebuild.sh` - re-applies the config after the first switch.
  Run this every time you make a change.
- `bootstrap.sh` - one-time fresh-Mac setup.
- `home/` - the actual config files that get symlinked into place (Neovim, WezTerm, herdr, Claude settings, Kimi Code settings, the shared `AGENTS.md`).

## How the symlinks work

The files under `home/` are the real files — editing them here is editing your live config, no rebuild needed to see the change in your editor.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/nvim` straight at `home/.config/nvim` in this repo, so the two never drift out of sync.
You only run `./rebuild.sh` when you change something that isn't just a symlinked file, like a package list or a system default.

## Notes

- The first time you launch `nvim`, it bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) by cloning plugins from GitHub.
  That needs network access once; after that it's offline.
- Neovim and WezTerm both use the rose-pine moon theme.
- Neovim keeps italics off and uses a transparent background on macOS so it matches the terminal setup.

## License

This repo is licensed under MIT No Attribution.
See `LICENSE`.
