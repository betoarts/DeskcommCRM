#!/usr/bin/env bash
#
# Remove todos os recursos do daemon Docker selecionado: containers, imagens,
# volumes, redes personalizadas e cache de build. O Docker em si permanece
# instalado; este script nao remove configuracoes do daemon nem credenciais.

set -Eeuo pipefail

readonly CONFIRMACAO="ZERAR-DOCKER"

uso() {
  cat <<'EOF'
Uso: bash unistall_docker.sh [--force]

Para todos os recursos do daemon Docker atualmente selecionado:
  1. para e remove todos os containers;
  2. remove todas as imagens e todos os volumes (inclusive bancos de dados);
  3. remove redes Docker personalizadas e o cache de build.

O Docker continua instalado. Redes internas padrao (bridge, host e none),
configuracoes do daemon e credenciais locais nao sao removidas.

Sem --force, digite ZERAR-DOCKER para confirmar a operacao irreversivel.
EOF
}

falhar() {
  printf 'Erro: %s\n' "$*" >&2
  exit 1
}

forcar=false
case "${1:-}" in
  "") ;;
  --force) forcar=true ;;
  -h|--help)
    uso
    exit 0
    ;;
  *)
    uso >&2
    exit 2
    ;;
esac

command -v docker >/dev/null 2>&1 || falhar "Docker nao esta instalado ou nao esta no PATH."
docker info >/dev/null 2>&1 || falhar "Nao foi possivel acessar o daemon Docker atual."

contexto="$(docker context show 2>/dev/null || true)"
printf 'Daemon Docker selecionado: %s\n' "${contexto:-desconhecido}"
printf '\nATENCAO: esta operacao apaga todos os dados Docker desse daemon, incluindo volumes de banco de dados.\n'
printf 'Ela nao pode ser desfeita.\n\n'

if [[ "$forcar" != true ]]; then
  read -r -p "Digite ${CONFIRMACAO} para continuar: " resposta
  [[ "$resposta" == "$CONFIRMACAO" ]] || falhar "Operacao cancelada."
fi

mapfile -t containers_em_execucao < <(docker container ls -q)
if ((${#containers_em_execucao[@]})); then
  printf 'Parando %d container(s)...\n' "${#containers_em_execucao[@]}"
  docker container stop "${containers_em_execucao[@]}"
else
  printf 'Containers em execucao: nenhum.\n'
fi

mapfile -t todos_containers < <(docker container ls -aq)
if ((${#todos_containers[@]})); then
  printf 'Removendo %d container(s)...\n' "${#todos_containers[@]}"
  docker container rm -f "${todos_containers[@]}"
else
  printf 'Containers: nada para remover.\n'
fi

mapfile -t todos_volumes < <(docker volume ls -q)
if ((${#todos_volumes[@]})); then
  printf 'Removendo %d volume(s)...\n' "${#todos_volumes[@]}"
  docker volume rm -f "${todos_volumes[@]}"
else
  printf 'Volumes: nada para remover.\n'
fi

mapfile -t todas_imagens < <(docker image ls -aq)
if ((${#todas_imagens[@]})); then
  printf 'Removendo %d imagem(ns)...\n' "${#todas_imagens[@]}"
  docker image rm -f "${todas_imagens[@]}"
else
  printf 'Imagens: nada para remover.\n'
fi

printf 'Removendo redes Docker personalizadas nao utilizadas...\n'
docker network prune --force

printf 'Removendo cache de build...\n'
docker builder prune --all --force

printf 'Executando limpeza final de recursos sem uso...\n'
docker system prune --all --volumes --force

printf '\nLimpeza concluida. O daemon Docker permanece instalado.\n'
