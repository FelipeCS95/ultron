#!/bin/bash

PACKAGE_INFO=(claude)
REQUIRED_PACKAGES=(curl)

install() {
  curl -fsSL https://claude.ai/install.sh | bash
}

remove() {
  npm uninstall -g @anthropic-ai/claude-code
}
