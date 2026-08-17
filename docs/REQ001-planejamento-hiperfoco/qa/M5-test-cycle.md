# Ciclo de Testes — M5 (Metas & Etapas)

## Metadados

| Campo | Valor |
|---|---|
| Milestone | M5 — Metas & Etapas |
| Data de execução | 2026-08-17 |
| Executor | Claude (Claude Code), testes automatizados (`flutter test --coverage`) + testes manuais via `adb` |
| Ambiente | Android Emulator `Pixel_7`, resolução 1080x2400, build debug (`app-debug.apk`), variant `com.hiperfoco.hiperfoco` |
| Referência de escopo | `docs/REQ001-planejamento-hiperfoco/planning.md`, seção "Roadmap faseado → M5" |

## Requisitos cobertos pelo milestone

1. `Goals` + `GoalSteps` (schema v5→v6): meta com título/descrição, etapas com título, `isDone`, `sortOrder` e `linkedTaskId` opcional.
2. CRUD completo de metas (`CreateGoal`, `UpdateGoal`, `DeleteGoal`, `WatchGoals`) e de etapas (`CreateGoalStep`, `SetGoalStepDone`, `ReorderGoalSteps`, `DeleteGoalStep`, `WatchGoalSteps`).
3. Lista de metas com progresso (`done/total` etapas) e exclusão com confirmação.
4. Detalhe da meta: checklist reordenável (drag-and-drop via `ReorderableListView`), adicionar etapa, marcar/desmarcar concluída, excluir etapa.
5. Ação "promover etapa a tarefa" (`PromoteGoalStepToTask`): cria uma `Task` vinculada à etapa (escolhendo categoria) e marca a etapa como promovida (badge "Promoted", sem novo botão de promover).
6. Acesso à tela de Metas a partir da AppBar de Tarefas (ícone de bandeira).
7. Cascata de exclusão consistente com o restante do app: excluir uma meta remove suas etapas; excluir uma tarefa (`DeleteTask`) desvincula (`linkedTaskId = null`) qualquer etapa que a referenciava, em vez de deixá-la órfã.

## Critério de pronto (gate do milestone, conforme planning.md)

> Criar meta → dividir em passos → marcar progresso → opcionalmente promover passo a tarefa, tudo funcional.

## Casos de teste

### TC-01 — Análise estática sem warnings

**Resultado obtido:** `No issues found! (ran in 3.2s)`

**Status:** ✅ Aprovado

---

### TC-02 — `Goal.copyWith` e `GoalStep`: entidades imutáveis

- **Dado** uma meta com todos os campos nuláveis preenchidos
- **Quando** chamo `copyWith` omitindo um campo, passando `null` explicitamente, ou passando um novo valor
- **Então** omitir mantém o valor atual; `null` explícito limpa `description`; um novo valor substitui — reaproveitando desde o início o padrão sentinel corrigido em `Task.copyWith` no M4, sem repetir aquele bug em uma entidade nova

**Resultado obtido:** 4 testes passando (`goal_test.dart`). `goal.dart` 100% (10/10 linhas).

**Status:** ✅ Aprovado

---

### TC-03 — Repositórios com Drift in-memory

- **Dado** `GoalRepositoryImpl` e `GoalStepRepositoryImpl` contra um banco Drift real (em memória)
- **Quando** exercito create/update/delete/watch, incluindo `countForGoal` (usado para calcular `sortOrder` da nova etapa), `setDone`, `setLinkedTask`/`clearLinkedTask`, e `updateSortOrders` (reorder transacional)
- **Então** todas as operações devem persistir e refletir corretamente, incluindo o cenário cross-feature: uma etapa vinculada a uma tarefa real (criada via `CategoryRepositoryImpl`+`TaskRepositoryImpl`) deve ter `linkedTaskId` limpo por `clearLinkedTask`

**Resultado obtido:** 13 testes passando (`goal_repository_impl_test.dart` 5, `goal_step_repository_impl_test.dart` 8). `goal_repository_impl.dart` e `goal_step_repository_impl.dart` 100% (25/25 e 31/31 linhas).

**Status:** ✅ Aprovado

---

### TC-04 — Usecases novos cobertos por testes unitários

- **Dado** os 10 usecases da feature (`WatchGoals`, `CreateGoal`, `UpdateGoal`, `DeleteGoal`, `WatchGoalSteps`, `CreateGoalStep`, `SetGoalStepDone`, `ReorderGoalSteps`, `DeleteGoalStep`, `PromoteGoalStepToTask`), mockando os repositórios
- **Quando** cada um é chamado
- **Então** cada um delega corretamente ao(s) repositório(s); `DeleteGoal` deve deletar as etapas **antes** da meta (`verifyInOrder`); `PromoteGoalStepToTask` deve criar a tarefa **antes** de vincular a etapa (`verifyInOrder`)

**Resultado obtido:** 10 testes passando (`goal_usecases_test.dart`). Todos os 10 usecases 100% cobertos.

**Status:** ✅ Aprovado

---

### TC-05 — `DeleteTask` desvincula etapas de meta (retrabalho da cascata do M4, crítico)

> **Extensão direta da cascata de exclusão criada no M4 (TC-08 daquele ciclo):** como `GoalSteps.linkedTaskId` é mais uma referência não-FK a `Tasks` (Drift não aplica `PRAGMA foreign_keys`), `DeleteTask` ganhou um quarto argumento de construtor (`GoalStepRepository`) e agora chama `goalStepRepository.clearLinkedTask(taskId)` antes de `taskRepository.delete`, na mesma orquestração que já limpa lembretes e overrides.

- **Dado** uma etapa de meta vinculada a uma tarefa (`linkedTaskId` preenchido)
- **Quando** a tarefa é deletada via `DeleteTask`
- **Então** `linkedTaskId` da etapa deve virar `null` — verificado tanto com mocks (`verifyInOrder` incluindo `goalStepRepository.clearLinkedTask(1)`) quanto end-to-end contra Drift real (`delete_task_cascade_test.dart`, estendido neste milestone para criar meta+etapa, vincular, deletar a tarefa, e reler a etapa do banco)

**Resultado obtido:** ambos os testes passando; nenhuma etapa órfã restante após a exclusão.

**Status:** ✅ Aprovado

---

### TC-06 — Testes de widget: `GoalsListScreen`

- **Dado** a tela de lista de metas
- **Quando** não há metas, uma meta é criada pelo formulário, uma meta tem etapas com progresso parcial, ou uma meta é excluída
- **Então** o estado vazio aparece corretamente; a meta criada aparece na lista; o progresso `done/total` é exibido corretamente; excluir remove a meta **e suas etapas** (verificado com uma query one-shot no Drift, não um `.watch()` cru fora da árvore de widgets — mesma lição de hang de teste já documentada no TC-08 do M3 e reaplicada aqui)

**Resultado obtido:** 4 testes passando.

**Status:** ✅ Aprovado

---

### TC-07 — Testes de widget: `GoalDetailScreen` (crítico)

> **Bug real encontrado por este teste, não artefato de teste:** `_promote` usava `ref.read(categoriesListProvider()).valueOrNull`, que retorna o estado inicial `AsyncLoading` (sincronamente `null`) quando nada mais na árvore já assinou aquele provider — o diálogo de promoção mostrava incorretamente o snackbar de "nenhuma categoria" mesmo havendo categorias cadastradas. Corrigido trocando para `await ref.read(categoriesListProvider().future)`, que aguarda de fato a primeira emissão do stream.

- **Dado** a tela de detalhe de uma meta
- **Quando** não há etapas, uma etapa é adicionada pelo campo de texto, o checkbox de uma etapa é marcado, ou uma etapa é promovida a tarefa (escolhendo categoria no diálogo)
- **Então** o estado vazio aparece corretamente; a etapa adicionada aparece na lista; marcar o checkbox reflete em `isDone`; promover cria uma `Task` real (confirmado com query one-shot no Drift) e a UI mostra o badge "Promoted" com o ícone de promover removido

**Resultado obtido:** 4 testes passando (após a correção do bug de race condition).

**Status:** ✅ Aprovado (após correção)

---

### TC-08 — Suíte completa de testes

**Resultado obtido:** `+190: All tests passed!`

**Status:** ✅ Aprovado

---

### TC-09 — Verificação manual em device: criar meta, adicionar etapas, marcar progresso

- **Dado** a tela de Metas (acessível pelo ícone de bandeira na AppBar de Tarefas)
- **Quando** crio a meta "Aprender Flutter" e adiciono as etapas "Ler a documentação" e "Construir um app"
- **Então** ambas as etapas devem aparecer na lista, e marcar uma como concluída deve refletir imediatamente no progresso (`1/2`) tanto no detalhe quanto na lista de metas

**Resultado obtido:** exatamente isso — checkbox marcado com texto riscado no detalhe, "1/2" exibido na lista de metas.

**Status:** ✅ Aprovado

---

### TC-10 — Verificação manual em device: promover etapa a tarefa ponta-a-ponta (crítico)

- **Dado** a meta "Aprender Flutter" com a etapa "Construir um app" ainda não promovida, e a categoria "Estudos" já cadastrada
- **Quando** toco o ícone de promover na etapa, seleciono "Estudos" no diálogo
- **Então** a etapa deve mostrar o badge "Promoted" (ícone de promover removido), **e** navegando até a tela de Tarefas a tarefa "Construir um app" deve existir com a categoria "Estudos" corretamente atribuída

**Resultado obtido:** badge "Promoted" confirmado no detalhe da meta (screenshot); navegando de volta até Tarefas, "Construir um app" aparece com o indicador roxo de "Estudos" — confirma que o usecase realmente criou a `Task` e não apenas atualizou a UI local.

**Status:** ✅ Aprovado — este é o critério de pronto central do M5.

---

### TC-11 — Verificação manual em device: excluir etapa não afeta a tarefa promovida

- **Dado** a etapa "Construir um app" já promovida (badge visível) e a tarefa correspondente existindo em Tarefas
- **Quando** excluo a etapa pelo ícone de lixeira no detalhe da meta
- **Então** a etapa deve desaparecer da lista de etapas, **mas a tarefa "Construir um app" deve continuar existindo** em Tarefas — a promoção é um vínculo de mão única (criar a tarefa), não uma sincronização bidirecional de ciclo de vida

**Resultado obtido:** etapa removida do detalhe da meta (restou só "Ler a documentação"); tarefa "Construir um app" continuou visível em Tarefas com a categoria "Estudos" intacta.

**Status:** ✅ Aprovado

---

### TC-12 — Verificação manual em device: excluir meta remove suas etapas (crítico)

- **Dado** a meta "Aprender Flutter" com a etapa restante "Ler a documentação"
- **Quando** excluo a meta pelo ícone de lixeira na lista de metas, confirmando no diálogo ("Are you sure you want to delete... All its steps will be deleted too.")
- **Então** a meta deve desaparecer da lista, mostrando o estado vazio

**Resultado obtido:** lista de metas voltou para "No goals yet. Tap + to create one." após a confirmação — consistente com a cobertura automatizada do TC-06 (que já verifica a ausência de etapas órfãs no banco).

**Status:** ✅ Aprovado

---

### TC-13 — Verificação manual em device: telas não afetadas continuam funcionando

**Resultado obtido:** navegação entre Home/Tasks/Calendar/Stats/Settings e a tela de Tarefas (incluindo o novo ícone de Metas na AppBar, ao lado do sino de Lembretes) renderizou normalmente, sem regressão visível causada pelas mudanças de schema/UI do M5.

**Status:** ✅ Aprovado

---

## Resumo

| ID | Caso de teste | Status |
|---|---|---|
| TC-01 | Análise estática sem warnings | ✅ Aprovado |
| TC-02 | `Goal.copyWith` e entidades imutáveis | ✅ Aprovado |
| TC-03 | Repositórios (Drift in-memory) | ✅ Aprovado |
| TC-04 | Usecases novos cobertos por testes | ✅ Aprovado |
| TC-05 | `DeleteTask` desvincula etapas (retrabalho, crítico) | ✅ Aprovado |
| TC-06 | Widget: `GoalsListScreen` | ✅ Aprovado |
| TC-07 | Widget: `GoalDetailScreen` (bug de race condition) | ✅ Aprovado |
| TC-08 | Suíte completa de testes | ✅ Aprovado |
| TC-09 | Manual: criar meta, etapas, progresso | ✅ Aprovado |
| TC-10 | Manual: promover etapa a tarefa ponta-a-ponta | ✅ Aprovado |
| TC-11 | Manual: excluir etapa não afeta tarefa promovida | ✅ Aprovado |
| TC-12 | Manual: excluir meta remove etapas | ✅ Aprovado |
| TC-13 | Manual: telas existentes sem regressão | ✅ Aprovado |

**Resultado geral do ciclo:** 13/13 casos aprovados. Critério de pronto do M5 (planning.md) atendido — gate liberado para início do M6 (Estatísticas).

**Cobertura de testes (domain/data, gate do milestone):**

| Camada | Arquivo | Linhas cobertas |
|---|---|---|
| domain/entities | `goal.dart`, `goal_step.dart` | 100% (10/10, 4/4) |
| domain/usecases | 10 arquivos novos | 100% (todos) |
| data/repositories | `goal_repository_impl.dart` | 100% (25/25) |
| data/repositories | `goal_step_repository_impl.dart` | 100% (31/31) |
| core/database/daos | `goal_dao.dart`, `goal_step_dao.dart` | 100% (11/11, 31/31) |
| domain/usecases (retrabalho) | `delete_task.dart` (cascata estendida) | 100% |

Total: 190 testes automatizados passando no projeto (155 ao final do M4 + 35 novos deste milestone).

**Observações:**
- **Um bug real foi encontrado neste ciclo** (TC-07): a mesma classe de erro de "ler um provider Riverpod antes de qualquer coisa tê-lo assinado" que já havia causado hangs de teste no M3/M4 (por outro motivo — `.watch()` cru fora da árvore de widgets) desta vez causou um bug de produto real: o diálogo de promoção parecia não encontrar categorias existentes. `ref.read(provider.future)` deve ser preferido a `ref.read(provider).valueOrNull` sempre que o provider não é garantidamente já assistido por outro widget na árvore.
- **Design deliberado confirmado por QA manual (TC-11):** a promoção etapa→tarefa é unidirecional. Excluir a etapa promovida não exclui a tarefa gerada, e excluir a meta (que cascata para as etapas) também não toca as tarefas já promovidas — apenas a exclusão da tarefa em si desvincula a etapa (TC-05), nunca o contrário. Esse comportamento não estava explicitamente escrito no planning.md, mas é a única opção consistente com "promover" ser uma ação de criação, não um espelhamento de dois registros.
- Testado manualmente apenas o long-press-and-drag do `ReorderableListView` via inspeção de código e cobertura de `ReorderGoalSteps`/`updateSortOrders` (testado ponta-a-ponta contra Drift real no TC-03) — o gesto de arrastar em si não foi exercitado manualmente no emulador porque `adb shell input swipe` não reproduz de forma confiável o long-press inicial que o `ReorderableListView` exige antes de aceitar o arrasto. Risco considerado baixo: é um widget padrão do Flutter, e toda a lógica de reordenação abaixo dele (cálculo do novo `sortOrder`, persistência transacional) está 100% coberta por teste automatizado.
