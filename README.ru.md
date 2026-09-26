# Frontend Production QA

[English version](README.md)

Переиспользуемый Codex plugin для production frontend-разработки и QA.

Он не заменяет специализированные навыки. Его задача — оркестрировать их, выбирать глубину проверки browser-facing изменений и определять, когда задача действительно подтверждена достаточными доказательствами.

## Зачем он нужен

Frontend может успешно собираться и при этом оставаться сломанным:

- исправление desktop ломает mobile;
- один screenshot выглядит правильно, а другой viewport переполнен;
- shared component ломается на другой странице;
- screenshots создаются, но не просматриваются;
- visual baseline обновляется вместо исправления regression;
- анимация выглядит нормально в конечном состоянии, но ломается во время перехода или при reduced motion;
- plugin выглядит установленным, хотя нужный skill payload фактически отсутствует.

`frontend-production-qa` добавляет вокруг этих случаев обязательный evidence-based workflow.

## Установка напрямую из GitHub

GitHub-репозиторий является каноническим источником. При plugin-установке не нужно поддерживать отдельную ручную копию skill.

```powershell
codex plugin marketplace add SergejDAGDA/codex-frontend-production-qa --ref main
codex plugin add frontend-production-qa@codex-frontend-production-qa
```

После установки запустите новую сессию Codex.

### Обновление из GitHub

```powershell
codex plugin marketplace upgrade codex-frontend-production-qa
codex plugin add frontend-production-qa@codex-frontend-production-qa
```

После этого также нужно открыть новую сессию Codex.

Вторая команда намеренно может выполняться повторно: она гарантирует материализацию plugin payload из обновлённого snapshot marketplace.

### Единственный источник версии

Публичная версия plugin хранится только здесь:

```text
plugin.json
```

В `SKILL.md` и dependency manifests отдельную release version добавлять не нужно.

Каждое опубликованное изменение plugin должно одновременно увеличивать version в manifest и обновлять `CHANGELOG.md`.

### Переход со старых ручных установок

Если `frontend-production-qa` или `frontend-visual-qa` раньше вручную копировались в `~/.agents/skills/`, старую активную копию нужно удалить или переименовать перед plugin-установкой.

Поддерживаемый `frontend-visual-qa` теперь включён непосредственно в этот repository и не должен восстанавливаться как floating runtime dependency из Daymade.

## Встроенный Inspo MCP

Plugin включает hosted MCP проекта [Inspo](https://github.com/Nutlope/inspo):

```text
https://inspomcp.dev/api/mcp
```

Inspo даёт агенту поиск по реальным production-сайтам и их design patterns. Оркестратор использует его выборочно для:

- нового UI;
- новых компонентов;
- существенного redesign;
- поиска визуального направления;
- исследования hierarchy/layout;
- явного запроса на references или inspiration.

Inspo не становится источником дизайна существующего проекта. При bugfix, screenshot matching, responsive regression или необходимости сохранить уже утверждённый visual language главным источником остаётся сам проект.

Отдельная команда `codex mcp add inspo ...` при plugin-установке не нужна.

## Conditional Motion specialist

Для задач, где существенны анимация и интерактивное движение, orchestrator может использовать официальный `/motion` skill из Motion AI Kit: [motiondivision/ai-kit](https://github.com/motiondivision/ai-kit).

Установка или обновление выполняется отдельно:

```powershell
npx motion-ai@latest
```

Motion является **recommended conditional specialist**. Он не обязателен для базовой готовности `frontend-production-qa` и не bundled в этот repository.

Использовать его нужно, когда задача существенно затрагивает:

- animation или transitions;
- enter/exit presence;
- layout/shared-layout animation;
- drag, swipe, reorder или gestures;
- spring motion;
- scroll-triggered или scroll-linked effects;
- animation performance.

Routing остаётся CSS-first. Простые hover/focus/opacity/loading эффекты должны оставаться нативным CSS, когда этого достаточно. Наличие `/motion` skill не является разрешением добавить runtime-пакет `motion` или заменить уже используемую animation library.

Для существенных motion-изменений workflow проверяет initial, transient, settled, repeated/interrupted и `prefers-reduced-motion` состояния там, где это применимо.

Подробности: [Motion specialist routing](skills/frontend-production-qa/references/motion-specialist.md).

## Основной workflow

```text
правила проекта
  -> анализ и воспроизведение
  -> optional design references, если действительно нужны
  -> conditional Motion specialist, если действительно нужен
  -> frontend implementation
  -> design-quality слой, если нужен
  -> code checks
  -> реальный браузер
  -> responsive verification
  -> rendered visual QA
  -> regression closure
  -> условные review/security/performance/release gates
  -> доказательства завершения
```

## Классы проверки

| Класс | Типичное изменение | Проверка |
|---|---|---|
| A | layout, responsive, перенос текста, shared UI, layout-affecting motion, navigation, подготовка релиза | реальный браузер + полная матрица 8 viewport + visual QA + regression closure |
| B | небольшая visual-правка или transition без влияния на геометрию | реальный браузер + сокращённая матрица 3 viewport + visual inspection |
| C | невизуальное browser-facing изменение | точечная browser verification |
| D | backend/non-UI | frontend workflow не запускается, если rendered browser behavior не меняется |

Полная матрица:

```text
320x568
375x812
390x844
768x1024
1024x768
1280x800
1440x900
1920x1080
```

Сокращённая:

```text
390x844
768x1024
1440x900
```

Если меняется или подозревается breakpoint `B`, дополнительно проверяются `B-1`, `B`, `B+1`.

## Обязательный specialist stack

Core workflow ожидает:

- `frontend-ui-engineering`;
- `browser-testing-with-devtools`;
- bundled `frontend-visual-qa`;
- Chrome DevTools MCP.

Первые два навыка берутся из [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills).

`frontend-visual-qa` включён непосредственно в этот repository. Его исходный upstream — [daymade/claude-code-skills](https://github.com/daymade/claude-code-skills), но используемой версией является поддерживаемая здесь Codex-адаптация. Runtime maintenance не должен заменять её внешней копией.

Chrome DevTools MCP — из [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp).

Recommended conditional specialists/layers:

- Motion AI Kit `/motion` для существенной animation/gesture работы;
- [Impeccable](https://github.com/pbakaus/impeccable) для design-quality critique/polish.

Связанные необязательные skills:

- `ui-designer`;
- `qa-expert`.

Опционально можно использовать уже установленные:

- `taste-skill`;
- `karpathy-guidelines`;
- `context-engineering`;
- `maintain-project-memory`.

Оркестратор не должен незаметно устанавливать или обновлять recommended/optional integrations во время обычной frontend-задачи.

## Подключение к проекту

Не копируйте весь skill в `AGENTS.md`.

Используйте короткий routing fragment:

```text
skills/frontend-production-qa/assets/AGENTS.frontend.fragment.md
```

Архитектура проекта, юридические ограничения, design decisions и project memory остаются главным источником правил.

## Обслуживание зависимостей

Сам plugin обновляется через Git-backed marketplace.

Скрипты внутри skill обслуживают только основной внешний specialist toolchain и Impeccable при явном запросе:

```powershell
.\scripts\check-frontend-toolchain.ps1
.\scripts\bootstrap-frontend-toolchain.ps1
.\scripts\check-frontend-updates.ps1
.\scripts\update-frontend-toolchain.ps1 -Apply
```

Bundled `frontend-visual-qa` обновляется только через release этого repository/plugin.

Motion устанавливается или обновляется независимо:

```powershell
npx motion-ai@latest
```

Обычная frontend-задача не должна незаметно устанавливать или обновлять сторонние зависимости.

Подробности:

- [Зависимости](skills/frontend-production-qa/references/dependencies.md)
- [Motion specialist routing](skills/frontend-production-qa/references/motion-specialist.md)
- [Матрица проверки](skills/frontend-production-qa/references/verification-matrix.md)
- [Обслуживание toolchain](skills/frontend-production-qa/references/toolchain-maintenance.md)

## Центральное правило regression closure

Любое последующее изменение CSS/layout/spacing/typography/positioning/sizing/visibility/breakpoint/animation/transition/shared styles делает предыдущую visual verification недействительной для затронутой области.

После исправления соответствующие browser, responsive, motion-state и visual проверки выполняются заново.

Нельзя сообщать `done`, `fixed` или `ready`, если обязательная проверка не завершена.

## Лицензия

MIT.
