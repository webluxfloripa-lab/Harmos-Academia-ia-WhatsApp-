# Arquitetura inicial

React 19 + TypeScript + Vite. Aplicação estática Sites/Cloudflare, backend Supabase Auth e PostgREST/PostgreSQL. Sem serviço privilegiado intermediário; todas as operações de dados usam o token do usuário e RLS. Essa decisão reduz a infraestrutura do primeiro fluxo e preserva a possibilidade de adicionar serviços TypeScript para pagamentos e integrações.

Rotas hash: início, harmos, estrutura, planos, aulas, localização, portal, matrícula, admin e recuperação de senha. Não há renderização servidor nesta etapa.

Tabelas: harmos_plans (leitura pública dos ativos), harmos_profiles (próprio usuário e equipe autorizada), harmos_staff (apenas leitura do próprio papel), harmos_enrollment_requests (próprio usuário e equipe comercial). Projeto de uma academia; isolamento multiacademia ainda não implementado.

Papéis previstos no esquema: SUPER_ADMIN, ADMIN_ACADEMIA, GESTOR_FINANCEIRO, RECEPCAO, COMERCIAL, PROFESSOR. Aluno é a conta sem papel de equipe. Não conceder papéis por user_metadata. GESTOR_FINANCEIRO e PROFESSOR não recebem acesso ao fluxo comercial por padrão.

Snapshot reproduzível em database/schema.sql; não há histórico de migrações CLI registrado nesta etapa. Antes de evoluir schema, gerar e versionar migrações sem reaplicar o snapshot no banco ativo.
