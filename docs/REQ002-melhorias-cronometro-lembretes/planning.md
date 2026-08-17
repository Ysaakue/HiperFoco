# Planejamento — REQ002 (melhorias pós-MVP)

## Contexto

Ideias capturadas durante a implementação do M4 do REQ001 (2026-08-17), para não se perderem — **não** é um planejamento detalhado de arquitetura ainda. O trabalho nesta requisição só começa depois que o MVP do REQ001 (roadmap M0–M7) estiver concluído. Quando chegar a vez do REQ002, este documento deve ser revisado e expandido (decisões de arquitetura, milestones, critérios de pronto) antes de qualquer implementação, seguindo o mesmo processo usado no REQ001.

## Ideias capturadas

### 1. Lista de tarefas da categoria visível na tela do cronômetro

- Ao focar em uma categoria, a tela de cronômetro (`TimerScreen`) deve mostrar a lista de tarefas daquela categoria.
- Estado inicial: **colapsada** — não expor de cara, mantendo a tela do cronômetro limpa e sem distração extra, coerente com o princípio de UX-TDAH já estabelecido no planejamento do REQ001 ("tela de timer sem distrações", "uma ação primária por tela").
- Deve existir uma forma de expandir para ver a lista completa e marcar tarefas como concluídas diretamente dali, sem precisar sair do cronômetro e navegar até a aba Tarefas.
- Pontos a decidir quando o planejamento for retomado: o que aparece na lista colapsada (só contagem? próxima tarefa pendente?); como tarefas recorrentes (REQ001 M4) aparecem aqui — ocorrência de hoje, ou a tarefa "crua"; se marcar como concluída aqui deve ter o mesmo comportamento de `SetTaskStatus`/`SetOccurrenceStatus` já existentes ou precisa de um caminho dedicado.

### 2. Horários específicos para lembretes

- Hoje (REQ001 M4), um lembrete recorrente dispara sempre no horário embutido em `RecurrenceRule.startDate` — um único horário fixo por regra, herdado da data/hora de criação.
- A ideia é permitir configurar o horário do disparo de forma mais explícita/flexível dentro do dia, em vez de depender do horário de criação da regra.
- Pontos a decidir quando o planejamento for retomado: granularidade exata (um horário por regra, editável separadamente da data de início; ou múltiplos horários no mesmo dia para a mesma regra); como isso se encaixa no `ReminderSchedulingService` atual (que já resolve o "próximo disparo" a partir de `RecurrenceRule.startDate`'s hora/minuto).

## Quando será atacado

Depois da conclusão do MVP do REQ001 (M0–M7). Nenhuma implementação desta requisição foi iniciada.

## Status

**Backlog** — sem arquitetura, milestones ou critérios de pronto definidos ainda. Isso é feito quando o trabalho desta requisição começar de fato.
