#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$SSH_DIR"

if [[ -z "${KEYS:-}" ]]; then
  echo "❌ KEYS variable is empty or unset"
  exit 1
fi

# 🔃 Parsowanie KEYS jako tablicy
IFS=$'\n' KEYS_ARRAY=()
while IFS= read -r line; do
  KEYS_ARRAY+=("$line")
done <<< "$KEYS"

# 🔍 Sprawdź brakujące
MISSING=()
for entry in "${KEYS_ARRAY[@]}"; do
  entry="$(echo "$entry" | xargs)"
  ref="${entry%%:::*}"
  filename="${entry#*:::}"
  path="$SSH_DIR/$filename"

  if [[ -f "$path" ]]; then
    echo "🔐 $filename already exists at $path"
  else
    echo "❌ $filename is missing"
    MISSING+=("$entry")
  fi
done

# ✅ Jeśli wszystkie są, wyjdź
if [[ "${#MISSING[@]}" -eq 0 ]]; then
  echo "✅ All SSH keys are already present."
  exit 0
fi

# 🔐 Zaloguj się do 1Password
echo "🔐 Logging into 1Password..."
export NIXPKGS_ALLOW_UNFREE=1
SESSION=$(nix run --impure nixpkgs#_1password-cli -- signin --account "my.1password.com" --raw)

# 📥 Pobierz brakujące
for entry in "${MISSING[@]}"; do
  ref="${entry%%:::*}"
  filename="${entry#*:::}"
  path="$SSH_DIR/$filename"

  echo "📥 Downloading $filename from 1Password..."
  nix run --impure nixpkgs#_1password-cli -- read "$ref" --session "$SESSION" > "$path"
  chmod 600 "$path"

  echo "🔑 Generating public key..."
  ssh-keygen -y -f "$path" > "${path}.pub"

  if [[ -z "${SSH_AUTH_SOCK:-}" ]] || ! ssh-add -l >/dev/null 2>&1; then
    echo "🟡 Starting ssh-agent..."
    eval "$(ssh-agent -s)"
  fi

  if ssh-add -l | grep -q "$path"; then
    echo "🔐 $filename already added to ssh-agent."
  else
    echo "➕ Adding $filename to ssh-agent..."
    ssh-add "$path"
  fi

  echo "✅ $filename imported successfully"
done

echo "🎉 All keys are now imported to $SSH_DIR"

