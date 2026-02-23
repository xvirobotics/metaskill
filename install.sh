#!/usr/bin/env bash
# Metaskill Installer
# One command to install: curl -fsSL https://raw.githubusercontent.com/xvirobotics/metaskill/main/install.sh | bash

set -e

BASE_URL="https://raw.githubusercontent.com/xvirobotics/metaskill/main"
DEST_DIR="$HOME/.claude/skills/metaskill"

FILES=(
  "skill/SKILL.md:SKILL.md"
  "skill/flows/team.md:flows/team.md"
  "skill/flows/agent.md:flows/agent.md"
  "skill/flows/skill.md:flows/skill.md"
)

echo "Installing Metaskill..."

for entry in "${FILES[@]}"; do
  src="${entry%%:*}"
  dest="$DEST_DIR/${entry#*:}"

  mkdir -p "$(dirname "$dest")"

  if command -v curl &> /dev/null; then
    curl -fsSL "$BASE_URL/$src" -o "$dest"
  elif command -v wget &> /dev/null; then
    wget -q "$BASE_URL/$src" -O "$dest"
  else
    echo "Error: curl or wget is required."
    exit 1
  fi

  echo "  Installed $dest"
done

echo ""
echo "Metaskill installed successfully!"
echo ""
echo "Usage: Open Claude Code and type:"
echo "  /metaskill fullstack web app       — generate a full agent team"
echo "  /metaskill a security reviewer agent — create a single agent"
echo "  /metaskill a deploy skill            — create a single skill"
echo ""
