# Current Work State
*Example for the club newsletter (see PRD-EXAMPLE-newsletter-tool.md). Blueprint template: blueprint/tasks/current.md*

## Active Task
Unsubscribe link (PRD feature 4)

## Status
IN_PROGRESS

## PRD Section
PRD › Features #4

## Domain
backend

## Decisions Made
- Unsubscribed addresses stay in the database with status "unsubscribed": otherwise a later import could mail them again (PRD › Data).
- Tokens are signed, not stored: one less table to migrate.

## Current Blockers
- None

## Completed Subtasks
- [x] Token helper src/lib/tokens.ts (signToken, verifyToken) + tests
- [ ] Route GET /unsubscribe
- [ ] Link in the mail footer

## Exact Next Action
Create src/routes/unsubscribe.ts with GET /unsubscribe?token=... . Verify the token with verifyToken from src/lib/tokens.ts; on success set the subscriber's status to "unsubscribed" and show a plain confirmation page; on an invalid or expired token show the error page from src/views/error.html. Add tests/unsubscribe.test.ts covering valid, expired and tampered tokens. Done when npm test passes.

## Files Modified This Session
- src/lib/tokens.ts: new, signs and verifies tokens
- tests/tokens.test.ts: new
