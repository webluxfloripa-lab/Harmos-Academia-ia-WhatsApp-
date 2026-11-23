# Verificação da primeira etapa

- Typecheck e build: passaram.
- Testes de domínio: 2 passaram.
- Banco: persistência do proprietário, leitura isolada, escrita cruzada negada, autopromoção negada, status forjado negado, duplicidade bloqueada, leitura pública de planos e alteração por equipe comercial passaram. Fixtures totalmente revertidas por ROLLBACK.
- Supabase Security Advisors: nenhum aviso retornado.
- npm audit --omit=dev: zero vulnerabilidades reportadas.
- Navegador desktop: hero renderizado, dados reais de planos carregados, seleção encaminha para autenticação e retorno ao início funciona.
- Não verificado: login real, recebimento de e-mail, recuperação completa, portal autenticado no navegador, cinco resoluções, acessibilidade completa, PWA instalável e offline.
- Cadastro comercial, cobrança, contrato e acesso físico não ativados.

Limitação externa: o conector disponível não expõe configuração de URLs de Auth; configurar Site URL e allowlist de redirecionamentos no projeto Supabase para a URL publicada. Não afirmar que e-mails/retornos estão configurados.
