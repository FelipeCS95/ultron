#!/bin/bash

geniotec_admin::deploy() {
  local commit_sha
  commit_sha=$(git rev-parse HEAD 2>/dev/null)

  if [[ -z "$commit_sha" ]]; then
    echo "Erro: não está num repositório git" >&2
    return 1
  fi

  local image="ghcr.io/felipecs95/geniotec-admin:${commit_sha}"

  if docker manifest inspect "$image" >/dev/null 2>&1; then
    echo "Imagem já existe no GHCR para ${commit_sha:0:7} — pulando build"
    bin/kamal deploy --skip-push
  else
    echo "Buildando imagem para ${commit_sha:0:7}..."
    bin/kamal deploy
  fi

  docker rm -f buildx_buildkit_kamal-local-docker-container0 2>/dev/null && \
    echo "Builder buildkit removido" || true
}
