# Harmos Conecta

## Abrir
- Atendimento: /atendimento
- Painel: /crm
- Widget compacto: /chat
- Privacidade: /privacidade-atendimento

O site publicado da plataforma Harmos recebe o widget automaticamente. Para inserir no domínio institucional harmosacademia.com.br, incluir antes de fechar body:

```html
<script src="https://harmos-conecta.vercel.app/harmos-widget.js" defer></script>
```

O script usa Shadow DOM e iframe para não alterar os estilos do site. O iframe permite harmosacademia.com.br, www.harmosacademia.com.br e o próprio serviço. Para outro domínio, revisar frame-ancestors no Worker. Não configurar CORS aberto para dados administrativos.

## WhatsApp
Destino: +55 41 98872-0401, conferido no site institucional em 23/11/2026. Usa apenas wa.me com texto codificado. Visitante revisa e confirma o envio no aplicativo. Não há integração com a Meta, disparo, leitura de mensagens, confirmação de entrega ou sincronização do histórico do WhatsApp.

## Acesso da equipe
Login Supabase por e-mail e senha. A tabela privada harmos_crm.admins contém os e-mails autorizados. A ausência da configuração bloqueia o painel e todas as APIs administrativas. O servidor exige identidade autenticada e e-mail autorizado. A conta proprietária foi configurada; a conta de Daniel precisa ser identificada antes de adicioná-la. Nunca promover visitante a administrador.

## Funcionamento
Chatbot guiado por temas e reconhecimento simples de palavras, sem modelo de IA externo e sem custos de tokens. Base de conhecimento editável em /crm. Informações comerciais específicas exigem revisão da equipe. Sem integração com Pacto, catracas, pagamentos ou agenda. Pedidos de visita são solicitações, não reservas. Etapa Matriculado é marcada manualmente pela equipe.

Solicitação só persiste no Supabase se o visitante marcar autorização. Sem marcar, o resumo é gerado na página e o WhatsApp continua disponível. Não há rastreamento de visitas individuais ou captura silenciosa de conversas. A origem salva é um identificador de campanha; não a URL bruta. Não incluir dados pessoais nos identificadores. Logs de abuso usam hash do IP com prazo de limpeza do registro.

## Operação
1. Revisar os conteúdos em Conteúdo do chatbot.
2. Abrir Atendimentos, filtrar perfil e assunto pela busca.
3. Clicar no contato para mudar etapa, responsável, prazo e anotações.
4. Conferir histórico e diferenciar abertura do WhatsApp de envio efetivo.
5. Usar CSV quando necessário (até 10 mil registros; painel até mil mais recentes).
6. Pedidos de exclusão podem ser atendidos no detalhe do registro, com confirmação. A exclusão do CRM não apaga mensagens no WhatsApp.

Acompanhamentos e prazos são internos: nenhum envio futuro está agendado. Métricas não representam todo o cadastro de alunos nem receita total da academia.

## Testes e infraestrutura
npm test: 9 testes de domínio e API Vercel aprovados. Uma transação PostgreSQL com rollback verificou autorização, persistência, encaminhamento, gestão, concorrência, conteúdo e exclusão, sem deixar dados de teste. Build TypeScript + Vite. Banco Supabase exclusivo. A origem D1 foi conferida e estava sem registros.

Rollback: republicar a versão anterior do site se necessário. Não excluir as novas tabelas; a versão anterior não as utiliza. Dados e configuração ficam disponíveis para diagnóstico e retomada.
