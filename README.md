# Harmos Conecta

CRM e chatbot da Harmos com hospedagem Vercel, banco PostgreSQL e autenticação Supabase. Sem dependência de login ou runtime do ChatGPT. WhatsApp usa apenas wa.me, sem integração Meta.

## Desenvolvimento
Node 22. npm ci; npm test; npm run build. A hospedagem Vercel compila React/Vite e publica api/crm.js como função Node.

## Banco e segurança
Projeto Supabase exclusivo harmos-conecta (msmdqdalkpxrboefkyjk), em São Paulo. Migrações em supabase/migrations. Tabelas do CRM ficam no schema privado harmos_crm, com RLS e sem acesso direto de anon/authenticated. Uma função RPC restrita valida o segredo do servidor e, para gestão, a identidade Supabase e o e-mail confirmado na allowlist. O segredo não substitui a autenticação do gestor. API pública tem validação de origem, limites e autorização explícita de registro.

## Configuração de servidor
SUPABASE_URL, SUPABASE_ANON_KEY, HARMOS_API_SECRET somente na Vercel. O segredo deve corresponder ao SHA256 da linha api_hash de harmos_crm.settings. Não armazenar o valor no Git. Nunca usar uma chave administrativa no cliente.

## Operação
/atendimento para visitante, /crm para equipe, /chat para iframe e /privacidade-atendimento para aviso de dados.
A conta autorizada cria seu acesso por e-mail e senha e confirma o e-mail. Não há senha padrão. Em um Supabase novo, configure Site URL e URLs de retorno para a URL Vercel em Authentication > URL Configuration antes de usar links de confirmação e recuperação. Mesmo que o link retorne a outro endereço, a confirmação deve ser feita; depois volte ao CRM.

Allowlist de gestão: harmos_crm.admins. Inserir o e-mail exato por canal administrativo seguro. Excluir da lista revoga imediatamente a autorização consultada no banco.

Widget: incluir o script /harmos-widget.js da URL Vercel antes de fechar body no site institucional. O script deriva a URL base de seu próprio src, sem redirecionar para ChatGPT. Aceita os domínios institucionais Harmos e a própria hospedagem para o iframe.

## Limites
Atendente por conteúdo guiado e palavras-chave. Sem IA generativa, disparos, integração Pacto ou agenda de reservas. Clique WhatsApp não comprova envio. Matrículas são confirmadas manualmente. Acompanhamentos são tarefas internas.

## Cópias e migração
A pasta legacy preserva o código anterior D1 apenas como referência de migração. Não é usada pelo build nem pelo serviço publicado. Ao verificar a origem, CRM e base editada estavam sem registros: nenhuma conversa foi perdida. O portal Supabase anterior não ficou acessível à conexão atual; não foi possível verificar usuários e solicitações históricas daquele projeto. O código do portal agora aponta para o novo Supabase; dados históricos exigem exportação autorizada da origem.

## Continuidade
Código e configurações ficam nesta cópia completa. Código publicado no repositório público https://github.com/webluxfloripa-lab/Harmos-Academia-ia-WhatsApp-. A Vercel recebeu uma implantação a partir do commit GitHub. A publicação por commit está verificada; a conexão contínua para deploy automático ainda precisa ser configurada no projeto Vercel. Backups do banco devem ser feitos no Supabase; o ZIP de código não contém dados de alunos nem credenciais de servidor.

## Download completo independente

[Baixar projeto completo em ZIP](https://harmos-conecta.vercel.app/downloads/Harmos_Conecta_Projeto_Completo_2026-11-23.zip), incluindo fonte, estrutura/dados de negócio do Supabase, frontend publicado, configuração Vercel, widget e instruções de restauração. O arquivo também está em public/downloads neste repositório. Consulte public/downloads/README.md para escopo e checksum.

O código original agora está sob MIT. Ativos de terceiros mantêm os direitos descritos em THIRD_PARTY_NOTICES.md.
