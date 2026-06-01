# Interview Pitch — MyCalender

How to introduce this app in an interview in a way that maximizes a company's perceived value (and your hireability).

---

## The core insight

Most candidates open with **"I built a calendar app, it has month/day/week views, lets you add events..."** — a feature list. Forgettable.

The interesting version flips it and leads with the **decisions you made**, not the screens you built.

---

## The opening hook (memorize this)

> "I built a calendar app — but the interesting part isn't the calendar. It's that before I wrote a single screen, I made five architectural decisions that I think would have measurable impact on a team's shipping speed. Can I walk you through them?"

That opening does three things in 20 seconds:

1. **Signals product/business thinking** ("measurable impact on a team's shipping speed").
2. **Reframes the conversation** away from "demo my work" toward "discuss my judgment."
3. **Invites the interviewer in** — they say yes, you're already controlling the narrative.

---

## The 3-minute structure

### Minute 1 — One specific feature, one specific decision, one specific outcome

Pick the multi-day banner that spans across month cells. Show it. Then say:

> "To implement this, I had two choices: hack each cell individually, or invent a shared coordinate system. I picked the second. The result: when I later added all-day events, they reused 80% of the same code. If your team adds drag-to-reschedule next sprint, that work is already paid for."

That's the move. **One screen → one trade-off → one downstream win.** Repeat for 2-3 more features.

### Minute 2 — Pick the bug you handled best

Story format:

1. Here's a bug I shipped.
2. Here's how I noticed.
3. Here's what I changed in the architecture so it can't recur.

This is gold in interviews because it shows:
- You ship, you hit bugs (everyone does).
- You investigate root causes, not symptoms.
- You change *systems*, not just code.

For MyCalender, the "delete event didn't refresh the month grid" → fixed via `viewWillAppear` reload + closure callback is a great one.

### Minute 3 — Tie it back to the company

> "If I joined your team and you asked me to add [recurring events / sharing / push reminders], here's what would already be in place: [list 3 architectural pieces]. What I'd need to figure out: [1 honest gap]. I'd estimate [X weeks]."

This is the killer move — you're showing them you can **estimate**, you know what you don't know, and you can transition from "my code" thinking to "your team" thinking.

---

## Three "out-of-the-box" framings to choose from

### The retrospective frame — open with one mistake

> "Halfway through I made a struct that should've been a class — events disappeared from the grid. The fix took 10 minutes. The lesson — about value vs reference semantics — took longer. Let me show you what I changed."

Interviewers respect this enormously. It signals confidence in your own learning.

### The "if I had a team" frame — imagine you're hiring for this codebase

> "If I were onboarding a new iOS dev to this codebase, I'd give them this README."

Show your `ARCHITECTURE.md`. Walk through the five decisions as if you're explaining them to a new hire on day one. This pivots the conversation from "candidate showing off" to "team lead reasoning."

### The product-decision frame — pick a feature you *didn't* build

> "I deliberately didn't add recurring events. Here's why: [time constraint / API design wasn't clear yet / wanted to ship single events first]. Most candidates' portfolios are graveyards of half-features. Mine is a focused MVP because I optimized for finishing."

This shows discipline, which senior interviewers value more than scope.

---

## Tying every decision to revenue

Companies don't pay for clean code. They pay for things that affect revenue. Translate every choice into one of these:

| Decision | Revenue framing |
|---|---|
| `EventStore` singleton | "When the team adds CloudKit sync next quarter, it's one file, not eight" → **faster feature shipping** |
| Closures over delegates | "Junior devs read this codebase 2× faster than a delegate-heavy one" → **faster onboarding** |
| Localized for Hebrew | "If you wanted to launch in Israel / Saudi tomorrow, RTL is already handled" → **larger addressable market** |
| Programmatic week view | "When iPad support is a priority, the week view scales — no storyboard rewrite" → **device coverage = more users** |
| Core Data over UserDefaults | "Once you cross 10k events per user, queries are still under 50ms" → **scales with successful users** |

The pattern: **architecture decision → engineering implication → business outcome.** Three steps, always.

---

## What to avoid

- ❌ **Don't run the simulator and tap through screens.** It looks like you can't articulate decisions without the UI to lean on.
- ❌ **Don't apologize for missing features.** "I would've added X but didn't have time" sounds defensive. Reframe as: "I deliberately scoped to Y because Z."
- ❌ **Don't go deep on Swift syntax** unless asked. They can read code; they want to know how you think.
- ❌ **Don't say "best practices"** without naming the practice. It's a filler phrase.

---

## The killer closing line

> "I shipped this in [X] weeks, hit [Y] non-trivial bugs, and resolved them by changing the architecture rather than patching the symptom. If you give me a similar problem in your codebase, you'll get a similar process — and a similar codebase you'd be okay maintaining after I leave."

That last clause — **"a codebase you'd be okay maintaining after I leave"** — is the most underrated line in tech interviews. Most candidates pitch what they can build. Almost none pitch what they *leave behind*. Companies care enormously about the second.

---

## TL;DR

Don't demo the app. **Demo your decision-making.**

1. Pick three features.
2. Attach one trade-off to each.
3. End every trade-off with "and here's how that would help your team."

That's the version that gets remembered.

---

## Quick reference — the five decisions, one sentence each

1. **UIKit + Storyboards** — chosen because we draw at exact coordinates (event blocks at `y = hour × 60`).
2. **`EventStore.shared` singleton** — one place for all event CRUD, future cross-cutting concerns land here.
3. **In-memory `CalenderDay`** — the 42-cell grid is presentational, rebuilt per month switch (not persisted).
4. **Closure callbacks for VC-to-VC** — local, readable, lighter than delegate protocols for one-shot handoffs.
5. **Programmatic UI inside storyboard scenes** — storyboard for static skeleton, code for everything data-driven.
