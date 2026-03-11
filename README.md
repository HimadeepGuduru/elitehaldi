# 🌿 EliteHaldi Command Center — Deployment & Versioning Guide

## Folder Structure

```
elitehaldi/
├── index.html              ← Entry point — auto-redirects to stable version
├── versions.json           ← Version registry (stable pointer + changelog)
├── versions/
│   ├── v20.html            ← Stable (production)
│   ├── v21.html            ← Dev (work in progress)  ← you edit this
│   └── v22.html            ← Future
├── scripts/
│   ├── new-version.sh      ← Branch a new version from stable
│   ├── promote.sh          ← Promote dev → stable
│   └── deploy.sh           ← Push to GitHub Pages / Netlify / VPS
└── .github/workflows/
    └── deploy.yml          ← Auto-deploy on every git push
```

---

## Day-to-Day Workflow

### 1. Start working on a new version
```bash
./scripts/new-version.sh v21
# This copies v20.html → v21.html and marks it as "dev"
# versions.json: stable=v20, latest=v21
```

### 2. Edit the new version
Open `versions/v21.html` in your editor and make changes.
- Stable (`v20.html`) is **untouched**
- Consultants still see `v20` at the main URL

### 3. Test your dev version
Open directly in browser:
```
file:///path/to/elitehaldi/versions/v21.html
```
Or if deployed:
```
https://your-site.com/versions/v21.html
```

### 4. Promote dev → stable when ready
```bash
./scripts/promote.sh v21
# stable=v21, v20 becomes "archived" (file kept forever)
```

### 5. Deploy
```bash
./scripts/deploy.sh
# Auto-detects GitHub Pages or Netlify
```

---

## One-Time Setup (GitHub Pages)

```bash
# 1. Create a GitHub repo
git init
git remote add origin https://github.com/YOUR_USERNAME/elitehaldi.git

# 2. Push
git add -A
git commit -m "initial: EliteHaldi v20 stable"
git push -u origin main

# 3. Enable GitHub Pages
# Go to: Repo → Settings → Pages → Source: GitHub Actions
# That's it. Every git push auto-deploys.
```

**Your URLs after setup:**
```
Main (stable auto-redirect):  https://YOUR_USERNAME.github.io/elitehaldi/
Version panel:                https://YOUR_USERNAME.github.io/elitehaldi/?panel=true
Stable direct link:           https://YOUR_USERNAME.github.io/elitehaldi/versions/v20.html
Dev link:                     https://YOUR_USERNAME.github.io/elitehaldi/versions/v21.html
Force specific version:       https://YOUR_USERNAME.github.io/elitehaldi/?v=v20
```

---

## One-Time Setup (Netlify — Recommended for Speed)

```bash
# 1. Install Netlify CLI
npm install -g netlify-cli

# 2. Login
netlify login

# 3. Deploy
netlify deploy --prod --dir .

# Future deploys: just run
./scripts/deploy.sh netlify
```

Netlify also supports **drag-and-drop**: go to [app.netlify.com](https://app.netlify.com), drag the entire `elitehaldi/` folder. Done.

---

## Adding a Changelog Entry

After editing `v21.html`, update the changelog in `versions.json`:

```json
{
  "version": "v21",
  "file": "versions/v21.html",
  "date": "2026-03-12",
  "status": "dev",
  "tag": "dev",
  "changelog": [
    "Added UV index tracker to daily view",
    "Fixed Zone B EC range bar alignment",
    "New Curcumin trend sparkline in yearly tab"
  ]
}
```

---

## Version Status Reference

| Status     | Meaning                              | Who sees it     |
|------------|--------------------------------------|-----------------|
| `stable`   | Production. `index.html` points here | Everyone        |
| `dev`      | Work in progress                     | You + testers   |
| `archived` | Old stable, still accessible         | Via direct URL  |

---

## Share Links with Consultants

| Purpose              | URL                                    |
|----------------------|----------------------------------------|
| Always latest stable | `your-site.com/`                       |
| Specific version     | `your-site.com/?v=v20`                 |
| Version panel        | `your-site.com/?panel=true`            |
| Dev preview          | `your-site.com/versions/v21.html`      |
