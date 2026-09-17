#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ENV_FILE="${LOCAL_ENV_FILE:-.env.local}"
if [[ ! -f "$ENV_FILE" ]]; then
  printf 'Erro: %s não existe. Execute o instalador da VM primeiro.\n' "$ENV_FILE" >&2
  exit 1
fi

./scripts/local-env.sh ensure

if [[ "${1:-}" == "--restart" ]]; then
  ./scripts/local-stack.sh up
else
  printf 'Web Push configurado em %s.\n' "$ENV_FILE"
  printf 'Para aplicar no Docker local/VM: bash scripts/local-stack.sh up\n'
fi
