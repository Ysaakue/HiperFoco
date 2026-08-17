# Ciclo de Testes — M6 (Estatísticas)

## Metadados

| Campo | Valor |
|---|---|
| Milestone | M6 — Estatísticas (fl_chart) |
| Data de execução | 2026-08-17 |
| Executor | Claude (Claude Code), testes automatizados (`flutter test --coverage`) + testes manuais via `adb` |
| Ambiente | Android Emulator `Pixel_7`, resolução 1080x2400, build debug (`app-debug.apk`), variant `com.hiperfoco.hiperfoco` |
| Referência de escopo | `docs/REQ001-planejamento-hiperfoco/planning.md`, seção "Roadmap faseado → M6" |

## Requisitos cobertos pelo milestone

1. Seletor de período: Dia, Semana (segunda a domingo) e Mês, com navegação por chevrons entre períodos e bloqueio de navegação para o futuro.
2. Queries agregadas combinando a camada "hoje" (`TimerSessions`/`TimerIntervals`, ainda não arquivada) com o histórico compactado (`TimerHistoryDaily`), sem duplicar nem perder dados na fronteira entre as duas camadas.
3. Gráfico por categoria (`PieChart`, fl_chart) com legenda listando nome, duração (h:mm:ss) e percentual por categoria, reaproveitando `Category.colorValue`/`iconKey` — mesma identidade visual usada em Home e no histórico do cronômetro.
4. Gráfico de tendência (`BarChart`, fl_chart) com o total por dia dentro do período, incluindo dias sem nenhum tempo cronometrado (eixo contínuo); omitido para o período "Dia" (não há tendência com um único ponto).
5. Total do período em destaque no topo.
6. Estado vazio quando não há tempo cronometrado no período selecionado.
7. Legibilidade nos dois temas (claro/escuro).

## Critério de pronto (gate do milestone, conforme planning.md)

> Gráficos batem com os dados reais (inclusive dias já arquivados), troca de período funciona, legível nos dois temas.

## Casos de teste

### TC-01 — Análise estática sem warnings

**Resultado obtido:** `No issues found! (ran in 3.5s)`

**Status:** ✅ Aprovado

---

### TC-02 — `StatisticsPeriodRange`: cálculo puro de calendário (crítico)

- **Dado** um período (dia/semana/mês) e uma data de referência
- **Quando** calculo `rangeFor` (intervalo `[start, end)`), `shift` (mover para o período anterior/seguinte) e `containsToday` (se "hoje" cai dentro do período)
- **Então** semana deve sempre ancorar em segunda-feira independente do dia da semana da referência; mês deve ir do dia 1 ao dia 1 do mês seguinte, virando o ano corretamente em dezembro→janeiro; `shift` de mês deve sempre cair no dia 1 do mês-alvo (evita o mesmo tipo de bug de rolagem de dia-do-mês já corrigido no M3); `containsToday` deve diferenciar corretamente "mesmo mês, ano diferente"

**Resultado obtido:** 14 testes passando. `statistics_period_range.dart` 100% (23/23 linhas).

**Status:** ✅ Aprovado

---

### TC-03 — `StatisticsAggregator`: combina histórico arquivado com dados "quentes" de hoje (crítico)

- **Dado** entradas já arquivadas (`TimerHistoryEntry`) e intervalos de hoje ainda não arquivados (`TimerInterval`), para um intervalo `[start, end)`
- **Quando** agrego em totais por categoria e totais por dia
- **Então** todo dia do período deve aparecer no total diário mesmo sem nenhum registro (zero-preenchido, para o eixo do gráfico de tendência ser contínuo); os intervalos de hoje só devem ser somados se "hoje" cair dentro do período consultado; um intervalo de hoje ainda aberto (sem `endedAt`, sessão em andamento) deve ser ignorado, igual ao padrão já usado em `watchTodayDurationSecondsForCategory`

**Resultado obtido:** 5 testes passando. `statistics_aggregator.dart` 100% (31/31 linhas) — inclusive o branch "hoje fora do intervalo consultado" e "intervalo aberto ignorado", que só ficaram cobertos após simplificar o código (ver observações).

**Status:** ✅ Aprovado

---

### TC-04 — Entidades do domínio (`CategoryDuration`, `DailyDuration`, `StatisticsSummary`)

**Resultado obtido:** 4 testes passando, cobrindo igualdade por valor e `StatisticsSummary.totalDurationSeconds`. `category_duration.dart`, `daily_duration.dart` e `statistics_summary.dart` 100%.

**Status:** ✅ Aprovado

---

### TC-05 — `TimerDao.watchHistoryBetween` / `TimerRepositoryImpl.watchArchivedBetween`: query de intervalo real contra Drift (crítico)

- **Dado** dias arquivados dentro e fora de um intervalo `[start, end)`, e um dia com dados só na camada "quente" (nunca arquivado)
- **Quando** consulto `watchArchivedBetween`
- **Então** só os dias já arquivados dentro do intervalo devem retornar; **hoje nunca deve aparecer aqui, mesmo estando dentro do intervalo consultado**, porque a arquivagem de hoje só acontece no próximo boot do app — esse é o contrato que `StatisticsAggregator` depende para não duplicar o total de hoje

**Resultado obtido:** 2 testes novos passando, adicionados a `timer_repository_impl_test.dart` (que já cobria `archiveDay`/`watchArchivedDay` desde o M3). `timer_repository_impl.dart` 100% (82/82 linhas), `timer_dao.dart` 100% (187/187 linhas).

**Status:** ✅ Aprovado

---

### TC-06 — `WatchArchivedBetween`: usecase novo coberto por teste unitário

**Resultado obtido:** 1 teste passando (mock, delega para `repository.watchArchivedBetween`). 100% de cobertura.

**Status:** ✅ Aprovado

---

### TC-07 — Testes de widget: `StatisticsScreen`

- **Dado** a tela de Estatísticas
- **Quando** não há tempo cronometrado na semana atual, há apenas dados "quentes" de hoje, há dados arquivados de um dia anterior da mesma semana combinados com dados quentes de hoje, ou o período é trocado de Semana para Dia
- **Então** o estado vazio aparece corretamente; o total e o percentual por categoria (100% com uma única categoria) aparecem corretamente para dados só de hoje; o total combina corretamente arquivado + quente (20min arquivados + 30min quentes = 50min); trocar para "Dia" estreita a consulta e volta ao estado vazio quando hoje não tem tempo cronometrado próprio

**Resultado obtido:** 4 testes passando. Um deles (`combina um dia já arquivado com hoje`) foi desenhado deliberadamente para não depender de qual dia da semana o teste roda — a primeira versão usava uma "quarta-feira mais próxima" como âncora e falhava de forma intermitente quando o teste rodava numa segunda ou terça-feira (o dia "anterior" caía na semana passada); corrigido ancorando no início real da semana (`weekStart = hoje − (hoje.weekday − 1)`, o mesmo cálculo usado por `StatisticsPeriodRange.rangeFor`) e criando os dados quentes de hoje **depois** de arquivar `weekStart`, garantindo que a sessão de hoje nunca é varrida para o histórico mesmo no caso extremo em que `weekStart == hoje`.

**Status:** ✅ Aprovado (após correção de teste intermitente)

---

### TC-08 — Suíte completa de testes

**Resultado obtido:** `+223: All tests passed!`

**Status:** ✅ Aprovado

---

### TC-09 — Verificação manual em device: estado vazio

- **Dado** a tela de Estatísticas sem nenhum tempo cronometrado na semana atual
- **Quando** abro a tela (período padrão: Semana)
- **Então** deve mostrar o ícone e a mensagem de estado vazio, com o seletor de período e a navegação por chevrons já visíveis e funcionais

**Resultado obtido:** exatamente isso — "Nenhum tempo cronometrado neste período ainda." com o intervalo da semana atual (17/08/2026 – 23/08/2026) exibido corretamente.

**Status:** ✅ Aprovado

---

### TC-10 — Verificação manual em device: gráficos batem com dados reais (crítico)

- **Dado** uma sessão de cronômetro de 36 segundos na categoria "Estudos"
- **Quando** paro a sessão e abro Estatísticas (período Semana)
- **Então** o total deve mostrar "Total: 0:00:36"; o gráfico de pizza deve mostrar um único segmento na cor da categoria "Estudos"; a legenda deve mostrar "Estudos — 0:00:36 — 100%"; o gráfico de tendência deve mostrar uma única barra no dia de hoje (17), com os demais dias da semana (18–23) no zero

**Resultado obtido:** exatamente isso, confirmado por screenshot — cor do gráfico de pizza idêntica à cor da bolinha da categoria na Home, valores batendo exatamente com a sessão cronometrada.

**Status:** ✅ Aprovado — este é o critério de pronto central do M6.

---

### TC-11 — Verificação manual em device: troca de período (Dia/Semana/Mês)

- **Dado** os mesmos 36 segundos cronometrados hoje
- **Quando** troco o período para "Dia"
- **Então** deve mostrar "Hoje" na navegação (reaproveitando `l10n.timerHistoryToday`, mesma string já usada no histórico do cronômetro), o chevron "próximo" desabilitado (não é possível navegar para o futuro), e o mesmo total de 36 segundos
- **Quando** troco para "Mês"
- **Então** deve mostrar "agosto de 2026" (via `DateFormat.yMMMM` com locale pt, mesmo padrão já usado no Calendário) e o gráfico de tendência com 31 pontos no eixo, rótulos a cada 5 dias para não poluir o eixo, barra única no dia 17

**Resultado obtido:** ambas as trocas funcionaram exatamente como esperado, confirmado por screenshots.

**Status:** ✅ Aprovado

---

### TC-12 — Verificação manual em device: legibilidade no tema escuro

- **Dado** a tela de Estatísticas com dados (período Mês)
- **Quando** troco o tema para "Escuro" em Ajustes
- **Então** todos os textos, o gráfico de pizza (cor da categoria preservada) e o gráfico de barras (cor primária do tema, rótulos do eixo em cinza claro) devem permanecer legíveis contra o fundo escuro

**Resultado obtido:** confirmado por screenshot — bom contraste em todos os elementos, nenhum texto ilegível.

**Status:** ✅ Aprovado

---

### TC-13 — Verificação manual em device: telas existentes sem regressão

**Resultado obtido:** navegação entre Home/Tasks/Calendar/Settings e o fluxo de cronômetro (iniciar, ver o card "Focando", encerrar) continuaram funcionando normalmente durante o teste manual deste ciclo, sem regressão visível causada pelas mudanças de schema/repositório do M6 (a única mudança em código existente foi a adição de `watchArchivedBetween`, sem alterar nenhum método já usado por outras telas).

**Status:** ✅ Aprovado

---

## Resumo

| ID | Caso de teste | Status |
|---|---|---|
| TC-01 | Análise estática sem warnings | ✅ Aprovado |
| TC-02 | `StatisticsPeriodRange` (crítico) | ✅ Aprovado |
| TC-03 | `StatisticsAggregator` combina arquivado + quente (crítico) | ✅ Aprovado |
| TC-04 | Entidades do domínio | ✅ Aprovado |
| TC-05 | `watchArchivedBetween` nunca inclui hoje (crítico) | ✅ Aprovado |
| TC-06 | `WatchArchivedBetween` usecase | ✅ Aprovado |
| TC-07 | Widget: `StatisticsScreen` (teste intermitente corrigido) | ✅ Aprovado |
| TC-08 | Suíte completa de testes | ✅ Aprovado |
| TC-09 | Manual: estado vazio | ✅ Aprovado |
| TC-10 | Manual: gráficos batem com dados reais (crítico) | ✅ Aprovado |
| TC-11 | Manual: troca de período Dia/Semana/Mês | ✅ Aprovado |
| TC-12 | Manual: legibilidade no tema escuro | ✅ Aprovado |
| TC-13 | Manual: telas existentes sem regressão | ✅ Aprovado |

**Resultado geral do ciclo:** 13/13 casos aprovados. Critério de pronto do M6 (planning.md) atendido — gate liberado para início do M7 (Polish, i18n/tema final, preparação de release).

**Cobertura de testes (domain/data, gate do milestone):**

| Camada | Arquivo | Linhas cobertas |
|---|---|---|
| domain/entities | `category_duration.dart`, `daily_duration.dart`, `statistics_summary.dart` | 100% |
| domain/services | `statistics_period_range.dart` | 100% (23/23) |
| domain/services | `statistics_aggregator.dart` | 100% (31/31) |
| domain/usecases (timer, estendido) | `watch_archived_between.dart` | 100% |
| data/repositories (timer, estendido) | `timer_repository_impl.dart` | 100% (82/82) |
| core/database/daos (timer, estendido) | `timer_dao.dart` | 100% (187/187) |

Total: 223 testes automatizados passando no projeto (193 ao final do trabalho anterior de sincronização etapa↔tarefa + 30 novos deste milestone).

**Observações:**
- **Nenhuma tabela nova foi criada neste milestone** — Estatísticas é a primeira feature do projeto que não precisa de schema próprio, só de uma nova forma de consultar dados já existentes (`TimerHistoryDaily`, `TimerSessions`/`TimerIntervals`). A única mudança de schema foi zero: `schemaVersion` permanece o mesmo do M5.
- **Sem repositório dedicado para Estatísticas**, por design: a combinação "histórico arquivado + hoje ainda quente" é feita na camada de provider (`statisticsSummaryProvider`, um `@riverpod` `Stream` `async*`), seguindo o mesmo padrão já estabelecido por `occurrencesForRange` (M4) de combinar múltiplos providers via `ref.watch(...future)` em vez de inventar uma nova camada de repositório só para orquestração. A lógica de agregação em si (`StatisticsAggregator`) é pura e vive no domínio da feature, plenamente testável sem Drift.
- **Retrabalho de teste, não de produto:** o único achado deste ciclo foi um teste de widget intermitente (TC-07) causado por matemática de calendário sensível ao dia da semana em que o teste roda — não afeta o comportamento real do app, só a robustez do próprio teste. Corrigido ancorando o cenário no início real da semana corrente em vez de um dia da semana fixo arbitrário.
- **Sem verificação de fuso horário/DST neste ciclo** — assim como no M3/M4, toda a lógica de data usa `DateTime` local sem componente de fuso explícito, consistente com o resto do projeto (app 100% local, sem sincronização entre dispositivos).
