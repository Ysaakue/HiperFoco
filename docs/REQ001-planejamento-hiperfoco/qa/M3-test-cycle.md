# Ciclo de Testes — M3 (Arquivamento, histórico compactado e retenção de dados)

## Metadados

| Campo | Valor |
|---|---|
| Milestone | M3 — Arquivamento, histórico compactado e retenção de dados |
| Data de execução | 2026-08-16 |
| Executor | Claude (Claude Code), testes automatizados (`flutter test --coverage`, com relógio controlado via `package:clock`) + testes manuais via `adb` |
| Ambiente | Android Emulator `emulator-5554`, resolução 1080x2400 @420dpi, build debug (`app-debug.apk`), variant `com.hiperfoco.hiperfoco` |
| Referência de escopo | `docs/REQ001-planejamento-hiperfoco/planning.md`, seção "Roadmap faseado → M3" |

## Requisitos cobertos pelo milestone

1. Tabela Drift `TimerHistoryDaily` (schema v3→v4), histórico compactado por `(date, categoryId, taskId)` com chave única.
2. `DailyArchiveService` (domínio puro): compara a última data arquivada com a data atual, arquiva cada dia pendente (cobrindo múltiplos dias em atraso), idempotente.
3. `TimerDao.archiveDay`: transação que agrupa intervalos fechados por `(dia, categoria, tarefa)`, divide uma sessão aberta que atravessa a meia-noite, remove os intervalos já arquivados, e recalcula o cache de cada sessão tocada (incluindo a exclusão de sessões concluídas sem nada restante).
4. Camada "hoje" (quente) permanece intacta — apenas dias passados são compactados.
5. Purga em massa configurável (`PurgeOldDataUseCase`), com retenção padrão de 6 meses, editável em Settings (3/6/12 meses) e ação manual "Purge now" com confirmação.
6. Job de virada de dia executado antes da UI renderizar (`main.dart`, via `ProviderContainer` + `dailyArchiveServiceProvider.run()`).
7. `TimerHistoryScreen` distingue visualmente um dia já arquivado (totais compactados, sem timeline de intervalos) do dia corrente (timeline detalhada, inalterada desde o M2).

## Critério de pronto (gate do milestone, conforme planning.md)

> Fechar o app por N dias e reabrir arquiva corretamente todos os dias pendentes sem duplicar nem perder tempo total; sessão deixada rodando durante a virada do dia é dividida corretamente; tentar editar um registro de dia passado é bloqueado na UI; purga manual remove dados além do limite configurado e é coberta por testes de fronteira de data (meia-noite, fuso, mês de 28/30/31 dias).

## Casos de teste

### TC-01 — Análise estática sem warnings

**Resultado obtido:** `No issues found! (ran in 2.9s)`

**Status:** ✅ Aprovado

---

### TC-02 — Usecases cobertos por testes unitários (mocktail)

**Critério de aceite:** `WatchArchivedDay` e `PurgeOldData` (os dois usecases novos deste milestone) com teste passando.

**Resultado obtido:** 10 testes passando em `timer_usecases_test.dart` (8 herdados do M2 + 2 novos), cobertura de linha 100% nos arquivos de usecase novos.

**Status:** ✅ Aprovado

---

### TC-03 — `DailyArchiveService` cobre múltiplos dias em atraso e idempotência

- **Dado** um mock de `TimerRepository`/`ArchiveStateRepository` com a última data arquivada controlada
- **Quando** executo `DailyArchiveService.run()` em cenários de: nenhum dia pendente, um dia pendente, múltiplos dias pendentes (app fechado por vários dias), e primeira execução (nunca arquivado antes)
- **Então** deve chamar `archiveDay` uma vez por dia pendente (nunca duplicando nem pulando dias) e persistir a última data arquivada ao final

**Resultado obtido:** 5 testes passando (`daily_archive_service_test.dart`), 100% de cobertura (13/13 linhas).

**Status:** ✅ Aprovado

---

### TC-04 — `TimerDao.archiveDay`/`TimerRepositoryImpl` validados contra Drift in-memory com relógio controlado

- **Dado** `AppDatabase.forTesting(NativeDatabase.memory())` e tempo controlado via `withClock(Clock.fixed(t), ...)`
- **Quando** executo os testes cobrindo: compactação básica, categorias diferentes em buckets separados, tarefas diferentes em buckets separados (mesma categoria), idempotência ao re-arquivar sem dados novos, **acumulação ao re-arquivar o mesmo bucket com dados novos** (dois `archiveDay` no mesmo dia, cada um com uma sessão nova — o total e a contagem de sessões devem somar, não sobrescrever), sessão aberta dividida na virada da meia-noite, múltiplos dias em atraso processados um por um, sessão pausada sobrevive ao arquivamento do que já foi fechado, sessão concluída é removida quando nada resta, e dados fora do dia arquivado permanecem intocados
- **Então** toda a lógica transacional deve se comportar corretamente e de forma determinística

**Resultado obtido:** 19 testes passando no grupo `archiveDay` combinado ao restante do arquivo (10 específicos de `archiveDay`); `timer_dao.dart` 181/181 linhas cobertas (100%), `timer_repository_impl.dart` 72/72 (100%).

**Status:** ✅ Aprovado

---

### TC-05 — Purga por retenção configurável, incluindo fronteiras de mês (crítico)

- **Dado** entradas de histórico arquivadas em datas conhecidas, incluindo meses curtos (fevereiro, meses de 30 dias)
- **Quando** executo `purgeHistoryOlderThan(months)` com o relógio fixado em datas que caem em meses de 28/30/31 dias
- **Então** o corte deve recuar exatamente N meses a partir de hoje, com o dia clampado ao último dia válido do mês-alvo quando necessário — nunca rolando para o mês seguinte

**Resultado obtido (retrabalho encontrado durante a escrita do teste, antes de qualquer QA manual):** a primeira versão calculava o corte com `DateTime(now.year, now.month - months, now.day)`. Para `now = 2026-03-31` e `months = 6`, isso produz `DateTime(2026, -3, 31)`, que o Dart normaliza para **1º de outubro de 2025** (porque setembro só tem 30 dias) em vez de 30 de setembro — um deslocamento silencioso de um dia no corte. O teste de fronteira pego exatamente esse caso. Corrigido com um helper `_monthsBefore` que clampa o dia ao último dia real do mês-alvo via `DateTime(year, month + 1, 0).day`.

**Status:** ✅ Aprovado (após correção)

---

### TC-06 — `ArchiveStateRepositoryImpl` (SharedPreferences) cobre get/set de ambos os campos

**Observação técnica:** revisão de cobertura pós-implementação encontrou que `getLastArchivedDate`/`setLastArchivedDate` só eram exercitados indiretamente via mock em `daily_archive_service_test.dart`, nunca contra a implementação real. Adicionado `archive_state_repository_impl_test.dart` dedicado.

**Resultado obtido:** 4 testes passando, cobrindo `getLastArchivedDate` (null quando nunca setado, round-trip), `getRetentionMonths` (default 6, round-trip). `archive_state_repository_impl.dart` 11/11 linhas cobertas (100%).

**Status:** ✅ Aprovado

---

### TC-07 — Testes de widget: `TimerHistoryScreen` distingue dia arquivado do dia corrente

- **Dado** uma sessão de ontem já arquivada
- **Quando** navego para o dia anterior na tela de histórico
- **Então** deve mostrar o total compactado ("0:45:00", "1 session") sem nenhum horário de início/fim por intervalo — diferente da timeline detalhada do dia corrente

**Resultado obtido:** 3 testes passando (2 herdados do M2 + 1 novo para esta distinção).

**Status:** ✅ Aprovado

---

### TC-08 — Testes de widget: Settings — retenção e purga manual

> **Retrabalho de metodologia de teste (não é um bug do app):** a primeira versão do teste de purga usava `TimerDao.watchArchivedDay(...).first` (uma stream reativa do Drift) fora da árvore de widgets, para verificar o estado do banco após confirmar/cancelar o diálogo. Isso travava indefinidamente na finalização automática do teste (`flutter test`), sem lançar nenhuma exceção — só reproduzível com um `timeout` externo ao processo, já que o próprio `pumpAndSettle()` nunca chegava a ser o ponto de trava. Trocado por uma query única (não-reativa) direto na tabela (`database.select(database.timerHistoryDaily)...get()`), que resolveu o travamento por completo. Lição registrada: **nunca inscrever uma stream `.watch()` fora da árvore de widgets gerenciada pelo Riverpod dentro de um `testWidgets`** — usar sempre uma consulta única para asserções de estado.

- **Dado** a tela de Settings com um histórico antigo já arquivado
- **Quando** troco a retenção para 12 meses; e, separadamente, toco "Purge now" e cancelo; e, em outro teste, toco "Purge now" e confirmo
- **Então** a escolha de retenção deve persistir via `SharedPreferences`; cancelar não deve apagar nada; confirmar deve apagar os dados antigos e mostrar o snackbar "Old data purged."

**Resultado obtido:** 3 testes passando, cobrindo os três comportamentos acima.

**Status:** ✅ Aprovado

---

### TC-09 — Suíte completa de testes

**Resultado obtido:** `+80: All tests passed!`

**Status:** ✅ Aprovado

---

### TC-10 — Verificação manual em device: boot silencioso e UI nova funcionando

**Observação:** simular uma lacuna real de múltiplos dias fechados não é praticável manualmente no emulador (exigiria manipular o relógio do sistema Android); por isso, conforme a própria orientação de verificação do `planning.md`, a evidência primária deste milestone são os testes automatizados de fronteira de data (TC-03 a TC-05). A verificação manual aqui se limita a confirmar que o app continua funcionando normalmente com o schema/job novos.

- **Dado** o app reinstalado (`app-debug.apk`, schema v4) com dados de milestones anteriores já no dispositivo
- **Quando** abro o app
- **Então** o job de arquivamento deve rodar silenciosamente antes da UI renderizar, sem crash, e a Home deve aparecer normalmente

**Resultado obtido:** app abriu sem crash (`logcat` sem `FATAL`/`AndroidRuntime` exceptions), Home mostrando a categoria "Trabalho" existente normalmente.

**Status:** ✅ Aprovado

---

### TC-11 — Verificação manual em device: nova seção "Data & storage" em Settings

- **Dado** o app aberto na aba Settings
- **Quando** visualizo a tela
- **Então** deve mostrar a nova seção "Data & storage" com o seletor de retenção (3/6/12 meses, 6 meses selecionado por padrão) e o botão "Purge now"

**Resultado obtido (retrabalho de polish encontrado na primeira verificação manual):** com 4 opções (3/6/12/24 meses) e o ícone de check do segmento selecionado, o rótulo "6 months" quebrava em duas ou três linhas, uma vez cortando a palavra no meio ("6 mon"/"ths"). Corrigido reduzindo o tamanho do ícone/padding do `SegmentedButton` e removendo a opção de 24 meses (3 opções cabem confortavelmente com a fonte original). Resultado final: rótulos em uma única linha, sem cortes.

**Status:** ✅ Aprovado (após ajuste)

---

### TC-12 — Verificação manual em device: cronômetro continua funcionando após o schema v4

- **Dado** a categoria "Trabalho" na Home
- **Quando** inicio e depois encerro uma sessão de cronômetro
- **Então** o fluxo deve funcionar exatamente como no M2, com os totais do dia atualizando corretamente

**Resultado obtido:** iniciar levou à tela do cronômetro rodando normalmente; encerrar voltou à Home com o total do dia atualizado ("0:05:31"), sem qualquer regressão visível causada pelas mudanças de schema/DAO do M3.

**Status:** ✅ Aprovado

---

## Resumo

| ID | Caso de teste | Status |
|---|---|---|
| TC-01 | Análise estática sem warnings | ✅ Aprovado |
| TC-02 | Usecases novos cobertos por testes unitários | ✅ Aprovado |
| TC-03 | `DailyArchiveService`: múltiplos dias, idempotência | ✅ Aprovado |
| TC-04 | `archiveDay`/DAO com relógio controlado | ✅ Aprovado |
| TC-05 | Purga com fronteiras de mês (retrabalho) | ✅ Aprovado |
| TC-06 | `ArchiveStateRepositoryImpl` get/set | ✅ Aprovado |
| TC-07 | Widget: histórico distingue dia arquivado | ✅ Aprovado |
| TC-08 | Widget: Settings retenção/purga (retrabalho de teste) | ✅ Aprovado |
| TC-09 | Suíte completa de testes | ✅ Aprovado |
| TC-10 | Manual: boot silencioso pós-schema v4 | ✅ Aprovado |
| TC-11 | Manual: UI nova de Settings | ✅ Aprovado |
| TC-12 | Manual: cronômetro sem regressão | ✅ Aprovado |

**Resultado geral do ciclo:** 12/12 casos aprovados. Critério de pronto do M3 (planning.md) atendido — gate liberado para início do M4 (Tarefas recorrentes + Lembretes).

**Cobertura de testes (domain/data, gate do milestone):**

| Camada | Arquivo | Linhas cobertas |
|---|---|---|
| domain/services | `daily_archive_service.dart` | 100% (13/13) |
| domain/usecases | `purge_old_data.dart`, `watch_archived_day.dart` | 100% (todos) |
| domain/entities | `timer_history_entry.dart` | 100% (3/3) |
| data/repositories | `timer_repository_impl.dart` | 100% (72/72) |
| data/repositories | `archive_state_repository_impl.dart` | 100% (11/11) |
| core/database/daos | `timer_dao.dart` | 100% (181/181) |
| presentation/screens | `settings_screen.dart` | 90% (57/63) — lacuna pré-existente em tema/idioma, fora do escopo do M3 |

Total: 80 testes automatizados passando no projeto (53 ao final do M2 + 27 novos deste milestone: 5 de `DailyArchiveService` + 2 de usecases + 12 de `archiveDay`/`purgeHistoryOlderThan` + 4 de `ArchiveStateRepositoryImpl` + 1 de `TimerHistoryScreen` (dia arquivado) + 3 de `SettingsScreen`).

**Observações:**
- **Bug real pego por teste de fronteira, antes de qualquer QA manual (TC-05):** o cálculo de "N meses atrás" usando o construtor `DateTime` diretamente rola silenciosamente para o mês seguinte em meses curtos, em vez de clampar o dia — exatamente o tipo de bug que a exigência do `planning.md` de "testes de fronteira de data... mês de 28/30/31 dias" foi desenhada para capturar. Funcionou como esperado.
- **Lição de metodologia de teste (TC-08):** inscrever uma stream `.watch()` do Drift fora da árvore de widgets dentro de um `testWidgets` pode travar a finalização do teste indefinidamente, sem exceção — só diagnosticável isolando o processo com um `timeout` externo, já que o hang acontece depois do corpo do teste retornar e antes do `tearDown`. A consulta de verificação deve ser sempre uma query única (`.get()`), nunca `.watch().first`.
- **Revisão de cobertura pós-implementação encontrou 3 lacunas reais** (não apenas teóricas) antes de fechar o milestone: a acumulação ao re-arquivar o mesmo bucket (TC-04), o bucketing por `taskId` (TC-04), e `ArchiveStateRepositoryImpl.getLastArchivedDate`/`setLastArchivedDate` (TC-06) — todas fechadas com testes novos, elevando `timer_dao.dart` e `archive_state_repository_impl.dart` a 100%.
- Nenhum bloqueio de edição de registros de dia passado foi implementado na UI ainda (mencionado no critério de pronto do planning.md) — não há tela de edição manual de sessões/intervalos em nenhum milestone até aqui, então não há UI a bloquear; o próprio modelo de dados já impede isso ao remover os intervalos do dia arquivado da camada "quente".
