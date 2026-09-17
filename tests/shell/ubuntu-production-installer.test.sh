#!/usr/bin/env bash
# Testes sem efeitos colaterais para a porta de entrada de produção.

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/ubuntu-production-installer.sh"
FAILS=0

check() {
  local descricao="$1"
  shift
  if "$@"; then
    printf '  ✓ %s\n' "$descricao"
  else
    printf '  ✗ %s\n' "$descricao"
    FAILS=$((FAILS + 1))
  fi
}

echo "instalador Ubuntu de produção"
check "sintaxe Bash válida" bash -n "$SCRIPT"

ajuda="$(bash "$SCRIPT" --help 2>&1)"
check "--help termina sem preparar o host" test "$?" -eq 0
check "ajuda explica a entrevista de domínio" grep -q "pergunta o domínio" <<<"$ajuda"
check "ajuda distingue os serviços locais" grep -q "Serviços locais em Docker" <<<"$ajuda"
check "ajuda explica que --yes exige .env" grep -q "exige um .env previamente preenchido" <<<"$ajuda"

saida_invalida="$(bash "$SCRIPT" --desconhecido 2>&1)"
rc_invalido=$?
check "opção desconhecida é recusada" test "$rc_invalido" -eq 2
check "recusa mostra o uso" grep -q "Uso: bash ubuntu-production-installer.sh" <<<"$saida_invalida"

check "delega ao instalador self-host canônico" \
  grep -q 'hostgator-setup-kit/install.sh' "$SCRIPT"
check "não mantém uma segunda lista de variáveis do .env" \
  bash -c '! grep -qE "^(DOMAIN|SUPABASE_DB_URL|WAHA_API_KEY|INTERNAL_SECRET)=" "$1"' _ "$SCRIPT"

if [[ "$FAILS" -ne 0 ]]; then
  printf '\n%d teste(s) falharam.\n' "$FAILS"
  exit 1
fi

printf '\nTodos os testes do instalador Ubuntu passaram.\n'
