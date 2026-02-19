#!/usr/bin/env bash
# Metaskill Installer
# One command to install: curl -fsSL https://raw.githubusercontent.com/xvirobotics/metaskill/main/install.sh | bash

set -e

BASE_URL="https://raw.githubusercontent.com/xvirobotics/metaskill/main"

SKILLS=(
  "metaskill:skill/SKILL.md"
  "create-agent:skills/create-agent/SKILL.md"
  "create-skill:skills/create-skill/SKILL.md"
)

echo "Installing Metaskill suite..."

for entry in "${SKILLS[@]}"; do
  name="${entry%%:*}"
  path="${entry#*:}"
  dest="$HOME/.claude/skills/$name/SKILL.md"

  mkdir -p "$(dirname "$dest")"

  if command -v curl &> /dev/null; then
    curl -fsSL "$BASE_URL/$path" -o "$dest"
  elif command -v wget &> /dev/null; then
    wget -q "$BASE_URL/$path" -O "$dest"
  else
    echo "Error: curl or wget is required."
    exit 1
  fi

  echo "  Installed /$name → $dest"
done

echo ""
echo "All skills installed successfully!"
echo ""
echo "Usage: Open Claude Code and type:"
echo "  /metaskill fullstack web app       — generate a full agent team"
echo "  /create-agent security reviewer    — create a custom agent"
echo "  /create-skill deploy to production — create a custom skill"
echo ""
