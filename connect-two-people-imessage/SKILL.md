---
name: connect-two-people-imessage
description: Connect two people over iMessage using Advay's standard intro template. Use when the user asks to intro or connect two contacts over Messages/iMessage, resolve both contacts, send the fixed body `<Person 1>, <Person 2>: meet each other` in a two-recipient iMessage draft with `sms://open?addresses=...`, keep Messages in the background when possible, and verify the send without guessing ambiguous contacts.
argument-hint: <person 1> and <person 2>
user-invocable: true
---

# Connect Two People Over iMessage

Use this skill when the user wants an intro thread between two people in Messages. The default is background-only automation. Resolve the contacts first, format the standard intro body as `<Person 1>, <Person 2>: meet each other`, and send it in a two-recipient iMessage thread.

## Inputs

- Required: two people to connect
- Preferred: exact contact names as they appear in Contacts or Messages

If either person is ambiguous, ask a short disambiguation question before sending anything.

## Workflow

1. Resolve both contacts before touching Messages.
   - Use Contacts and Messages participants to map each person to a real iMessage-capable handle.
   - Prefer the iMessage participant object over Contacts alone when both exist.
   - Never guess between multiple people with the same first name.

2. Build the fixed intro body.
   - Use the exact format `<Person 1>, <Person 2>: meet each other`.
   - Use the resolved display names, not raw phone numbers.
   - Preserve the user-specified order unless they say otherwise.

3. Keep Messages in the background by default.
   - Prefer `open -g` so Messages does not become frontmost.
   - Do not call `activate` on Messages unless the user explicitly allows foreground automation.

4. Use the known-working two-recipient compose route.
   - Use `sms://open?addresses=` rather than plain `sms:`.
   - Plain `sms:` can collapse to a single recipient.
   - The working pattern is:

```bash
open -g "sms://open?addresses=<handle1>,<handle2>&body=<url-encoded body>"
```

5. Verify the draft before sending.
   - Confirm the `To:` field contains both recipients.
   - Confirm the compose field contains the intended body.
   - Confirm Messages is not frontmost if the user requested background behavior.

6. Send with a process-targeted Return key.
   - Get the Messages PID from System Events.
   - Post a Return key event to that PID with JXA/ApplicationServices so the send goes to Messages instead of the user's active app.
   - Prefer the bundled `scripts/send_background_group_imessage.sh` helper for this step.

7. Verify send success.
   - After sending, the compose field should clear while the two-recipient thread remains open.
   - If the draft does not clear, do not claim success.

## Hard Stops

- Stop if either contact is ambiguous.
- Stop if you cannot confirm both recipients in the draft.
- Stop instead of bringing Messages to the foreground unless the user explicitly agrees.

## Helper Script

- Use `scripts/send_background_group_imessage.sh "<handle1>" "<handle2>" "<body>"` for the background compose-and-send path.
- The script composes the draft in the background, verifies both recipients and body, posts Return to the Messages PID, and verifies the compose field cleared.
