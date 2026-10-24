# CLAUDE.md

Personal dotfiles, linked into `~` with GNU Stow. Two profiles: **Omarchy** (layered on top of Omarchy's defaults) and **standalone** (macOS / Arch / EndeavourOS, full zsh setup). See README.md for the user-facing details.

## Layout

- `common/<pkg>/`: every machine (`git shell bin lazygit mise conda`).
- `omarchy/<pkg>/`: Omarchy only (`tmux hypr starship ssh hooks`).
- `standalone/<pkg>/`: macOS / Arch only (`zsh git alacritty btop tmux nvim fastfetch zed`).
- `windows/`: PowerShell profile, never stowed.
- `templates/`: per-machine files copied once, never linked (`gitconfig.local` → `~/.gitconfig.local`).
- `upstream/omarchy/`: Omarchy files as last reviewed, the baseline `dotfiles-check` diffs against.

Inside a package, paths mirror `~` (`common/shell/.config/shell/rc.sh` → `~/.config/shell/rc.sh`). The package lists live in `install.sh` (`COMMON_PACKAGES`, `PROFILE_PACKAGES`); `install.sh --list` prints them.

## Rules

- **Never `stow .` on the repo root.** Use `./install.sh --link-only` (or `--dry-run` to preview), or `stow -d <group> <pkg>`.
- **On Omarchy, add, don't replace.** Omarchy owns `~/.bashrc`, `tmux.conf`, `hyprland.lua` and its migrations edit them. Put settings in your own file and load it with one line (`ensure_line` in `install.sh`, step 5b). Never copy an Omarchy file into the repo; the one exception is `starship.toml` (starship can't include), tracked against `upstream/omarchy/starship`.
- **Don't add what Omarchy already ships** (git defaults, mise, theming, nvim, terminal). Check `/usr/share/omarchy` first.
- **Edit through the links.** `~/.config/shell/aliases.sh` is the repo file; edit either path, then review with `git diff`.
- **Secrets and per-machine values stay out of the repo** (keys, work identity, signing key): they go in `~/.gitconfig.local` or other untracked files, with a commented template in `templates/`.
- New personal commands go in `common/bin/.local/bin/`, executable. `~/.local/bin` is a real directory (`REAL_DIRS`), so stow links single files into it.
- Scripts: bash with `set -eu` (or `set -u`), safe to re-run, idempotent; skip steps already done rather than overwriting.

## Checking changes

```bash
bash -n <script>            # syntax
./install.sh --dry-run      # what would be backed up and linked
dotfiles-check              # links, hook lines, SSH agent, signing, Omarchy drift
dotfiles-check --online     # also GitHub SSH access
```

Every `install.sh` run is logged to `~/.local/state/dotfiles/install-<time>.log` (`install-latest.log` points to the newest); read that rather than asking for pasted output. `ssh-setup` output goes to the terminal only.

Test anything that touches `~/.ssh`, `~/.gitconfig.local` or other real home files against a throwaway `HOME=<scratch dir>` first.

After merging an Omarchy change into `starship.toml` (or when Omarchy changes its git config), run `dotfiles-check --accept` and commit `upstream/omarchy/` and `standalone/`.

## Docs and commits

- Keep README.md (structure, Omarchy layering, SSH) and SETUP.md in sync with behaviour changes.
- Conventional commits with a scope: `feat(zsh): …`, `fix(install): …`, `chore(git): …`.
