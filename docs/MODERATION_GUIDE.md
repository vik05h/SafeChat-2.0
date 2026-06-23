# SafeChat Safety & Moderation — User & Moderator Guide

SafeChat is built to stop cyberbullying **before** it reaches anyone. Every post,
comment, and direct message is checked for harmful content the moment you hit
send. This guide explains, in plain language, what that means for you — whether
you're a regular user or a moderator.

> Looking for the technical details (how the engine works, how to deploy)? See
> [`MODERATION.md`](./MODERATION.md).

---

## For everyone

### What gets flagged, and why
We check your text for cyberbullying so the people you talk to don't have to see
it. Two things can flag a message:

1. **Banned words** — slurs, threats, and insults (in English, Hindi, and
   Hinglish). These are caught instantly, even if you try to disguise them
   (e.g. `id1ot`, `i.d.i.o.t`, `idioooot`).
2. **Bullying phrasing** — our safety model also recognizes mean, harassing, or
   demeaning sentences *even when they contain no banned word* (for example,
   "nobody wants you here" or "your face is scaring people").

Clean messages send instantly — you'll never notice the check.

### "This can't be uploaded" — your two options
If something you write is flagged, a popup appears showing **your text with the
flagged words highlighted in red**. You have two choices:

- **Edit** — change the wording and try again.
- **Submit for human verification** — if you believe the flag is a mistake, send
  it to a human moderator to review.

Nothing is posted while it's flagged.

### "I think this is a mistake" — submitting for human verification
Our filter isn't perfect — sometimes a perfectly fine message gets flagged (a
"false positive"). That's what **Submit for human verification** is for:

- Your content is saved **privately** — nobody else can see it yet.
- A moderator reviews it and decides.
- You get a notification when there's a decision.

### Tracking your content — Profile ▸ Content Status / Appeals
Open your **Profile** and tap the **⚖️ Content Status / Appeals** button to see
everything you've sent for review:

| Status | What it means |
|---|---|
| 🟠 **Under review** | A moderator hasn't decided yet. |
| 🟢 **Approved** | It passed review and is now live. |
| 🔴 **Rejected** | It won't be published — the **reason** is shown underneath. |

### Where approved content goes
Once approved, content reaches its normal audience:

- **Post** → your feed / the global feed
- **Comment** → onto the post
- **Direct message** → delivered to the person you messaged

Rejected content is never shown to anyone.

---

## For moderators

### Getting moderator access
Moderator access is a special permission on your account (not just a username).
An administrator grants it once with a quick setup step; after that, **sign out
and sign back in** so your app picks up the new permission. *(Admins: the exact
command is in [`MODERATION.md`](./MODERATION.md) → "Admin access".)*

### Reviewing the queue
1. Go to **Profile ▸ ⚙️ Settings** and scroll to **"Moderation Queue"** (this
   only appears for moderators).
2. Each item shows the flagged content (with the words highlighted), who wrote
   it, and whether it's a post, comment, or DM.
3. Choose:
   - **Approve** → the content is published and the author is notified. 🎉
   - **Reject** → you type a short **reason**; the content stays hidden and the
     author sees your reason on their Content Status screen.

### Tips for fair, consistent review
- **Read the whole message**, not just the highlighted word — context matters
  (e.g. quoting someone, reclaiming a word, or discussing a topic vs. attacking
  a person).
- **Write clear rejection reasons** — the author reads them, and a good reason
  helps them understand and do better.
- When unsure, lean toward protecting the recipient: this is a teen-safety app.

---

## FAQ

**Why was my normal message flagged?**
Our AI model is still learning and can over-flag. If your message is fine, tap
*Submit for human verification* — a person will review it.

**Can other people see my flagged message while it's under review?**
No. Content under review is private to you and moderators until it's approved.

**What happens to a rejected message?**
It's never shown to anyone. You'll see it marked **Rejected** with the reason in
Profile ▸ Content Status / Appeals.

**Does this work in DMs too?**
Yes — posts, comments, and direct messages all go through the same checks.

**I keep getting flagged for the same fine phrase. Can that be fixed?**
Yes — moderators/admins can teach the model by approving it; over time the
filter learns. See the [improvement roadmap](./MODERATION_ROADMAP.md).
