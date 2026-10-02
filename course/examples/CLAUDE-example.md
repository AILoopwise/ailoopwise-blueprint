## Project: Club Newsletter
Collects sign-ups on the club website (double opt-in) and sends a monthly Markdown newsletter as HTML mail.

## Tech Stack
- Node.js + TypeScript
- SQLite (data/subscribers.db)
- Mail provider API, key only in .env

## Conventions
- Source in src/, tests in tests/ next to the feature name (src/routes/unsubscribe.ts -> tests/unsubscribe.test.ts)
- camelCase for variables and functions
- Subscribers are never deleted; status is pending | confirmed | unsubscribed

## Hard rules (the AI must never)
- Send to real subscribers. Every send command you run uses --test.
- Write the mail API key into code, tests or git. It lives only in .env.
- Drop or recreate data/subscribers.db without making a copy first.

## Session Protocol
- Check tasks/current.md for ongoing work
- Check tasks/lessons.md for project-specific rules
- Use subagents for research to preserve context
- Run tests before marking work complete

## Key Commands
- Build: npm run build
- Test: npm test
- Lint: npm run lint
- Typecheck: npx tsc --noEmit

## Mandatory Quality Checks
After every task run typecheck, lint, tests and build. Report which ones you ran and their result. A task is not done while one of them fails.
