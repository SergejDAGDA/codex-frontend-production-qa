## Frontend workflow

For tasks that create, modify, fix, review, test, or prepare user-facing browser UI, use the `frontend-production-qa` skill.

This includes HTML, CSS, responsive layout, browser-side JavaScript, navigation, forms, interactive components, accessibility, animations, transitions, gestures, visual fixes, frontend regressions, and frontend release preparation.

When animation, gestures, layout motion, springs, drag/reorder, or scroll-linked effects are material to the task, let `frontend-production-qa` route to the available Motion specialist instead of introducing animation-library choices directly in this file.

Do not apply this workflow to backend-only, database-only, infrastructure-only, data-processing, or documentation-only work unless the change directly affects rendered browser behavior.

Keep project-specific architecture, product, legal, accessibility, design, release and project-memory constraints in this `AGENTS.md`.

Do not install, update, or repair third-party frontend skills during normal development work. Toolchain bootstrap and updates are explicit maintenance operations.
