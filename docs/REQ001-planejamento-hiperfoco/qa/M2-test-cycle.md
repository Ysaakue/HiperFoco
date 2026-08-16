# Ciclo de Testes — M2 (Cronômetro com pausa)

## Metadados

| Campo | Valor |
|---|---|
| Milestone | M2 — Cronômetro com pausa (o diferencial do app) |
| Data de execução | 2026-08-16 |
| Executor | Claude (Claude Code), testes automatizados (`flutter test --coverage`, com relógio controlado via `package:clock`) + testes manuais via `adb` |
| Ambiente | Android Emulator `emulator-5554`, resolução 1080x2400 @420dpi, build debug (`app-debug.apk`), variant `com.hiperfoco.hiperfoco` |
| Referência de escopo | `docs/REQ001-planejamento-hiperfoco/planning.md`, seção "Roadmap faseado → M2" |

## Requisitos cobertos pelo milestone

1. Tabelas Drift `TimerSessions`/`TimerIntervals` (schema v2→v3), sessão modelada como sequência de intervalos com cache de leitura (`totalDurationSeconds`, `currentIntervalStartedAt`).
2. Usecases start/pause/resume/stop, repositório e DAO (`TimerDao`) com toda a lógica transacional.
3. Tela de cronômetro: nome+ícone da categoria, tempo central H:MM:SS, botão play/pause circular, sub-métricas "esta categoria hoje"/"hoje", botão de encerrar.
4. Play inline na Home (`CategoryTile`), com indicação visual de qual categoria tem a sessão ativa.
5. Regra de sessão única ativa no app inteiro.
6. Timeline/histórico por dia (`TimerHistoryScreen`), navegável por dia anterior/seguinte.
7. Recuperação de sessão em andamento após fechar/reabrir o app.
8. Acesso ao histórico pelo menu de 3 pontos da categoria, sem exigir uma sessão ativa (adicionado por pedido do usuário após a primeira execução deste ciclo).

## Critério de pronto (gate do milestone, conforme planning.md)

> Pausar/retomar não perde tempo, sessão sobrevive a fechar/reabrir o app, timeline mostra blocos com gaps corretos.

## Casos de teste

### TC-01 — Análise estática sem warnings

**Resultado obtido:** `No issues found! (ran in 2.9s)`

**Status:** ✅ Aprovado

---

### TC-02 — Usecases cobertos por testes unitários (mocktail)

**Critério de aceite:** todos os 8 usecases de timer com teste passando (gate bloqueador do planning.md).

**Resultado obtido:** 8 testes passando (`timer_usecases_test.dart`), cobertura de linha 100% nos 8 arquivos de usecase.

**Status:** ✅ Aprovado

---

### TC-03 — Repositório/DAO validados contra Drift in-memory com relógio controlado

- **Dado** `AppDatabase.forTesting(NativeDatabase.memory())` e o tempo controlado via `withClock(Clock.fixed(t), ...)` (pacote `clock`, adicionado neste milestone especificamente para tornar a acumulação de duração testável sem depender de `sleep` real)
- **Quando** executo os testes de `TimerRepositoryImpl`/`TimerDao` cobrindo: criar sessão, pausar (acumula duração), retomar (não perde o acumulado, não conta o tempo pausado), encerrar, trocar de categoria (encerra a anterior), trocar com a anterior pausada, agregação "hoje" por categoria/total, timeline do dia
- **Então** toda a lógica transacional deve se comportar corretamente, de forma determinística e instantânea (sem esperas reais)

**Resultado obtido:** 17 testes passando; `timer_repository_impl.dart` 45/45 e `timer_dao.dart` 104/104 linhas cobertas (100%).

**Status:** ✅ Aprovado

---

### TC-04 — Testes de widget (TimerScreen, TimerHistoryScreen, integração com Home)

**Observação técnica:** `TimerScreen` mantém um `Timer.periodic` real para o relógio visual, que nunca "assenta" — `pumpAndSettle()` foi evitado nesses testes em favor de `pump()` explícito, com o mesmo cuidado de `pump(Duration.zero)` no encerramento já documentado no M1 para os streams do Drift.

**Resultado obtido:** 6 testes de widget passando, cobrindo iniciar/pausar/retomar/encerrar na própria tela, navegação a partir do botão de play da Home, e a timeline vazia/preenchida.

**Status:** ✅ Aprovado

---

### TC-05 — Suíte completa de testes

**Resultado obtido:** `+52: All tests passed!`

**Status:** ✅ Aprovado

---

### TC-06 — Retrabalho: condição de corrida ao iniciar o cronômetro pela Home

> **Encontrado durante a escrita dos testes automatizados, antes de qualquer verificação manual** — diferente dos retrabalhos do M1 (que só apareceram quando o usuário testou a UI), este foi pego ao desenhar os casos de teste do DAO: percebi que "pausar a sessão anterior" ao iniciar uma nova permitiria **múltiplas sessões pausadas coexistindo**, quebrando a garantia de "uma sessão ativa por vez" da qual toda a UI depende. Corrigido trocando o comportamento para **encerrar** (não pausar) a sessão anterior ao iniciar uma nova — o `planning.md` já previa as duas opções ("pausa/encerra o anterior automaticamente").
>
> Esse mesmo redesenho expôs um segundo bug, esse sim só visível no emulador: como `activeTimerSessionProvider` é compartilhado entre Home e a tela do cronômetro, havia uma janela onde, logo após `start()` retornar, o stream ainda emitia o valor antigo (`null`) por um instante antes do novo valor chegar — a `TimerScreen` interpretava isso como "sessão encerrada" e voltava para a Home sozinha, um piscar quase imperceptível de tela. Corrigido usando `ref.listen` para só disparar o "voltar" numa transição real de "tinha sessão" → "não tem mais", nunca no primeiro frame.

- **Dado** uma categoria sem sessão ativa
- **Quando** toco o botão de play na Home uma única vez
- **Então** devo ser levado direto para a tela do cronômetro já rodando, sem piscar de volta para a Home

**Resultado obtido (antes da correção):** o app voltava para a Home imediatamente após o toque, embora a sessão tivesse sido criada corretamente no banco (confirmado reabrindo a tela manualmente, que mostrava o tempo já decorrido). **Depois da correção:** um único toque leva direto à tela do cronômetro rodando.

**Status:** ✅ Aprovado (após correção)

---

### TC-07 — Iniciar, pausar e ver as sub-métricas ao vivo

- **Dado** a categoria "Trabalho" sem sessão ativa
- **Quando** toco o play na Home e depois o botão de pausa na tela do cronômetro
- **Então** o tempo deve parar de contar, o botão deve virar play, e "esta categoria hoje"/"hoje" devem refletir o tempo decorrido

**Resultado obtido:** cronômetro iniciou em "Focando 0:00:02", pausou em "Pausado 0:00:18" com ambas as sub-métricas em "0:00:18".

**Status:** ✅ Aprovado

---

### TC-08 — Sessão pausada sobrevive a fechar/reabrir o app (crítico)

- **Dado** uma sessão pausada em "0:00:18"
- **Quando** forço o encerramento do app (`am force-stop`) e relanço pelo launcher
- **Então** a Home deve mostrar a categoria com o ícone de sessão ativa destacado e o tempo "0:00:18" **sem ter avançado** (a sessão estava pausada, não rodando, durante o tempo em que o app ficou fechado)

**Resultado obtido:** exatamente isso — "0:00:18" preservado, ícone de play destacado na cor da categoria indicando sessão ativa recuperável.

**Status:** ✅ Aprovado — este é o critério de pronto central do M2.

---

### TC-09 — Retomar continua de onde parou

- **Dado** a sessão pausada e recuperada em "0:00:18" (do TC-08)
- **Quando** toco o play na Home (navega de volta à tela do cronômetro) e depois o play dentro da tela (retoma)
- **Então** o tempo deve continuar contando a partir de "0:00:18", não zerar nem pular

**Resultado obtido:** cronômetro retomado mostrou "Focando 0:00:19" (18 + 1s de navegação), contando normalmente a partir daí.

**Status:** ✅ Aprovado

---

### TC-10 — Timeline do dia mostra os intervalos corretamente

- **Dado** uma sessão com um intervalo já fechado (pausa) e a sessão ainda pausada (não retomada)
- **Quando** abro o histórico pelo ícone da AppBar da tela do cronômetro
- **Então** deve listar o intervalo fechado com horário de início–fim e duração, para o dia atual, com navegação para dias anteriores

**Resultado obtido:** listou "Trabalho, 11:40 – 11:41, 0:00:18" corretamente; navegação "Today" com setas ‹ › presente e funcional (seta para o futuro desabilitada, como esperado).

**Status:** ✅ Aprovado

---

### TC-11 — Encerrar a sessão volta para a Home automaticamente

- **Dado** uma sessão rodando
- **Quando** toco o botão de encerrar (stop) na tela do cronômetro
- **Então** devo voltar para a Home automaticamente, com o ícone de play resetado (não mais destacado) e o badge de tempo da categoria atualizado com o total final

**Resultado obtido:** retornou à Home sozinho, ícone voltou ao estado normal, badge mostrou "0:01:46" (tempo total acumulado da sessão inteira, incluindo o trecho antes da pausa).

**Status:** ✅ Aprovado

---

### TC-12 — Acessar o histórico pela categoria sem iniciar o cronômetro

> **Retrabalho, pedido pelo usuário após a primeira execução deste ciclo:** originalmente, `TimerHistoryScreen` só era alcançável pelo ícone dentro da própria tela do cronômetro — ou seja, era preciso iniciar (ou já ter) uma sessão ativa só para consultar o histórico de um dia. Adicionado um item "Histórico" no menu de 3 pontos de `CategoryTile`, ao lado de "Arquivar", navegando direto para `TimerHistoryScreen` sem tocar em `start()`.

- **Dado** uma categoria sem sessão ativa
- **Quando** abro seu menu de 3 pontos e toco em "Histórico"
- **Então** devo ver a timeline do dia normalmente, e nenhuma sessão deve ter sido criada (badge de tempo da categoria inalterado, ícone de play permanece no estado neutro ao voltar)

**Resultado obtido:** menu passou a mostrar "History"/"Archive"; tocar em "History" abriu a timeline do dia (10 sessões de teste anteriores listadas corretamente); ao voltar, a categoria seguia com "0:04:56" e o ícone de play em estado neutro — nenhuma sessão nova foi criada.

**Status:** ✅ Aprovado (após adicionar a funcionalidade)

---

## Resumo

| ID | Caso de teste | Status |
|---|---|---|
| TC-01 | Análise estática sem warnings | ✅ Aprovado |
| TC-02 | Usecases cobertos por testes unitários | ✅ Aprovado |
| TC-03 | Repositório/DAO com relógio controlado | ✅ Aprovado |
| TC-04 | Testes de widget (timer + histórico + integração) | ✅ Aprovado |
| TC-05 | Suíte completa de testes | ✅ Aprovado |
| TC-06 | Condição de corrida ao iniciar (retrabalho) | ✅ Aprovado |
| TC-07 | Iniciar/pausar com sub-métricas ao vivo | ✅ Aprovado |
| TC-08 | Sessão pausada sobrevive a fechar/reabrir o app | ✅ Aprovado |
| TC-09 | Retomar continua de onde parou | ✅ Aprovado |
| TC-10 | Timeline do dia | ✅ Aprovado |
| TC-11 | Encerrar volta para a Home | ✅ Aprovado |
| TC-12 | Histórico pela categoria sem iniciar sessão (retrabalho) | ✅ Aprovado |

**Resultado geral do ciclo:** 12/12 casos aprovados. Critério de pronto do M2 (planning.md) atendido — gate liberado para início do M3 (Arquivamento, histórico compactado e retenção de dados).

**Cobertura de testes (domain/data, gate do milestone):**

| Camada | Arquivo | Linhas cobertas |
|---|---|---|
| domain/usecases | 8 arquivos (start/pause/resume/stop/watch×4) | 100% (todos) |
| data/repositories | `timer_repository_impl.dart` | 100% (45/45) |
| core/database/daos | `timer_dao.dart` | 100% (104/104) |
| domain/entities | `timer_session.dart` | 100% (17/17) |
| domain/entities | `timer_interval.dart` | 80% (4/5) |

Total: 53 testes automatizados passando no projeto. Deste milestone: 8 testes de usecases + 17 de repositório/DAO + 7 de widget (timer + histórico + integração com a Home, incluindo o acesso ao histórico via categoria) = 32 testes novos.

**Observações:**
- **Decisão de design revisada durante os testes, não depois:** a primeira versão fazia "iniciar novo timer" *pausar* a sessão anterior; escrever os testes do DAO expôs que isso permite múltiplas sessões pausadas simultâneas, quebrando o invariante "uma sessão ativa por vez". Trocado para *encerrar* a anterior, o que também simplificou `resumeSession` (não precisa mais verificar se há outra sessão rodando para pausar).
- Adicionado `package:clock` como dependência explícita para permitir testar acumulação de tempo sem `sleep` real — os 17 testes de repositório/DAO rodam em ~instantâneo apesar de simularem minutos de sessões.
- A técnica de `uiautomator dump` para obter bounds exatos de botões (em vez de estimar visualmente a partir do screenshot) foi necessária para acertar o botão "Stop" de forma confiável — vale usá-la desde o início nos próximos ciclos de QA manual em vez de só recorrer a ela após taps errados.
