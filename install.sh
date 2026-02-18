#!/usr/bin/env bash
# Metaskill Installer
# One command to install: curl -fsSL https://raw.githubusercontent.com/xvirobotics/metaskill/main/install.sh | bash

set -e

SKILL_DIR="$HOME/.claude/skills/metaskill"
REPO_URL="https://raw.githubusercontent.com/xvirobotics/metaskill/main/skill/SKILL.md"

echo "Installing Metaskill..."

mkdir -p "$SKILL_DIR"

if command -v curl &> /dev/null; then
  curl -fsSL "$REPO_URL" -o "$SKILL_DIR/SKILL.md"
elif command -v wget &> /dev/null; then
  wget -q "$REPO_URL" -O "$SKILL_DIR/SKILL.md"
else
  echo "Error: curl or wget is required."
  exit 1
fi

echo ""
echo "Metaskill installed to $SKILL_DIR/SKILL.md"
echo ""
echo "Usage: Open Claude Code and type:"
echo "  /metaskill fullstack web app"
echo "  /metaskill ios app with SwiftUI"
echo "  /metaskill data science pipeline"
echo ""
