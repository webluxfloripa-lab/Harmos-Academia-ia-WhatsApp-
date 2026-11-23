# Continuidade — Harmos Conecta independente

23/11/2026. Código independente da hospedagem ChatGPT, em Vercel + Supabase.
Vercel: prj_LCs1MT0ukCrgCKBAmCbVsJL145N4, equipe team_FskQlf4GRN5BnU8HDwdfAyWP.
Supabase: msmdqdalkpxrboefkyjk. API server api/crm.js; conteúdo crm/domain.mjs; UI src/Conecta.tsx; SQL supabase/migrations.
Segredos permanecem em variáveis da Vercel e apenas hash no banco. Não salvar valor de HARMOS_API_SECRET em código ou ZIP.
Não usar cabeçalhos ChatGPT para autorizar. O bearer é verificado pelo Supabase e a função consulta auth.users e a allowlist de e-mails confirmados.
A pasta legacy é somente histórico, não entra no build. Fonte anterior não deve voltar a ser a dependência da aplicação nova.
Repositório canônico público: https://github.com/webluxfloripa-lab/Harmos-Academia-ia-WhatsApp-. Fonte publicada em main pelo conector GitHub. Vercel aceita implantações por gitSource neste repositório; não afirmar deploy automático contínuo sem confirmar a conexão nas configurações da Vercel.
