---
name: "dsw-order-call"
description: "Call DSW customer support via Vapi to complete a checkout that is failing online. Use when the user wants to retry placing their DSW order by phone, or follow up on a previous DSW checkout error call."
---

# DSW Order Call

## Overview

Use this skill when the user wants to call DSW customer support to complete an online order that is failing at checkout. The workflow uses Vapi to place an outbound call, navigate the IVR, get transferred to a live agent, and have the agent complete the order.

## Known Context

- DSW customer support number: **1-866-379-7463** (+18663797463)
- Account email: advaypal@hotmail.com
- Account name: Advay Pal (first: Advay a-d-v-a-y, last: Pal p-a-l)
- Shipping address: 3165 Mission St, Apt 501, San Francisco, CA 94110
- ZIP code: 94110
- Payment: Mastercard ending in 6957 on file
- Item (as of 2026-04-01): Skechers Hands Free Slip-Ins Deluxe Journey Boots, black, size 11.5 medium, $114.99 ($124.91 with tax)
- Free shipping preferred

**Before calling, confirm with the user whether the item in the cart has changed since the last attempt.**

## Vapi Setup

- Vapi API key: ask the user or check environment variable `VAPI_API_KEY`
- Phone number ID: `c434faaa-a393-4b91-a73e-38e35dd009ae` (verify it still exists)
- Reuse or create an assistant with the prompt below

## Assistant Prompt

```text
You are Advay Pal, calling DSW customer support about a checkout error.

Goal:
- You have items in your cart on dsw.com but checkout is failing with an error telling you to call customer support.
- You need the rep to help complete the order.

Account details (provide when asked):
- Name: Advay Pal (first name Advay: a-d-v-a-y, last name Pal: p-a-l)
- Email: advaypal@hotmail.com (a-d-v-a-y-p-a-l at hotmail dot com)
- ZIP code: 94110
- Phone number on account: say you do not have it handy right now
- Payment: Mastercard ending in 6957 on file
- Shipping address: 3165 Mission St, Apt 501, San Francisco, CA 94110

Behavior:
- Speak naturally as a regular person. You are Advay.
- If the other side is clearly an IVR or phone tree, respond with the shortest valid answer only.
- If asked to press a number, say the number clearly.
- When a live human answers, say: Hi, I need help completing a checkout on dsw.com. I keep getting an error when I try to check out. Can you help?
- Provide account details when asked. Spell out the email clearly and slowly.
- Be persistent but polite. If they say they cannot help, ask to escalate or transfer.
- IMPORTANT: If put on hold, stay completely silent and wait. Do NOT speak while on hold. The hold may last several minutes.
- When the IVR asks if you want to provide feedback, press 2.
- Stay on topic. Do not end the call until the issue is resolved or you have been clearly told no one can help.
```

## Assistant Configuration

```json
{
  "model": {
    "provider": "openai",
    "model": "gpt-4.1"
  },
  "voice": {
    "provider": "vapi",
    "voiceId": "Elliot"
  },
  "transcriber": {
    "provider": "deepgram",
    "model": "nova-2"
  },
  "firstMessageMode": "assistant-speaks-first",
  "firstMessage": "Hi, I need help with a checkout error on my existing DSW account.",
  "silenceTimeoutSeconds": 1800
}
```

## Workflow

1. **Confirm details with user.** Ask if the item in the cart is still the same, and if any account details have changed.

2. **Get or reuse Vapi API key.** Check for `VAPI_API_KEY` in the environment. If not found, ask the user.

3. **Verify phone number.** Call `GET /phone-number` and confirm the phone number ID above is still active with a real number.

4. **Create or reuse assistant.** Create a new assistant using the prompt and config above. Adjust the prompt if the item or context has changed.

5. **Place the call.** Use `POST /call/phone` with the assistant ID, phone number ID, and DSW's number.

6. **Monitor the call.** Poll `GET /call/{id}` every 30-60 seconds. The call may take 10+ minutes due to hold times.

7. **Auto-retry if needed.** If the user requests it, loop and redial automatically if the call ends without resolution. Check the transcript for keywords like "order has been placed", "order is confirmed", "successfully placed" to detect success.

8. **Use control URL if stuck.** If the assistant gets stuck in the IVR, inject a message via the control URL: `{"type": "end-call"}` to hang up and retry, or `{"type": "add-message", ...}` to course-correct.

9. **Report results.** Show the user the transcript and outcome. If DSW's system is down, report that and suggest retrying later.

## Known Issues

- DSW's IVR bot says it "cannot place new orders" — frame the request as help with an existing checkout error, not a new order.
- The IVR tries to verify by phone number or rewards number. The AI should ask to verify by other means or request transfer to a live agent.
- Spelling the email over the phone is error-prone. Spell slowly and use phonetic alphabet (a as in apple, d as in dog, etc.).
- DSW's system may be intermittently down — their own reps have hit the same checkout error. If this happens, try again later.
- Long hold times (5-10+ min) are common. Set silenceTimeoutSeconds to at least 1800.
