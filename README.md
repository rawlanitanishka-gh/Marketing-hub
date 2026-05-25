# ⚡ Marketing Hub — New Age AI

An internal AI-powered marketing tool for the New Age AI team. Built for Google Ads, SEO, Meta Ads, and Marketing Automation workflows — no more writing long prompts from scratch every time.

---

## What It Does

Marketing Hub gives your team a library of pre-built, structured prompt templates for every marketing task. Fill in a few fields, hit Generate, and Claude writes the output for you in seconds.

Every usage is tracked — as admin you can see who's using what, how often, and when.

---

## Features

- 🎯 **Google Ads** — RSA copy, keyword research, campaign audits, ad extensions
- 🔍 **SEO** — Meta tags, blog briefs, on-page audits, competitor gap analysis
- 📱 **Meta Ads** — Feed/Story/Carousel copy, audience targeting, campaign analysis, creative briefs
- ⚡ **Automation** — Email drip sequences, subject line generator, workflow design, re-engagement campaigns
- 🛡 **Admin Panel** — User management, usage analytics, role control, API key settings

---

## Tech Stack

| Layer | Tool |
|---|---|
| Frontend | Vanilla HTML, CSS, JavaScript (single file) |
| Auth & Database | Supabase (email/password auth + PostgreSQL) |
| AI | Anthropic Claude API (claude-opus-4-5) |
| Hosting | Vercel |

---

## Database Schema

Three tables in Supabase:

**`profiles`** — Extends Supabase auth, stores name, role (user/admin), last seen

**`template_usage`** — Logs every template run with user, template name, category, timestamp

**`app_settings`** — Key-value store for the Anthropic API key (set by admin, readable by all users)

---

## Local Setup

No build step needed — it's a single HTML file.

1. Clone the repo
```bash
git clone https://github.com/your-username/marketing-hub.git
cd marketing-hub
```

2. Open `index.html` directly in your browser — or use a simple local server:
```bash
npx serve .
```

---

## Supabase Setup

1. Go to your [Supabase SQL Editor](https://supabase.com/dashboard)
2. Paste and run the contents of `supabase-setup.sql`
3. Sign up in the app with your email
4. Run this to make yourself admin:
```sql
UPDATE public.profiles SET role = 'admin' WHERE email = 'rawlanitanishka@gmail.com';
```

---

## Deployment (Vercel)

1. Push this repo to GitHub
2. Go to [vercel.com](https://vercel.com) → New Project → Import your repo
3. Deploy with default settings — no environment variables needed
4. Your app is live at `your-project.vercel.app`

Any commit to `main` triggers an automatic redeploy.

---

## First-time Admin Setup

After deploying and logging in as admin:

1. Click **Admin Panel** in the sidebar
2. Paste your Anthropic API key (get it from [console.anthropic.com](https://console.anthropic.com))
3. Click **Save Key**

All logged-in users can now generate content.

---

## Giving Team Access

**Open access** — Share the URL. Anyone can sign up with their email and start using it immediately.

**Restricted access** — Go to Supabase → Authentication → Settings → disable "Allow new users to sign up". Then invite people manually via Supabase → Authentication → Users → Invite User.

You can promote any user to admin (or revoke access) directly from the Admin Panel inside the app.

---

## Admin Panel

As admin you can see:

- Total registered users
- How many users were active today
- Total template runs across the team
- Top used category
- Per-user breakdown (name, email, role, join date, last active, total runs)
- Full recent activity feed
- Anthropic API key management

---

## Adding or Editing Templates

Templates are currently defined in the JavaScript inside `index.html`. Each template has:

```js
{
  id: 'unique-id',
  cat: 'google-ads',         // google-ads | seo | meta-ads | marketing-automation
  title: 'Template Name',
  desc: 'Short description',
  prompt: `Your prompt with [VARIABLE] placeholders`,
  vars: [
    { k: 'VARIABLE', l: 'Label shown to user', p: 'Placeholder text' }
  ]
}
```

To add a new template, duplicate any existing entry in the `TEMPLATES` array and update the fields.

---

## File Structure

```
marketing-hub/
├── index.html        ← entire app (HTML + CSS + JS in one file)
├── supabase-setup.sql  ← run once in Supabase SQL editor
└── README.md
```

---

## Built By

Tanishka Rawlani — Marketing Intern, New Age AI
