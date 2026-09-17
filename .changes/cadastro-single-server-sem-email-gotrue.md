---
impacto: nada_mudou
secao: corrigido
titulo: Cadastro no servidor único não depende do e-mail de confirmação do Supabase
---

O instalador de servidor único agora confirma automaticamente o e-mail no Auth
local. A solicitação para criar ou entrar em uma empresa continua passando pela
fila de aprovação da aplicação, e os avisos continuam sendo enviados pelo SMTP
interno configurado pelo operador.
