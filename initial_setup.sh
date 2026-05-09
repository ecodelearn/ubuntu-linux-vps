#!/usr/bin/env bash
set -euo pipefail
trap 'rc=$?; echo "FATAL: line $LINENO: $BASH_COMMAND (exit $rc)" >&2; df -h >&2; mount >&2; exit $rc' ERR

SCRIPT_VERSION="2026-04-01-verify10"
echo "BOOTSTRAP VERSION: $SCRIPT_VERSION"

if [[ ! -t 0 ]] && [[ ! -e /dev/tty ]]; then
    echo "ERROR: interactive mode requires a TTY" >&2
    exit 1
fi

############################################################################
# Interactive input (must read from TTY when piped)
###############################################################################

USE_FISH=1   # default

prompt_username() {
    local name
    while true; do
        read -rp "Enter username to create/configure: " name </dev/tty || true
        if [[ "$name" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            USER_NAME="$name"
            break
        else
            echo "Invalid username. Use lowercase letters, digits, _ or -."
        fi
    done
}

prompt_fish() {
    local reply
    read -rp "Use fish as default shell? [Y/n]: " reply </dev/tty || true
    case "${reply:-Y}" in
        [Nn]*) USE_FISH=0 ;;
        *)     USE_FISH=1 ;;
    esac
}

prompt_username
prompt_fish

###############################################################################
# Configuration
###############################################################################

HOME_DIR="/home/${USER_NAME}"
LOG_FILE="/var/log/bootstrap-${USER_NAME}.log"

###############################################################################
# Logging setup
###############################################################################

install -d -m 0755 "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    printf "\n==> %s\n" "$1"
}

###############################################################################
# Root check
###############################################################################

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "ERROR: run as root (sudo bash $0)" >&2
    exit 1
fi

log "Logging to $LOG_FILE"

###############################################################################
# System info
###############################################################################

log "System info"
uname -a || true
cat /etc/os-release || true
mount | grep -E " on /home " || true

###############################################################################
# Base tools
###############################################################################

log "Install base tools"
apt-get update -y
apt-get install -y \
    ca-certificates curl wget gpg git jq fzf ripgrep fd-find
apt-get install -y --no-install-recommends fish
apt upgrade -y

if command -v fdfind >/dev/null; then
    ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi

###############################################################################
# GitHub CLI
###############################################################################

if ! command -v gh >/dev/null 2>&1; then
    log "Installing GitHub CLI (gh)"

    mkdir -p /etc/apt/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null

    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list

    apt-get update -y
    apt-get install -y gh
fi

###############################################################################
# Create /home and user (HARD guarantee)
###############################################################################

log "Creating /home and ${HOME_DIR} unconditionally (HARD guarantee)"

mkdir -p /home
chmod 0755 /home

mkdir -p "$HOME_DIR"
chmod 0755 "$HOME_DIR"

log "Create user if missing, force home to ${HOME_DIR}"

if ! getent passwd "$USER_NAME" >/dev/null; then
    useradd -m -d "$HOME_DIR" -s /bin/bash "$USER_NAME" || true
fi

if getent passwd "$USER_NAME" >/dev/null; then
    usermod -d "$HOME_DIR" -m "$USER_NAME" || true
    chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR" || true
fi

if [[ ! -d "$HOME_DIR" ]]; then
    echo "FATAL: $HOME_DIR does not exist after mkdir/usermod."
    exit 2
fi

getent passwd "$USER_NAME" || true
ls -ld "$HOME_DIR" || true

###############################################################################
# Sudo + passwordless sudo
###############################################################################

log "Configure sudo access for $USER_NAME"

usermod -aG sudo "$USER_NAME"

install -m 0440 /dev/null "/etc/sudoers.d/90-${USER_NAME}-nopasswd"
echo "${USER_NAME} ALL=(ALL:ALL) NOPASSWD:ALL" \
    > "/etc/sudoers.d/90-${USER_NAME}-nopasswd"
visudo -cf "/etc/sudoers.d/90-${USER_NAME}-nopasswd" >/dev/null

###############################################################################
# SSH authorized_keys
###############################################################################

log "Copying root SSH keys"

if [[ -f /root/.ssh/authorized_keys ]]; then
    install -d -m 0700 -o "$USER_NAME" -g "$USER_NAME" "${HOME_DIR}/.ssh"
    install -m 0600 -o "$USER_NAME" -g "$USER_NAME" \
        /root/.ssh/authorized_keys \
        "${HOME_DIR}/.ssh/authorized_keys"
fi

###############################################################################
# Fish shell (optional)
###############################################################################

if [[ "$USE_FISH" -eq 1 ]]; then
    log "Set fish as default shell"

    fish_path="$(command -v fish || true)"
    if [[ -n "$fish_path" ]]; then
        grep -qx "$fish_path" /etc/shells || echo "$fish_path" >> /etc/shells
        chsh -s "$fish_path" "$USER_NAME" || true
    fi
else
    log "Skipping fish shell setup"
fi

###############################################################################
# SSH hardening
###############################################################################

set_sshd_kv () {
    local key="$1" value="$2" cfg="/etc/ssh/sshd_config"
    if grep -qiE "^[[:space:]]*${key}[[:space:]]+" "$cfg"; then
        sed -i -E "s/^[[:space:]]*${key}[[:space:]]+.*/${key} ${value}/I" "$cfg"
    else
        echo "${key} ${value}" >> "$cfg"
    fi
}

log "Hardening SSH"

cfg="/etc/ssh/sshd_config"
cp -a "$cfg" "${cfg}.bak.$(date +%Y%m%d-%H%M%S)"

set_sshd_kv PasswordAuthentication no
set_sshd_kv KbdInteractiveAuthentication no
set_sshd_kv ChallengeResponseAuthentication no
set_sshd_kv PubkeyAuthentication yes

sshd -t
systemctl reload ssh || systemctl reload sshd

###############################################################################
# Lock root password
###############################################################################

log "Lock root password"
passwd -l root >/dev/null || true

###############################################################################
# Node.js + npm + user-global npm bin path
###############################################################################

log "Installing Node.js + npm (NodeSource 20.x)"
apt-get install -y ca-certificates curl gpg

# Add NodeSource repo (idempotent)
install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
  | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
  > /etc/apt/sources.list.d/nodesource.list

apt-get update -y
apt-get install -y nodejs

log "Configuring npm global prefix for ${USER_NAME}"
NPM_PREFIX="${HOME_DIR}/.npm-global"
sudo -u "$USER_NAME" -H mkdir -p "${NPM_PREFIX}/bin"
sudo -u "$USER_NAME" -H npm config set prefix "$NPM_PREFIX"

log "Ensuring npm global bin is on PATH for bash/sh via /etc/profile.d"
cat >/etc/profile.d/npm.sh <<'EOF'
# npm user-global binaries
export PATH="$HOME/.npm-global/bin:$PATH"
EOF
chmod 0644 /etc/profile.d/npm.sh

log "Ensuring npm global bin is on PATH for fish via fish_user_paths"
if command -v fish >/dev/null 2>&1; then
  sudo -u "$USER_NAME" -H fish -c '
    if not contains "$HOME/.npm-global/bin" $fish_user_paths
      fish_add_path -U "$HOME/.npm-global/bin"
    end
  ' || true
fi

log "Verify node/npm in bash + fish for ${USER_NAME}"
sudo -u "$USER_NAME" -H bash -lc 'command -v node && node -v && command -v npm && npm -v'
if command -v fish >/dev/null 2>&1; then
  sudo -u "$USER_NAME" -H fish -c 'command -v node; node -v; command -v npm; npm -v' || true
fi

###############################################################################
# Fish aliases (optional)
###############################################################################

if [[ "$USE_FISH" -eq 1 ]]; then
    log "Configuring fish aliases"

    install -d -m 0755 -o "$USER_NAME" -g "$USER_NAME" \
        "${HOME_DIR}/.config/fish"

    cat > "${HOME_DIR}/.config/fish/config.fish" <<'FISH'

FISH

    chown "$USER_NAME:$USER_NAME" "${HOME_DIR}/.config/fish/config.fish"
fi

###############################################################################
# Shell PATH: npm global installs (~/.npm-global/bin)
###############################################################################

log "Configuring npm global PATH"

# Bash/login shells: ~/.profile
profile="$HOME_DIR/.profile"
install -m 0644 -o "$USER_NAME" -g "$USER_NAME" /dev/null "$profile" 2>/dev/null || true

npm_profile_block='
# npm global installs (user-local)
if [ -d "$HOME/.npm-global/bin" ]; then
  export PATH="$HOME/.npm-global/bin:$PATH"
fi
'

if ! grep -qs 'npm-global/bin' "$profile"; then
  printf "%s\n" "$npm_profile_block" >> "$profile"
  chown "$USER_NAME:$USER_NAME" "$profile"
fi

# Fish: ~/.config/fish/conf.d/npm.fish (only if fish enabled/used)
if [[ "${USE_FISH:-0}" -eq 1 ]]; then
  fish_conf_dir="$HOME_DIR/.config/fish/conf.d"
  install -d -m 0755 -o "$USER_NAME" -g "$USER_NAME" "$fish_conf_dir"

  fish_npm_file="$fish_conf_dir/npm.fish"
  if [[ ! -f "$fish_npm_file" ]] || ! grep -qs 'npm-global/bin' "$fish_npm_file"; then
    cat > "$fish_npm_file" <<'FISH'
# npm global installs (user-local)
if test -d "$HOME/.npm-global/bin"
    fish_add_path --prepend "$HOME/.npm-global/bin"
end
FISH
    chown "$USER_NAME:$USER_NAME" "$fish_npm_file"
    chmod 0644 "$fish_npm_file"
  fi
fi

###############################################################################
# Final checks
###############################################################################

log "FINAL CHECK"
getent passwd "$USER_NAME" || true
ls -ld "$HOME_DIR" || true
mount | grep -E " on /home " || true
log "Done."
