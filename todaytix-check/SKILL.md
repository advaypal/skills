---
name: todaytix-check
description: Check ticket prices on TodayTix for a Broadway show on a specific date. Use when the user wants to look up ticket availability or pricing for a musical or play in NYC.
argument-hint: [show-name] [date, e.g. "May 30 2026"]
user-invocable: true
allowed-tools: mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_click, mcp__playwright__browser_type, mcp__playwright__browser_wait_for, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_evaluate, mcp__playwright__browser_press_key, Bash, Read, Grep
---

# Check TodayTix Prices for "$0" on $1

You are looking up ticket prices on TodayTix (todaytix.com) for the show **$0** on the date **$1**.

## Steps

### 1. Navigate to TodayTix and search for the show

- Go to `https://www.todaytix.com/nyc/category/all-shows`
- Click the search icon in the top navigation bar
- Type the show name "$0" into the search box (use `slowly: true` to trigger suggestions)
- Click on the matching show result from the dropdown

### 2. Handle cookie consent

- If a cookie consent dialog appears, click "Accept all" to dismiss it

### 3. Select the date

- Parse the date "$1" to determine the target month and day
- The calendar defaults to the current month. Use the "Next month" / "Previous month" buttons to navigate to the correct month
- Click on the target day in the calendar
- If there are multiple showtimes, note all of them and their starting prices. Pick the evening show by default unless the user specified otherwise.

### 4. Enter the seat selection view

- Click "Pick your seats" to open the seating map
- Wait for the seating map to load (wait for "Finding you the best deals..." to disappear)

### 5. Identify sections and pricing

- The snapshot will be very large. Save it to a file and use grep/python to analyze it.
- Identify the available seating sections (e.g., Orchestra, Mezzanine, Balcony). They appear as `availableSection` blocks in the snapshot.
- The section labels (Orchestra, Mezzanine, etc.) appear near the end of the seating map data.
- Seats are identified as `seat-{ROW}-{NUMBER}` with available ones having `availableSeat` in their tooltip ref.
- Double-letter rows (AA, BB, CC, etc.) are typically side/box sections. Single-letter rows (A-N) are the main sections. Seats numbered 100+ are often in a separate sub-section (e.g., rear mezzanine vs front mezzanine).

### 6. Sample prices from different sections

- Click on representative seats from each section to see the price. When you click a seat tooltip (e.g., `tooltip-A-18-availableSeat`), a panel appears at the bottom showing:
  - Section name (e.g., "FMEZZ", "ORCH")
  - Row and seat numbers
  - Price per ticket including fees
  - Total price
- Sample at least one seat from each section/area:
  - Orchestra center
  - Orchestra sides
  - Mezzanine/Balcony center (front rows)
  - Mezzanine/Balcony center (back rows)
  - Mezzanine/Balcony sides
- After checking a seat's price, click the close/deselect button (the X icon) before selecting the next seat.

### 7. Report findings

Present a clear summary including:
- Show name, date, and venue
- Available showtimes and starting prices
- A price table broken down by section and approximate location (center vs sides, front vs back)
- Note any sections that are sold out
- The cheapest and most expensive options

## Tips

- The TodayTix URL pattern for NYC shows is: `https://www.todaytix.com/nyc/shows/{id}-{slug}`
- If the page returns a 404, use the search function instead of guessing URLs
- The seating map snapshot is huge (200K+ chars). Always save to file and use grep/python to parse it rather than reading inline.
- To find available seats, search for `availableSeat` patterns and extract row/seat/ref info with regex.
- Center seats in the main sections typically have seat numbers in the middle of the range (e.g., seats 14-24 in a 1-36 range, or seats 108-112 in a 101-118 range).
