#!/usr/bin/env bash
set -euo pipefail
mkdir -p dist/diagrams
# Dependências (uma vez): brew install pandoc node
# Depois: npm install
npm run build
echo "Abrindo PDF..."
open dist/ebook.pdf || true
