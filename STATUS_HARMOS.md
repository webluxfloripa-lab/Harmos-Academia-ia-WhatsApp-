# Harmos Conecta — migração independente — 23/11/2026

Infraestrutura: Vercel projeto harmos-conecta, equipe Daniel; Supabase projeto exclusivo harmos-conecta, ref msmdqdalkpxrboefkyjk, região sa-east-1.
Autenticação: e-mail/senha Supabase e allowlist em harmos_crm.admins, sem login ChatGPT.
Banco: PostgreSQL com schema privado, RLS, API pública invoker e implementação privada com segredo do servidor e autenticação adicional para gestão.
Origem: CRM D1 conferido; leads, eventos e conteúdo editado estavam sem registros. O projeto Supabase antigo do portal não está acessível à conexão atual; usuários e solicitações históricas daquele portal não foram verificados nem migrados.
Validação: 9 testes locais; build; transação PostgreSQL com rollback validando persistência, autorização, histórico, concorrência, conteúdo e exclusão. Advisors: nenhum WARN, somente INFO de RLS sem políticas nas tabelas privadas intencionalmente inacessíveis diretamente.
Pendências: configuração dos links de Auth e login interativo; instalação do script no domínio institucional.
Não há integração Meta, disparos, reservas reais ou cobranças.

Publicação Vercel concluída: https://harmos-conecta.vercel.app. Implantação dpl_88xmnztmJSzNfPUoFDLTM56ppDH9, estado READY. Verificação HTTP: conteúdo público e widget 200, leitura administrativa anônima 403. Captura pela API Vercel persistiu no Supabase; abertura de encaminhamento confirmada sem alterar etapa; registro QA excluído. Nenhuma mensagem enviada.

Repositório público criado pelo usuário e preenchido com 51 arquivos: https://github.com/webluxfloripa-lab/Harmos-Academia-ia-WhatsApp-. Verificação dos arquivos versionados não encontrou credenciais privadas ou arquivos .env reais. Uma implantação de produção foi iniciada a partir do commit GitHub. Segredos mantidos fora do repositório.

Distribuição independente de 23/11/2026: public/downloads/Harmos_Conecta_Projeto_Completo_2026-11-23.zip contém 85 arquivos, estrutura e fotografia do Supabase (zero registros de negócio/Auth/Storage), frontend efetivamente publicado, widget, restauração e licenças. Segredos de produção e estado efêmero excluídos. Integridade ZIP e nove testes locais aprovados; servidor Node opcional respondeu HTTP 200. O código original recebe licença MIT; direitos de ativos de terceiros preservados.
