#!/usr/bin/env bash
set -euo pipefail

# ✅ Sprawdź, czy klucz już jest
if gpg --list-secret-keys | grep -q "$FINGERPRINT"; then
  echo "🔐 GPG key already present. Exiting."
  exit 0
fi

echo "📦 Importing 1Password CLI temporarily via nix..."
export NIXPKGS_ALLOW_UNFREE=1

# 🔐 Logowanie do 1Password
echo "🔐 Signing in to 1Password..."
SESSION=$(nix run --impure nixpkgs#_1password-cli -- signin --account "my.1password.com" --raw)

echo "📥 Fetching GPG key from 1Password..."
TMP_KEY=$(mktemp)
nix run --impure nixpkgs#_1password-cli -- document get "$ITEM_ID" --session "$SESSION" --out-file "$TMP_KEY"

# 🔑 Import do GPG
gpg --import "$TMP_KEY"
shred -u "$TMP_KEY"

echo "✅ Key imported successfully."
