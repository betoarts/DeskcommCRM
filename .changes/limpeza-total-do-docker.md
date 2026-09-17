---
impacto: capacidade_nova
secao: adicionado
titulo: Desinstalador Docker remove somente a aplicacao atual
---

O desinstalador na raiz agora seleciona containers, volumes e redes pelos labels
do projeto Docker Compose atual. Outras aplicacoes do mesmo servidor, imagens,
cache de build, redes externas do proxy, codigo, `.env`, backups e bancos
Supabase externos sao preservados. A operacao continua exigindo confirmacao
explicita e oferece `--force` para automacao.
