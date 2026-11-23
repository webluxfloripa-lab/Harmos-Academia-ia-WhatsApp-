# Mapa funcional

| Módulo | UI / API / Persistência | Testes | Estado |
|---|---|---|---|
| Site e planos | React / PostgREST / PostgreSQL | Build, navegador e leitura anônima | PARCIAL: responsividade não validada nas cinco resoluções |
| Auth | Formulário / Supabase Auth / auth.users | Formulário e encaminhamento verificados; e-mail e login real pendentes | IMPLEMENTADO, NÃO TESTADO de ponta a ponta |
| Perfil | Formulário / PostgREST / harmos_profiles | Teste transacional RLS e validação | PARCIAL: E2E autenticado pendente |
| Solicitação | Escolha e histórico / PostgREST / harmos_enrollment_requests | Persistência, isolamento e duplicidade | PARCIAL: E2E autenticado pendente |
| Gestão comercial | Painel / PostgREST / solicitações | Papel comercial lê e atualiza no teste de banco | PARCIAL: sem usuário gestor provisionado |
| Contratos e pagamento | Não implementados | Não executados | NÃO INICIADO |
| CRM completo, treinos, avaliações e reservas | Não implementados | Não executados | NÃO INICIADO |
| Acesso físico e biometria | Não implementados | Não executados | NÃO INICIADO |
| Automações e notificações | Não implementadas; desativadas | Não executados | NÃO INICIADO |
