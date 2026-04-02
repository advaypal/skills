---
name: generate-sublet-agreement
description: Generate a new copy of Advay's canonical sublet agreement at `/Users/advaypal/Library/Mobile Documents/com~apple~CloudDocs/Documents/sublet agreement.pages`. Ask for the incoming subtenant's full name if missing, update the agreement date to the current local date, preserve layout, save the new agreement on the Desktop, add the real signature, and export a checked PDF.
argument-hint: <full legal name of the new subtenant>
user-invocable: true
---

# Generate Sublet Agreement

Use this skill only for Advay's canonical sublet agreement at `/Users/advaypal/Library/Mobile Documents/com~apple~CloudDocs/Documents/sublet agreement.pages`. The workflow is fixed: get the new subtenant's full name, duplicate that exact file onto the Desktop, update the other party's name and today's local date, preserve the layout, add the real signature, export a PDF on the Desktop, and review it before sending.

## Inputs

- Required: the incoming subtenant's full legal name
- Automatic: the current local date in `MM/DD/YYYY`
- Fixed source: `/Users/advaypal/Library/Mobile Documents/com~apple~CloudDocs/Documents/sublet agreement.pages`
- Output directory: `/Users/advaypal/Desktop`

If the full legal name is not already provided in `$ARGUMENTS`, ask for it before making any edits.

## Workflow

1. Use only the canonical source file.
   - Start from `/Users/advaypal/Library/Mobile Documents/com~apple~CloudDocs/Documents/sublet agreement.pages`.
   - Do not use prior generated copies such as Turner or any other person's agreement as the base.
   - Stop if the canonical source file is missing.

2. Get the name first.
   - If `$ARGUMENTS` already contains the incoming subtenant's full legal name, use it.
   - Otherwise ask only for that name before proceeding.

3. Duplicate and rename the source.
   - Create an editable copy on the Desktop named `/Users/advaypal/Desktop/sublet agreement - <Full Name>.pages`.
   - Keep the original source untouched.

4. Update only the required fields.
   - Replace the non-user party name with the provided full legal name.
   - Set the agreement date to today's local date in `MM/DD/YYYY`.
   - Leave all other legal wording unchanged unless the user explicitly asks for more edits.

5. Edit in place and preserve layout.
   - Make the changes inside Pages or through UI-level automation that preserves text boxes, spacing, headers, and pagination.
   - Do not use AppleScript `body text` round-trips or any full-document plain-text rewrite.
   - If the available automation path cannot preserve layout, stop and say so.

6. Handle signatures authentically.
   - Use an existing real signature asset, a previously signed source, or the app's native signature workflow.
   - Never fake a signature with a handwriting font, typed name, or synthetic scribble unless the user explicitly asks for that.
   - If a valid signature source is unavailable, report the blocker.

7. Export the final files.
   - Save the editable Pages copy on the Desktop first.
   - Export the reviewed PDF on the Desktop as `/Users/advaypal/Desktop/sublet agreement - <Full Name> signed.pdf`.
   - Prefer export directly from Pages rather than a lossy conversion path.

8. Visually validate before sending.
   - Compare the output against the source at minimum on the first page, every edited page, and the signature page.
   - Check for text reflow, clipped lines, moved signature blocks, altered spacing, missing pages, and broken pagination.
   - If the result looks off, fix it in the native app before sending.

9. Send only validated files.
   - If the user asks you to message someone, attach only the reviewed PDF.
   - Describe the document accurately and avoid claiming anything was signed or approved unless that is true.

## Hard Stops

- Stop if the incoming subtenant's full legal name is unavailable.
- Stop if the canonical source file is missing or cannot be opened.
- Stop if the only available method would rewrite the entire rich document as plain text.
- Stop if signature authenticity cannot be preserved.
- Say that fidelity cannot be guaranteed instead of producing a degraded document.

## Common Failure Modes

- Replacing the full `body text` of a Pages document and destroying layout
- Using a prior generated agreement instead of the canonical `sublet agreement.pages` source
- Overlaying a script-font "signature" instead of using a real one
- Exporting or sending without opening the final file and checking it visually
