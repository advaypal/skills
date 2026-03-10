---
name: glg-accept
description: Accept a GLG project from a link. Use when the user provides a GLG project link (glg.link or glgresearch.com) and asks to accept it. Automates the acceptance flow using saved preferences and asks the user for project-specific text box inputs.
---

This skill automates accepting GLG (Gerson Lehrman Group) consulting projects via the browser using Playwright MCP tools.

## Workflow

1. **Navigate** to the provided GLG project link
2. **Accept cookies** if the cookie dialog appears
3. **Click "Get Started"** to begin the acceptance flow
4. **Fill in Project Acceptance Questions** — these vary per project:
   - For **text box fields**: ASK the user what to enter. These are project-specific (e.g., roles/responsibilities, years of experience, relevant employer, additional experience, comments).
   - For **radio button ratings** (e.g., familiarity with companies): ASK the user how to rate each item.
   - For **off-limit topics/NDAs**: ASK the user if they have any. If yes, ask what to put in the required comment.
5. **Contact Phone Number**: The user's phone number is already on file. Proceed with the pre-selected number without asking.
6. **Confirm Professional Details**: Automatically check the confirmation checkbox and proceed without asking the user.
7. **Set Project Rate**: Keep the rate at **$1000/hr**. Do NOT adjust the slider. Click "Set project rate" button BEFORE clicking Next (required to avoid form error).
8. **Confirm & Submit**: Check the Terms and Conditions acknowledgment checkbox, then click "Apply for this Project".
9. **Availability** (if the page redirects to availability):
   - The user's default availability is **2:00 PM - 5:00 PM PT on weekdays**.
   - The calendar displays in **EDT (America/New_York)**. Convert PT to ET: **5:00 PM - 8:00 PM EDT**.
   - Add availability for each remaining weekday in the current week (skip past dates).
   - For each day: use "Add Availability", pick the date via the date picker calendar, set start time to 5:00 PM and end time to 8:00 PM, then Save.
   - After all days are added, click Next.

## Saved Preferences (do NOT ask the user about these)

- **Phone number**: Use whatever is pre-selected (do not change)
- **Biography confirmation**: Always confirm
- **Hourly rate**: $1000/hr (do not adjust)
- **Terms acknowledgment**: Always accept
- **Availability**: 2-5pm PT weekdays (= 5-8pm EDT)

## Important Notes

- The GLG form uses custom MUI components. Radio buttons and checkboxes often have labels intercepting clicks — if a direct click times out, try clicking the label element instead, or use `page.evaluate()` with JavaScript to click the label by its `for` attribute.
- For combobox/select dropdowns (like start/end time), click the combobox to open the listbox, then click the desired option.
- For the date picker, click the calendar button next to the date field to open it, then click the desired day in the grid.
- Always click "Set project rate" on the rate page before clicking Next, or the form will error.
