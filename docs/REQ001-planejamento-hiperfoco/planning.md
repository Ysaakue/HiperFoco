# Plano — App HiperFoco (Flutter)

## Contexto

O usuário quer um app mobile de gestão de tempo/foco voltado para pessoas com TDAH, com foco em Android, construído em Flutter. O projeto (`c:\projects\HiperFoco`) estava vazio no início desta requisição — só existiam o briefing funcional e screenshots de apps similares, hoje arquivados em `docs/REQ001-planejamento-hiperfoco/ref/` (`hiperfoco.txt` e as imagens de referência, listadas em `ref/aplicativos.txt`).

Funcionalidades centrais pedidas: categorias personalizadas, cronômetro por tarefa/categoria com pausa controlada (sem perder progresso), quebra de metas em etapas, tarefas recorrentes com agenda, lembretes configuráveis (isolados ou vinculados a recorrências), estatísticas em gráficos (dia/semana/mês), e uma interface deliberadamente simples para reduzir sobrecarga cognitiva (TDAH). Requisitos técnicos: boas práticas Flutter + SOLID, código 100% em inglês, i18n configurável (pt/en inicialmente, todas as strings traduzíveis), tema claro/escuro configurável, armazenamento 100% local.

Referências visuais analisadas (`ref/*.jpeg`, nesta mesma pasta): tema escuro predominante, tela de cronômetro com tempo grande central (H:MM:SS), nome+ícone da categoria, botão de play/pause circular grande, sub-métricas "tempo da categoria hoje" e "tempo total hoje"; Home com lista de categorias (bolinha colorida + nome + tempo do dia + play inline); calendário mensal com chips coloridos; histórico em timeline por dia com blocos de horário.

Decisões já confirmadas com o usuário (via pergunta direta, todas as recomendadas):
- **State management:** Riverpod (com `riverpod_generator`)
- **Persistência local:** Drift (SQLite) — dados são relacionais (tarefas↔categorias↔sessões↔lembretes↔metas)
- **Gráficos:** fl_chart
- **Escopo:** plano de arquitetura completo, faseado em milestones (MVP primeiro, depois features avançadas)

Este plano cobre desde o zero (não existe nenhum código Flutter ainda) até um roadmap de implementação em fases.

---

## Arquitetura

### Estrutura de pastas (Clean Architecture feature-first)

```
hiperfoco/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart                       # MaterialApp.router, wiring de theme/locale
│   │   ├── router/app_router.dart         # go_router + ShellRoute (bottom nav)
│   │   └── theme/{app_theme,app_colors,app_typography}.dart
│   │
│   ├── core/                              # infra compartilhada, sem regra de negócio de feature
│   │   ├── database/
│   │   │   ├── app_database.dart          # @DriftDatabase
│   │   │   ├── tables/                    # categories, tasks, recurrence_rules,
│   │   │   │                              # task_occurrence_overrides, timer_sessions,
│   │   │   │                              # timer_intervals, reminders, goals, goal_steps
│   │   │   └── daos/                      # category_dao, task_dao, timer_dao,
│   │   │                                  # reminder_dao, goal_dao, statistics_dao
│   │   ├── notifications/notification_service.dart
│   │   ├── error/{failure,exceptions}.dart
│   │   ├── utils/{duration_formatter,date_range_utils}.dart
│   │   └── widgets/                       # design system: primary_action_button,
│   │                                      # color_icon_picker, empty_state, confirm_dialog
│   │
│   ├── features/
│   │   ├── categories/{data,domain,presentation}/
│   │   ├── tasks/          # + recurrence rule como value object
│   │   ├── timer/          # start/pause/resume/stop usecases
│   │   ├── reminders/
│   │   ├── goals/
│   │   ├── statistics/
│   │   └── settings/       # theme mode + locale
│   │
│   └── l10n/{app_en.arb, app_pt.arb}
│
├── test/                   # espelha lib/ (unit: domain+data; widget: presentation)
├── integration_test/       # fluxos e2e críticos
├── l10n.yaml
├── analysis_options.yaml
└── pubspec.yaml
```

Cada feature segue `data/domain/presentation`:
- `domain/entities` — modelos de negócio puros (sem depender de Drift)
- `domain/repositories` — **interfaces** abstratas
- `domain/usecases` — uma regra de negócio por classe
- `data/datasources` + `data/repositories/*_impl.dart` — implementação concreta (Drift)
- `presentation/providers` (`@riverpod`) + `screens` + `widgets`

**Aplicação de SOLID:**
- **SRP** — DAO só fala com SQLite; `*RepositoryImpl` só traduz DAO↔entidade; usecase contém uma única regra.
- **DIP** — `presentation` depende de `domain/repositories` (interface), nunca de Drift diretamente; providers Riverpod injetam a implementação. Permite substituir por fakes em teste.
- **OCP** — nova feature = nova pasta, sem editar módulos existentes.
- **ISP** — repositórios expõem só os métodos que a própria feature usa (sem "repositório deus").
- **LSP** — qualquer implementação de um repositório (Drift real ou in-memory fake) é substituível sem quebrar usecases.

### Modelo de dados (Drift)

Tabelas principais e como modelam os requisitos mais delicados:

- **`CategoriesTable`**: `name`, `colorValue`, `iconKey`, `isArchived` (nunca hard-delete se tiver histórico), `createdAt`.
- **`RecurrenceRulesTable`**: regra tipo RRULE simplificada (`frequency`, `interval`, `byWeekdays`, `byMonthDay`, `timeOfDay`, `startDate`, `endDate?`), reutilizada tanto por `Task` quanto por `Reminder` standalone recorrente.
- **`TasksTable`**: `title`, `categoryId`, `status`, `dueDate?`, `isRecurring`, `recurrenceRuleId?`, `goalStepId?` (se nasceu de etapa promovida).
- **`TaskOccurrenceOverridesTable`**: exceções por ocorrência (`done`/`skipped`/`rescheduled`) de tarefa recorrente. **Recorrência é virtual** — um `RecurrenceEngine` (domínio puro) calcula ocorrências sob demanda para um intervalo de datas; não materializa uma linha por dia. Evita geração infinita e mantém o schema simples.
- **`TimerSessionsTable`** + **`TimerIntervalsTable`**: esta é a modelagem chave da "pausa sem perder progresso". Uma sessão é uma **sequência de intervalos** (`startedAt`/`endedAt` nullable). Pausar = fechar o intervalo aberto; retomar = abrir um novo. Duração total = soma dos intervalos. `totalDurationSeconds` na sessão é só cache de leitura. Regra de negócio: só uma sessão `running` por vez (enforced no usecase `StartTimer`, em transação). Esse modelo também alimenta naturalmente a tela de timeline/histórico (blocos com gaps de pausa, como nas referências visuais).
- **`RemindersTable`**: três formas válidas — standalone único (`scheduledAt`), standalone recorrente (`recurrenceRuleId`), ou vinculado a task (`taskId`, herda horário da recorrência/`dueDate`).
- **`GoalsTable`** + **`GoalStepsTable`**: etapas com `isDone`, `sortOrder`, e `linkedTaskId?` opcional para "promover passo a tarefa agendável".
- **`TimerHistoryDailyTable`** (arquivamento compactado — ver seção dedicada abaixo): `date`, `categoryId`, `taskId?`, `totalDurationSeconds`, `sessionCount`, `createdAt`. Chave única em `(date, categoryId, taskId)`.

**Settings (tema/idioma):** `shared_preferences`, não Drift — leitura simples no boot, sem acoplar ao schema relacional.

### Arquivamento, histórico compactado e retenção de dados

Para não deixar `TimerSessionsTable`/`TimerIntervalsTable` crescerem indefinidamente (cada pausa/retomada gera uma linha), o modelo separa dados em duas camadas:

- **Camada "hoje" (quente, editável):** `TimerSessions` + `TimerIntervals` guardam granularidade total (todo intervalo start/end) **apenas para a data corrente**. É essa granularidade que alimenta a timeline de hoje com os blocos e gaps de pausa. Edição manual de sessões/intervalos só é permitida para registros de hoje.
- **Camada histórico (fria, somente leitura):** `TimerHistoryDailyTable` guarda um total compactado por `(dia, categoria, tarefa)` — sem detalhe de pausas individuais. É a fonte para Estatísticas (M6) e para visualizar dias passados na timeline (mostrando só blocos totais por tarefa/categoria naquele dia, não cada pausa).

**Job de virada de dia (`DailyArchiveService`, domínio puro, sem depender de background service do SO):**
1. Executado no boot do app (e opcionalmente ao voltar do background), comparando a última data processada (guardada em `shared_preferences`) com a data local atual.
2. Para cada dia entre a última data processada e ontem (inclusive) — cobre o caso do app ficar dias fechado —, agrupa `TimerIntervals` por `(dia, categoryId, taskId)`, soma a duração, conta sessões, e faz upsert em `TimerHistoryDailyTable`.
3. Remove as `TimerSessions`/`TimerIntervals` daquele dia já arquivado (cascade apaga os intervalos).
4. Tudo em uma transação Drift por dia processado; idempotente (pode rodar de novo sem duplicar).
5. **Sessão aberta atravessando a meia-noite** (usuário deixou o cronômetro rodando durante a virada do dia): a sessão é **dividida** no rollover — fecha o intervalo aberto às 23:59:59 do dia anterior (vira histórico) e abre automaticamente uma nova sessão/intervalo a partir de 00:00 do novo dia, preservando o estado `running`/`paused`. Essa é a regra padrão proposta; sinalizar se o usuário preferir outro comportamento (ex.: não dividir e manter tudo no dia de início).

**Purga em massa (retenção configurável):** em Settings, uma ação "Excluir dados com mais de X meses" (padrão sugerido: 6 meses, editável pelo usuário) que roda `PurgeOldDataUseCase` sobre `TimerHistoryDailyTable` (e, secundariamente, sobre `TaskOccurrenceOverrides` e `Goals`/`Tasks` arquivados antigos). Disponível tanto como ação manual quanto, opcionalmente, automática em cada boot do app (mesma rotina do `DailyArchiveService`).

### Packages (além de Riverpod/Drift/fl_chart)

| Necessidade | Package | Motivo |
|---|---|---|
| Navegação | `go_router` | Declarativo, `ShellRoute` encaixa no bottom nav mantendo estado por aba |
| Notificações | `flutter_local_notifications` + `timezone` + `flutter_timezone` | Agendamento local com fuso correto, sem backend |
| Permissões | `permission_handler` | `POST_NOTIFICATIONS` (Android 13+) |
| i18n | `flutter gen-l10n` (`flutter_localizations` + `intl`) | First-party, chaves checadas em compile-time; strings são estáticas (não precisam trocar sem rebuild), então não justifica `easy_localization` |
| Modelagem | `freezed` + `json_annotation` | Entidades imutáveis e union types de estado (ex.: `TimerControllerState.idle/running/paused`) |
| Settings | `shared_preferences` | Tema + idioma |
| SQLite nativo | `sqlite3_flutter_libs`, `path_provider`, `path` | Bundling do Drift no Android |
| Testes | `mocktail`, `integration_test` (SDK) | Mock sem codegen extra; e2e dos fluxos críticos |
| Lint | `flutter_lints` (ou `very_good_analysis` para regra mais estrita) | Baseline oficial |
| Riverpod tooling (dev) | `riverpod_lint`, `custom_lint` | Detecta uso incorreto de `ref` em tempo de análise |

Deliberadamente **adiado**: `workmanager`/`android_alarm_manager_plus` (não necessário — `zonedSchedule` + `RECEIVE_BOOT_COMPLETED` já resolvem reagendamento pós-boot). Evitar `SCHEDULE_EXACT_ALARM` no MVP — usar `AndroidScheduleMode.inexactAllowWhileIdle` (lembretes de TDAH não precisam de precisão de segundo, e alarme exato tem escrutínio extra na Play Store).

---

## Roadmap faseado

**M0 — Setup & infraestrutura**
`flutter create`, estrutura de pastas, dependências, `AppDatabase` vazio, `go_router` com shell de abas (Home/Tasks/Calendar/Stats/Settings, telas placeholder), tema claro/escuro persistido, `gen-l10n` com pt/en funcionando ponta-a-ponta, `analysis_options.yaml`.
*Pronto quando:* `flutter run` no Android mostra o shell navegável, toggle de tema/idioma funciona, sem warnings do analyzer.

**M1 — Categorias + Tarefas (CRUD, sem recorrência)**
Tabelas `Categories`/`Tasks` (não-recorrente), DAOs/repos/usecases, telas de lista/form (cor+ícone da categoria), Home com categorias e badge de tempo (placeholder), testes unitários com Drift in-memory.
*Pronto quando:* CRUD persiste entre reinícios, traduzido pt/en, funciona nos dois temas.

**M2 — Cronômetro com pausa** (o diferencial do app)
`TimerSessions`/`TimerIntervals`, usecases start/pause/resume/stop, tela de cronômetro (nome+ícone da categoria, H:MM:SS central, botão circular, sub-métricas), play inline na Home, regra de sessão única ativa, timeline/histórico por dia, recuperação de sessão em andamento após reabrir o app.
*Pronto quando:* pausar/retomar não perde tempo, sessão sobrevive a fechar/reabrir o app, timeline mostra blocos com gaps corretos.

**M3 — Arquivamento, histórico compactado e retenção de dados**
`TimerHistoryDailyTable`, `DailyArchiveService` (rollover de meia-noite, split de sessão aberta, idempotente para múltiplos dias em atraso), bloqueio de edição para registros fora do dia corrente, tela/ação em Settings para "excluir dados com mais de X meses" (`PurgeOldDataUseCase`, padrão 6 meses).
*Pronto quando:* fechar o app por N dias e reabrir arquiva corretamente todos os dias pendentes sem duplicar nem perder tempo total; sessão deixada rodando durante a virada do dia é dividida corretamente; tentar editar um registro de dia passado é bloqueado na UI; purga manual remove dados além do limite configurado e é coberta por testes de fronteira de data (meia-noite, fuso, mês de 28/30/31 dias).

**M4 — Tarefas recorrentes + Lembretes**
`RecurrenceRules`, `RecurrenceEngine`, `TaskOccurrenceOverrides`, UI de recorrência no form, calendário mensal com chips + tempo cronometrado do dia, `Reminders` + `NotificationService`, fluxo de permissão de notificação, reminders standalone e vinculados.
*Pronto quando:* recorrência aparece certo no calendário, concluir uma ocorrência não afeta as demais, notificações disparam no horário certo e sobrevivem a reboot.

**M5 — Metas & Etapas**
`Goals`/`GoalSteps`, lista de metas + detalhe com checklist reordenável e progresso, ação "promover passo a tarefa".
*Pronto quando:* criar meta → dividir em passos → marcar progresso → opcionalmente promover passo a tarefa, tudo funcional.

**M6 — Estatísticas (fl_chart)**
Queries agregadas no Drift (SUM/GROUP BY, não loop em memória) combinando a camada "hoje" (`TimerSessions`) e o histórico compactado (`TimerHistoryDailyTable`), seletor de período (dia/semana/mês), gráfico por categoria + tendência, cores reaproveitadas de `Category.colorValue`.
*Pronto quando:* gráficos batem com os dados reais (inclusive dias já arquivados), troca de período funciona, legível nos dois temas.

**M7 — Polish, i18n/tema final, preparação de release**
Auditoria de strings hardcoded, acessibilidade (escala de fonte, contraste, alvo de toque ≥48dp), empty states, Settings finalizado, ícone/splash, build de release assinado, checklist de UX-TDAH revisado.
*Pronto quando:* app pronto para submissão na Play Store.

*(Fora de escopo por ora: widget de home screen, backup/exportação, gamificação, iOS — candidatos a M8+.)*

### Gate de qualidade ao final de cada milestone

Cada milestone só é considerado concluído com dois entregáveis adicionais, não apenas código funcionando:

1. **Cobertura máxima de testes unitários** nas camadas `domain` e `data` da(s) feature(s) do milestone (usecases e repositórios são o alvo prioritário — é onde mora a regra de negócio), mais testes de widget para as telas novas. Rodar `flutter test --coverage` e revisar o relatório (`lcov`) antes de avançar; qualquer usecase sem teste é bloqueador, não é aceitável avançar de milestone com lógica de negócio não testada.
2. **Documento de ciclo de testes para QA**, em `qa/M{n}-test-cycle.md` (dentro desta mesma pasta `docs/REQ001-planejamento-hiperfoco/`), contendo: lista dos requisitos cobertos pelo milestone, casos de teste em formato dado/quando/então com passos manuais reproduzíveis, critério de aceite por caso, e uma coluna de status (pendente/aprovado/reprovado). Esse documento é o gate formal — só se avança ao próximo milestone com todos os casos aprovados.

---

## UX para TDAH (aplicada, não genérica)

- Uma ação primária por tela (FAB único, botão único no timer).
- Iniciar cronômetro em ≤2 toques (play inline na Home).
- Cor+ícone de categoria consistentes em Home/Timer/Calendário/Estatísticas — reconhecimento visual em vez de leitura.
- Tela de timer sem distrações (considerar ocultar bottom nav durante sessão ativa).
- Notificações diretas, sem tom de urgência desnecessário.
- Metas forçadas a granularidade pequena pelo próprio schema (`GoalStep`).
- Campos avançados (recorrência custom, offset de lembrete) atrás de "mais opções", não expostos de cara.
- Pausa automática ao sair da tela/trocar de app — nada se perde por esquecimento.
- Modo escuro como padrão, paleta calma, vermelho reservado a ações destrutivas com confirmação.
- Bottom nav com no máximo 5 itens.

---

## Arquivos críticos para começar a implementação

- `pubspec.yaml` — todas as dependências listadas acima
- `lib/core/database/app_database.dart` e `lib/core/database/tables/timer_sessions_table.dart` / `timer_intervals_table.dart` — núcleo do diferencial (pausa controlada)
- `lib/core/database/tables/timer_history_daily_table.dart` e o serviço de rollover (`lib/features/timer/domain/services/daily_archive_service.dart`) — arquivamento/retenção
- `lib/app/router/app_router.dart` — shell de navegação
- `lib/l10n/app_en.arb` / `app_pt.arb` — base de tradução desde o M0

## Verificação

- **M0:** `flutter analyze` sem warnings; `flutter run` em device/emulador Android navegando pelas 5 abas; alternar tema e idioma nas Settings reflete imediatamente.
- **M1 em diante:** testes unitários por feature (`test/features/<feature>/domain` e `data`, com Drift in-memory) rodando via `flutter test --coverage`, com meta de cobertura máxima em `domain`/`data` (usecases e repositórios sem teste bloqueiam o milestone); testes de widget para telas de formulário/lista.
- **M2 (crítico):** teste de integração cobrindo iniciar → pausar → fechar app → reabrir → retomar → parar, validando que a duração total bate com a soma dos intervalos.
- **M3 (crítico):** testes unitários de fronteira de data para `DailyArchiveService` — múltiplos dias em atraso, sessão aberta atravessando a meia-noite, idempotência ao rodar duas vezes, purga por limite de meses configurável.
- **M4:** teste manual em device real de agendamento de notificação + reboot do device, para validar sobrevivência do agendamento.
- Ao final de cada milestone: relatório de cobertura revisado + `qa/M{n}-test-cycle.md` preenchido e aprovado (ver "Gate de qualidade" no roadmap) antes de iniciar o próximo milestone.
- Cada milestone finaliza com `flutter run` manual no Android exercitando o fluxo completo daquela fase antes de avançar para a próxima.
