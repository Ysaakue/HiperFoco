# Ciclo de Testes — M0 (Setup & Infraestrutura)

## Metadados

| Campo | Valor |
|---|---|
| Milestone | M0 — Setup & infraestrutura |
| Data de execução | 2026-08-14 |
| Executor | Claude (Claude Code), testes manuais simulados via `adb` + testes automatizados via `flutter analyze`/`flutter test` |
| Ambiente | Android Emulator `emulator-5554`, resolução 1080x2400 @420dpi, build debug (`app-debug.apk`), variant `com.hiperfoco.hiperfoco` |
| Referência de escopo | `docs/REQ001-planejamento-hiperfoco/planning.md`, seção "Roadmap faseado → M0" |

## Requisitos cobertos pelo milestone

1. Estrutura de pastas do projeto (Clean Architecture feature-first) e dependências do `pubspec.yaml` instaladas.
2. `AppDatabase` (Drift) inicializado, mesmo que vazio de tabelas de domínio.
3. Navegação em shell de abas (`go_router` + `ShellRoute`) com 5 destinos: Início, Tarefas, Calendário, Estatísticas, Ajustes — todas com tela placeholder.
4. Tema claro/escuro configurável nas Ajustes e persistido entre reinícios do app.
5. Idioma configurável (pt/en) nas Ajustes, com troca refletida imediatamente em toda a UI, incluindo a navegação inferior.
6. `analysis_options.yaml` configurado e projeto livre de warnings do analisador estático.
7. Suíte de testes automatizados (`flutter test`) executável e passando.

## Critério de pronto (gate do milestone, conforme PLANNING.md)

> `flutter analyze` sem warnings; `flutter run` em device/emulador Android navegando pelas 5 abas; alternar tema e idioma nas Settings reflete imediatamente.

## Casos de teste

### TC-01 — Análise estática sem warnings

- **Dado** o código-fonte do projeto em `c:\projects\HiperFoco`
- **Quando** executo `flutter analyze` na raiz do projeto
- **Então** o comando deve retornar "No issues found!" sem warnings ou erros

**Passos reproduzíveis:**
```
cd c:/projects/HiperFoco
flutter analyze
```

**Critério de aceite:** saída contém `No issues found!`; exit code 0.

**Resultado obtido:** `No issues found! (ran in 25.3s)`

**Status:** ✅ Aprovado

---

### TC-02 — Suíte de testes automatizados passa

- **Dado** o projeto com a suíte de testes em `test/widget_test.dart`
- **Quando** executo `flutter test`
- **Então** todos os testes devem passar sem falhas

**Passos reproduzíveis:**
```
cd c:/projects/HiperFoco
flutter test
```

**Critério de aceite:** saída indica `All tests passed!`, nenhum teste falho.

**Resultado obtido:** `App shell renders bottom navigation destinations` → `+1: All tests passed!`

**Status:** ✅ Aprovado

---

### TC-03 — App inicia no emulador Android

- **Dado** o build de debug instalado no emulador (`emulator-5554`)
- **Quando** o app é lançado via launcher intent
- **Então** o app deve abrir sem crash e exibir a tela inicial (Início) com o shell de navegação

**Passos reproduzíveis:**
```
adb -s emulator-5554 shell monkey -p com.hiperfoco.hiperfoco -c android.intent.category.LAUNCHER 1
adb -s emulator-5554 exec-out screencap -p > state.png
```

**Critério de aceite:** screenshot mostra título "HiperFoco", conteúdo da aba Início e barra de navegação inferior com 5 destinos.

**Status:** ✅ Aprovado

---

### TC-04 — Navegação pelas 5 abas do shell

- **Dado** o app aberto na aba Início
- **Quando** toco sequencialmente em Tarefas, Calendário, Estatísticas e Ajustes na barra de navegação inferior
- **Então** cada toque deve trocar o conteúdo da tela para a respectiva aba, com o título e ícone de destaque atualizados, sem travar ou sair do shell

**Passos reproduzíveis:** (bounds obtidos via `adb shell uiautomator dump`)
```
adb -s emulator-5554 shell input tap 324 2232   # Tarefas
adb -s emulator-5554 shell input tap 540 2232   # Calendário
adb -s emulator-5554 shell input tap 756 2232   # Estatísticas
adb -s emulator-5554 shell input tap 972 2232   # Ajustes
```
Screenshot após cada toque via `adb exec-out screencap -p`.

**Critério de aceite:** as 4 telas placeholder abrem corretamente, cada uma com título e ícone próprios ("Em breve"), e o destino ativo na barra inferior fica destacado.

**Resultado obtido:** Tarefas, Calendário e Estatísticas abriram corretamente com título e ícone próprios; destino ativo destacado em roxo em cada aba.

**Status:** ✅ Aprovado

---

### TC-05 — Alternância de tema reflete imediatamente

- **Dado** o app aberto em Ajustes com tema "Escuro" selecionado
- **Quando** toco na opção "Claro"
- **Então** toda a UI (fundo, texto, barra de navegação, botões segmentados) deve mudar para o esquema de cores claro imediatamente, sem necessidade de reiniciar o app

**Passos reproduzíveis:**
```
adb -s emulator-5554 shell input tap 972 2232   # abrir Ajustes
adb -s emulator-5554 shell input tap 208 472    # tocar em "Claro"
adb -s emulator-5554 exec-out screencap -p > state.png
```

**Critério de aceite:** screenshot pós-toque mostra fundo claro em toda a tela (incluindo status bar e nav bar) e o segmento "Claro" marcado com check.

**Status:** ✅ Aprovado

---

### TC-06 — Alternância de idioma reflete imediatamente

- **Dado** o app aberto em Ajustes com idioma "Português" selecionado
- **Quando** toco na opção "Inglês"
- **Então** todas as strings visíveis (título das telas, labels da navegação inferior, labels dos seletores de Aparência/Idioma) devem mudar para inglês imediatamente, sem reiniciar o app

**Passos reproduzíveis:**
```
adb -s emulator-5554 shell input tap 789 745    # tocar em "English"
adb -s emulator-5554 exec-out screencap -p > state.png
```

**Critério de aceite:** screenshot mostra "Settings", "Appearance", "Light/Dark/System", "Language", "Portuguese/English" e nav bar traduzida ("Home, Tasks, Calendar, Stats, Settings").

**Resultado obtido:** todas as strings verificadas traduzidas corretamente para inglês, incluindo a barra de navegação inferior.

**Status:** ✅ Aprovado

---

### TC-07 — Preferências persistem após reiniciar o app

- **Dado** o app configurado com tema "Escuro" e idioma "Português" (restaurados após TC-05/TC-06)
- **Quando** forço o encerramento do processo (`am force-stop`) e relanço o app pelo launcher
- **Então** o app deve reabrir já com tema "Escuro" e idioma "Português" aplicados, sem precisar reconfigurar

**Passos reproduzíveis:**
```
adb -s emulator-5554 shell input tap 540 472    # restaurar "Escuro"
adb -s emulator-5554 shell input tap 156 745    # restaurar "Português"
adb -s emulator-5554 shell am force-stop com.hiperfoco.hiperfoco
adb -s emulator-5554 shell monkey -p com.hiperfoco.hiperfoco -c android.intent.category.LAUNCHER 1
adb -s emulator-5554 exec-out screencap -p > state.png
```

**Critério de aceite:** screenshot pós-relaunch mostra tema escuro e labels em português ("Início", "HiperFoco") sem interação adicional do usuário.

**Resultado obtido:** app reabriu diretamente na aba Início, tema escuro e labels em português ("Início", "Tarefas", "Calendário", "Estatísticas", "Ajustes"), confirmando persistência via `shared_preferences`.

**Status:** ✅ Aprovado

---

## Resumo

| ID | Caso de teste | Status |
|---|---|---|
| TC-01 | Análise estática sem warnings | ✅ Aprovado |
| TC-02 | Suíte de testes automatizados passa | ✅ Aprovado |
| TC-03 | App inicia no emulador Android | ✅ Aprovado |
| TC-04 | Navegação pelas 5 abas do shell | ✅ Aprovado |
| TC-05 | Alternância de tema reflete imediatamente | ✅ Aprovado |
| TC-06 | Alternância de idioma reflete imediatamente | ✅ Aprovado |
| TC-07 | Preferências persistem após reiniciar o app | ✅ Aprovado |

**Resultado geral do ciclo:** 7/7 casos aprovados. Critério de pronto do M0 (PLANNING.md) atendido — gate liberado para início do M1 (Categorias + Tarefas).

**Observações:**
- Todos os testes de navegação/UI foram executados via automação `adb` (uiautomator dump para coordenadas exatas + `input tap` + `screencap`), simulando os passos manuais que um QA humano executaria em device físico.
- Nenhum caso coberto por este ciclo depende ainda de dados persistidos em `AppDatabase` (Drift) — isso será validado a partir do M1, quando `Categories`/`Tasks` passam a ter CRUD real.
