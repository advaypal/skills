---
name: twitter-feed
description: Check the user's Twitter/X home feed and surface the most important and technically relevant tweets. Use when the user asks to check their Twitter, see what's trending, or wants a feed summary.
argument-hint: [username (optional, defaults to advaypal)]
user-invocable: true
allowed-tools: mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_click, mcp__playwright__browser_wait_for, mcp__playwright__browser_press_key, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_evaluate, AskUserQuestion, Bash
---

# Twitter/X Feed Reader

Read the user's Twitter/X home feed and summarize the most important tweets, with a focus on technical content.

## /etc/hosts Setup

Twitter/X is blocked in `/etc/hosts`. Before navigating, ask the user to run the unblock command, then wait for them to confirm before proceeding. After the skill is done, ask them to run the restore command.

1. **Before starting**: Tell the user to run: `sudo sed -i '' -e '/^127.0.0.1 x.com/s/^/#/' -e '/^127.0.0.1 twitter.com/s/^/#/' /etc/hosts && dscacheutil -flushcache`
   Wait for the user to confirm they've run it before proceeding.
2. **After finishing** (even if errors occur): Tell the user to run: `sudo sed -i '' -e '/^#127.0.0.1 x.com/s/^#//' -e '/^#127.0.0.1 twitter.com/s/^#//' /etc/hosts`

## Browser Sharing Warning

Do NOT run this skill in parallel with other browser-based skills (e.g., linkedin-feed). They share the same Playwright browser instance and will steal focus from each other, causing both to fail. Run them sequentially.

## Steps

1. Navigate to `https://x.com/home` using the Playwright browser.
2. Wait for the page to fully load (wait a few seconds after navigation).
3. Take a snapshot to read the "For you" tab tweets.
4. Scroll down (press `End` key) and wait, then snapshot again to get more tweets.
5. Switch to the "Following" tab by clicking on it.
6. Snapshot the Following tab tweets.
7. Scroll down on the Following tab as well to get more content.
8. For any tweets that are truncated (have a "Show more" button), click to expand them.

## Handling Login

- If the page redirects to a login page, inform the user they need to log in first.
- Guide them through the login flow if needed.

## Output Format

After collecting tweets from both tabs, present a curated list of the most technically relevant tweets. For each tweet include:

- **Author** (@handle, display name, time posted)
- **Engagement** (likes, reposts, replies)
- **Full tweet text** — always paste the complete, untruncated content
- **Links** — if the tweet contains any links, include them
- **Quoted tweets** — if the tweet quotes another tweet, include the quoted tweet's full text as well
- **Articles** — if the tweet links to an article, include the article title and preview text

Filter for technical topics: AI/ML, software engineering, programming, systems, infrastructure, research papers, benchmarks, open source, developer tools. Skip ads, lifestyle content, and non-technical posts unless they are exceptionally high-engagement from accounts the user follows.

Also include a "Trending" section from the sidebar if visible.

## Default Username

The user's Twitter username is `advaypal`. If `$ARGUMENTS` provides a different username, use that instead.
