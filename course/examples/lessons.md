# Lessons & Self-Improvement Rules
*Example for the club newsletter. Checked at the start of every session. Blueprint template: blueprint/tasks/lessons.md*

## Project-Specific Rules
- Pass --test to npm run send while developing — learned after a test run was about to go to the full list and the hard rule in CLAUDE.md stopped it.
- Run the SQLite migration against a copy (cp data/subscribers.db data/subscribers.backup.db) first — learned after a migration dropped the confirmed_at column.

## Patterns to Avoid
- Don't build the unsubscribe URL from the raw e-mail address — anyone could unsubscribe anyone. Use signToken.

## Recurring Bugs
- Confirmation mails rendered as plain text: the Markdown converter was called after the template was filled. Root cause: wrong call order in src/mail/render.ts. Fixed by converting first, then filling the template.
