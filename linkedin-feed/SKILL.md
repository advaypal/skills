---
name: linkedin-feed
description: Check the user's LinkedIn home feed and surface the most important and technically relevant posts. Use when the user asks to check their LinkedIn, see what's trending on LinkedIn, or wants a LinkedIn feed summary.
argument-hint: [number of scrolls (optional, defaults to 3)]
user-invocable: true
allowed-tools: mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_click, mcp__playwright__browser_wait_for, mcp__playwright__browser_press_key, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_evaluate, AskUserQuestion
---

# LinkedIn Feed Reader

Read the user's LinkedIn home feed and summarize the most important posts, with a focus on technical content.

## /etc/hosts Setup

LinkedIn is blocked in `/etc/hosts`. Before navigating, ask the user to run the unblock command, then wait for them to confirm before proceeding. After the skill is done, ask them to run the restore command.

1. **Before starting**: Tell the user to run: `sudo sed -i '' '/^127.0.0.1 www.linkedin.com/s/^/#/' /etc/hosts && dscacheutil -flushcache`
   Wait for the user to confirm they've run it before proceeding.
2. **After finishing** (even if errors occur): Tell the user to run: `sudo sed -i '' '/^#127.0.0.1 www.linkedin.com/s/^#//' /etc/hosts`

## Browser Sharing Warning

Do NOT run this skill in parallel with other browser-based skills (e.g., twitter-feed). They share the same Playwright browser instance and will steal focus from each other, causing both to fail. Run them sequentially.

## Steps

1. Navigate to `https://www.linkedin.com/feed/` using the Playwright browser.
2. Wait 3 seconds for the page to fully load.
3. Check if logged in by taking a snapshot or screenshot. If redirected to login, inform the user.
4. Extract feed content using `page.evaluate()` with `document.querySelector('main').innerText` — LinkedIn's DOM is too large for snapshots, so use JS extraction instead.
5. Scroll down to load more posts. **IMPORTANT**: LinkedIn uses a custom scroll container, NOT window scroll. The scrollable element is `document.getElementById('workspace')`. Use:
   ```js
   document.getElementById('workspace').scrollBy(0, 2000)
   ```
   Do NOT use `window.scrollTo()`, `window.scrollBy()`, `document.body.scrollHeight`, `page.mouse.wheel()`, or keyboard `End` key — none of these work on LinkedIn because the window/body is not the scroll container.
6. After each scroll, wait 2 seconds for new content to load, then extract again.
7. Repeat scrolling for the number of times specified in `$ARGUMENTS` (default: 3 scrolls).
8. Extract links separately using `document.querySelectorAll('main a[href]')` to capture article URLs and external links.

## Content Extraction Pattern

```js
// Extract text content
const text = document.querySelector('main').innerText;
// Return in chunks if too large (max ~15000 chars per chunk)
return text.substring(startIndex, endIndex);
```

```js
// Scroll the feed
const ws = document.getElementById('workspace');
ws.scrollBy(0, 2000);
// Returns { scrollTop, scrollHeight } to verify scrolling worked
```

## Handling Login

- If the page redirects to a login page, inform the user they need to log in first.
- Guide them through the login flow if needed.

## Output Format

After collecting posts, present a curated list of the most technically relevant posts. For each post include:

- **Author** (name, headline, time posted)
- **Engagement** (reactions, comments, reposts)
- **Full post text** — always paste the complete, untruncated content
- **Links** — if the post contains any links, include them
- **Shared/quoted posts** — if the post shares another post, include that content too
- **Articles** — if the post links to an article, include the article title and preview text

Filter for technical topics: AI/ML, software engineering, programming, systems, infrastructure, research papers, startups, developer tools, open source. Skip ads, lifestyle content, and non-technical posts unless they are exceptionally high-engagement from accounts the user follows.

Also include a "LinkedIn News / Trending" section from the sidebar if visible.
