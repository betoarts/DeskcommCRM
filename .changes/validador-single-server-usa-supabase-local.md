---
impacto: nada_mudou
secao: corrigido
titulo: Instalação single-server não exige HTTPS antes de iniciar o proxy
---

Ao instalar tudo na mesma VPS, o validador agora confirma o Supabase pelo
gateway local já iniciado. Antes, ele tentava acessar o domínio público antes
do Caddy ser criado e interrompia a instalação mesmo com o Supabase saudável.
