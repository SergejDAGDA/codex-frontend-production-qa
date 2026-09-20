# Frontend Production QA

[English version](README.md)

Переиспользуемый навык для Codex, который оркестрирует production frontend-разработку и QA.

Он не заменяет специализированные навыки. Его задача — выбрать правильную глубину проверки, подключить нужные инструменты и определить, когда browser-facing задача действительно завершена.

## Зачем он нужен

Frontend может успешно собираться и при этом оставаться сломанным:

- исправление desktop ломает mobile;
- один screenshot выглядит правильно, а другой viewport уже переполнен;
- shared component ломается на другой странице;
- screenshots генерируются, но фактически не просматриваются;
- baseline обновляется вместо исправления regression;
- plugin зарегистрирован, но нужный skill payload реально отсутствует.

`frontend-production-qa` добавляет вокруг таких случаев обязательный evidence-based workflow.

## Основной workflow

```text
правила проекта
  -> анализ и воспроизведение
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
| A | layout, responsive, перенос текста, shared UI, navigation, подготовка релиза | реальный браузер + полная матрица 8 viewport + visual QA + regression closure |
| B | небольшая визуальная правка без реалистичного влияния на геометрию | реальный браузер + сокращённая матрица 3 viewport + визуальная проверка |
| C | невизуальное browser-facing изменение | точечная browser-проверка |
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

Workflow ожидает:

- `frontend-ui-engineering`
- `browser-testing-with-devtools`
- `frontend-visual-qa`
- Chrome DevTools MCP

Первые два навыка берутся из [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills).

`frontend-visual-qa` — из [daymade/claude-code-skills](https://github.com/daymade/claude-code-skills).

Chrome DevTools MCP — из [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp).

Рекомендуемый design-quality слой:

- [Impeccable](https://github.com/pbakaus/impeccable)

Опционально можно использовать уже установленные:

- `taste-skill`
- `karpathy-guidelines`
- `context-engineering`
- `maintain-project-memory`

Этот репозиторий не устанавливает и не обновляет optional integrations.

## Установка навыка

Нужна только папка:

```text
skills/frontend-production-qa/
```

Для глобальной установки Codex:

```text
~/.agents/skills/frontend-production-qa/
```

После установки нужно запустить новую сессию Codex.

## Подключение к проекту

Не копируйте весь skill в `AGENTS.md`.

Используйте короткий routing fragment:

```text
skills/frontend-production-qa/assets/AGENTS.frontend.fragment.md
```

Архитектура проекта, юридические ограничения, design decisions и project memory остаются главным источником правил.

## Обслуживание toolchain

Из папки установленного навыка:

```powershell
.\scripts\check-frontend-toolchain.ps1
.\scripts\bootstrap-frontend-toolchain.ps1
.\scripts\check-frontend-updates.ps1
.\scripts\update-frontend-toolchain.ps1 -Apply
```

Обычная frontend-задача не должна незаметно устанавливать или обновлять сторонние зависимости.

Подробности:

- [Зависимости](skills/frontend-production-qa/references/dependencies.md)
- [Матрица проверки](skills/frontend-production-qa/references/verification-matrix.md)
- [Обслуживание toolchain](skills/frontend-production-qa/references/toolchain-maintenance.md)

## Центральное правило regression closure

Любое последующее изменение CSS/layout/spacing/typography/positioning/sizing/visibility/breakpoint/shared styles делает предыдущую visual verification недействительной для затронутой области.

После исправления соответствующие browser и responsive проверки выполняются заново.

Нельзя сообщать `done`, `fixed` или `ready`, если обязательная проверка не завершена.

## Лицензия

MIT.
