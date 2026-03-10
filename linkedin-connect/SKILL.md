---
name: linkedin-connect
description: Connect with someone on LinkedIn based on a description (e.g., name, company, school). Use when the user asks to "connect with", "add", or "send a connection request" to someone on LinkedIn.
argument-hint: <description of the person, e.g. "Peter Nguyen who works at Twitch">
user-invocable: true
allowed-tools: mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_click, mcp__playwright__browser_wait_for, mcp__playwright__browser_press_key, mcp__playwright__browser_fill_form, mcp__playwright__browser_evaluate, AskUserQuestion
---

# LinkedIn Connect

Send a connection request to someone on LinkedIn based on a natural language description.

## /etc/hosts Setup

LinkedIn is blocked in `/etc/hosts`. Before navigating, ask the user to run the unblock command, then wait for them to confirm before proceeding. After the skill is done, ask them to run the restore command.

1. **Before starting**: Tell the user to run: `sudo sed -i '' '/^127.0.0.1 www.linkedin.com/s/^/#/' /etc/hosts && dscacheutil -flushcache`
   Wait for the user to confirm they've run it before proceeding.
2. **After finishing** (even if errors occur): Tell the user to run: `sudo sed -i '' '/^#127.0.0.1 www.linkedin.com/s/^#//' /etc/hosts`

## Browser Sharing Warning

Do NOT run this skill in parallel with other browser-based skills (e.g., twitter-feed, linkedin-feed). They share the same Playwright browser instance and will steal focus from each other, causing both to fail. Run them sequentially.

## Steps

1. **Build search query**: Extract keywords from `$ARGUMENTS` (name, company, school, role, etc.) and construct a LinkedIn people search URL:
   ```
   https://www.linkedin.com/search/results/people/?keywords=<url-encoded keywords>
   ```
   Include the person's name and key identifiers (company, school) in the keywords.

2. **Navigate** to the search URL using the Playwright browser.

3. **Wait** 3 seconds for the page to load.

4. **Check login**: Take a snapshot. If redirected to a login page, inform the user they need to log in first and guide them through it.

5. **Find the right person**: Take a snapshot of the search results. Match the person based on all details from `$ARGUMENTS`:
   - Name match
   - Company/employer match (current or past)
   - School/university match
   - Role/title match
   - Location match (if provided)

6. **Confirm with user**: Before clicking Connect, tell the user who you found and ask them to confirm this is the right person. Include the person's name, headline, and location from the search results.

7. **Send connection request**: Click the "Connect" button/link for the matched person. If a modal appears asking to add a note, click "Send without a note" unless the user specified a note to include.

8. **Verify**: Take a snapshot to confirm the button changed to "Pending", indicating the request was sent successfully.

9. **Report result**: Tell the user the connection request was sent, and remind them to re-block LinkedIn.

## Handling Multiple Matches

If multiple people match the description, present the top candidates to the user with their name, headline, and location, and ask which one to connect with.

## Handling No Matches

If no results match the description, try broadening the search (e.g., drop one keyword) and search again. If still no match, inform the user and suggest refining the description.

## Handling Login

- If the page redirects to a login page, inform the user they need to log in first.
- Suggest clicking "Continue with Google" or entering credentials manually.

## Error Handling

- If the Connect button is not available (already connected, pending, or blocked), inform the user of the current status.
- If LinkedIn shows a rate limit or CAPTCHA, inform the user and stop.
